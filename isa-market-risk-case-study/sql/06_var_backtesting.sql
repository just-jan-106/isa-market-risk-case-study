-- 06 | Rolling 250-prior-observation historical VaR backtest + tests.
-- Current day's return excluded from estimation. 95% one-interval forecast.

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.var_backtest_95` AS
WITH ordered_returns AS (
  SELECT date, portfolio_return,
         ROW_NUMBER() OVER (ORDER BY date) AS observation_number
  FROM `isa-market-risk.isa_market_risk.portfolio_returns`
  WHERE portfolio_return IS NOT NULL
), historical_windows AS (
  SELECT current_day.date,
         current_day.portfolio_return AS realised_return,
         past_day.date AS historical_date,
         past_day.portfolio_return AS historical_return
  FROM ordered_returns current_day
  INNER JOIN ordered_returns past_day
    ON past_day.observation_number BETWEEN current_day.observation_number - 250
                                       AND current_day.observation_number - 1
), rolling_thresholds AS (
  SELECT date, realised_return,
         PERCENTILE_CONT(historical_return, 0.05) OVER (PARTITION BY date)
           AS var_return_threshold,
         COUNT(*) OVER (PARTITION BY date) AS estimation_observations,
         ROW_NUMBER() OVER (PARTITION BY date ORDER BY historical_date DESC) AS row_number
  FROM historical_windows
)
SELECT date, realised_return,
       -var_return_threshold AS forecast_var_95,
       var_return_threshold, estimation_observations,
       realised_return < var_return_threshold AS is_var_exception
FROM rolling_thresholds
WHERE row_number = 1 AND estimation_observations = 250;

-- Expect n=426, exceptions=23, exception rate 5.40%, expected 21.3.
SELECT COUNT(*) AS backtest_observations,
       COUNTIF(is_var_exception) AS actual_exceptions,
       ROUND(100 * SAFE_DIVIDE(COUNTIF(is_var_exception), COUNT(*)), 2)
         AS exception_rate_pct,
       ROUND(COUNT(*) * 0.05, 2) AS expected_exceptions,
       MIN(date) AS first_backtest_date, MAX(date) AS last_backtest_date
FROM `isa-market-risk.isa_market_risk.var_backtest_95`;

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.kupiec_pof_test` AS
WITH exception_counts AS (
  SELECT COUNT(*) AS observations, COUNTIF(is_var_exception) AS exceptions
  FROM `isa-market-risk.isa_market_risk.var_backtest_95`
), parameters AS (
  SELECT observations, exceptions, 0.05 AS expected_probability,
         SAFE_DIVIDE(exceptions, observations) AS observed_probability
  FROM exception_counts
), kupiec_test AS (
  SELECT observations, exceptions, expected_probability, observed_probability,
         2 * (
           exceptions * LN(observed_probability / expected_probability)
           + (observations - exceptions) *
             LN((1 - observed_probability) / (1 - expected_probability))
         ) AS lr_pof
  FROM parameters
)
SELECT observations, exceptions,
       ROUND(observed_probability * 100, 2) AS observed_exception_rate_pct,
       ROUND(lr_pof, 4) AS kupiec_statistic, 3.841 AS critical_value,
       IF(lr_pof > 3.841, 'Reject H0', 'Do not reject H0') AS test_conclusion
FROM kupiec_test;
-- Formula above assumes 0 < exceptions < observations (true for this dataset).

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.christoffersen_independence_test` AS
WITH exception_sequence AS (
  SELECT date, is_var_exception,
         LAG(is_var_exception) OVER (ORDER BY date) AS previous_exception
  FROM `isa-market-risk.isa_market_risk.var_backtest_95`
), transitions AS (
  SELECT COUNTIF(previous_exception = FALSE AND is_var_exception = FALSE) AS n00,
         COUNTIF(previous_exception = FALSE AND is_var_exception = TRUE) AS n01,
         COUNTIF(previous_exception = TRUE AND is_var_exception = FALSE) AS n10,
         COUNTIF(previous_exception = TRUE AND is_var_exception = TRUE) AS n11
  FROM exception_sequence WHERE previous_exception IS NOT NULL
), probabilities AS (
  SELECT *,
         SAFE_DIVIDE(n01 + n11, n00 + n01 + n10 + n11) AS p,
         SAFE_DIVIDE(n01, n00 + n01) AS p01,
         SAFE_DIVIDE(n11, n10 + n11) AS p11
  FROM transitions
), likelihoods AS (
  SELECT *,
         n00 * LN(GREATEST(1 - p01, 1e-12)) + n01 * LN(GREATEST(p01, 1e-12))
         + n10 * LN(GREATEST(1 - p11, 1e-12)) + n11 * LN(GREATEST(p11, 1e-12))
           AS log_likelihood_alternative,
         (n00 + n10) * LN(GREATEST(1 - p, 1e-12))
         + (n01 + n11) * LN(GREATEST(p, 1e-12)) AS log_likelihood_null
  FROM probabilities
), test_result AS (
  SELECT *, 2 * (log_likelihood_alternative - log_likelihood_null) AS lr_ind
  FROM likelihoods
)
SELECT n00, n01, n10, n11,
       ROUND(p01 * 100, 2) AS exception_after_normal_pct,
       ROUND(p11 * 100, 2) AS exception_after_exception_pct,
       ROUND(lr_ind, 4) AS christoffersen_statistic,
       3.841 AS critical_value,
       IF(lr_ind > 3.841, 'Reject H0', 'Do not reject H0') AS conclusion
FROM test_result;

-- Auxiliary first-order combined conditional coverage statistic, df=2.
SELECT k.kupiec_statistic + c.christoffersen_statistic AS approx_lr_cc,
       5.991 AS critical_value_5pct
FROM `isa-market-risk.isa_market_risk.kupiec_pof_test` k
CROSS JOIN `isa-market-risk.isa_market_risk.christoffersen_independence_test` c;
