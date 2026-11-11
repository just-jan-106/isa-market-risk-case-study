-- 04 | Unconditional historical risk, concentration and current-weight risk attribution.
-- Dependencies: portfolio_returns/values/weights and alligned_daily_returns.

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.portfolio_drawdowns` AS
WITH running_peaks AS (
  SELECT date, portfolio_value,
         MAX(portfolio_value) OVER (
           ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
         ) AS running_peak
  FROM `isa-market-risk.isa_market_risk.portfolio_values`
)
SELECT date, portfolio_value, running_peak,
       SAFE_DIVIDE(portfolio_value, running_peak) - 1 AS drawdown
FROM running_peaks;

-- Minimum drawdown should be approx -0.20786751064538322.
SELECT MIN(drawdown) AS maximum_drawdown
FROM `isa-market-risk.isa_market_risk.portfolio_drawdowns`;

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.portfolio_risk_metrics` AS
WITH valid_returns AS (
  SELECT date, portfolio_return
  FROM `isa-market-risk.isa_market_risk.portfolio_returns`
  WHERE portfolio_return IS NOT NULL
), var_thresholds AS (
  SELECT DISTINCT
         PERCENTILE_CONT(portfolio_return, 0.05) OVER () AS percentile_05,
         PERCENTILE_CONT(portfolio_return, 0.01) OVER () AS percentile_01
  FROM valid_returns
)
SELECT COUNT(*) AS total_observations,
       -MAX(v.percentile_05) AS var_95,
       -MAX(v.percentile_01) AS var_99,
       -AVG(IF(r.portfolio_return <= v.percentile_05, r.portfolio_return, NULL)) AS es_95,
       -AVG(IF(r.portfolio_return <= v.percentile_01, r.portfolio_return, NULL)) AS es_99,
       COUNTIF(r.portfolio_return <= v.percentile_05) AS tail_observations_95,
       COUNTIF(r.portfolio_return <= v.percentile_01) AS tail_observations_99
FROM valid_returns r CROSS JOIN var_thresholds v;

-- Expected: n=676, var95=0.0139304, es95=0.0220505,
-- var99=0.0236613, es99=0.0365714, tail counts 34 and 7.
SELECT * FROM `isa-market-risk.isa_market_risk.portfolio_risk_metrics`;

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.correlation_matrix` AS
SELECT a.historical_ticker AS ticker_1,
       b.historical_ticker AS ticker_2,
       CORR(a.alligned_return, b.alligned_return) AS correlation,
       COUNTIF(a.alligned_return IS NOT NULL AND b.alligned_return IS NOT NULL)
         AS paired_observations
FROM `isa-market-risk.isa_market_risk.alligned_daily_returns` a
INNER JOIN `isa-market-risk.isa_market_risk.alligned_daily_returns` b
  ON a.date = b.date
GROUP BY ticker_1, ticker_2;

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.instrument_volatility` AS
SELECT r.historical_ticker, i.instrument_name, i.asset_type,
       COUNT(r.alligned_return) AS observations,
       AVG(r.alligned_return) AS average_daily_return,
       STDDEV_SAMP(r.alligned_return) AS daily_volatility,
       STDDEV_SAMP(r.alligned_return) * SQRT(252) AS annualised_volatility
FROM `isa-market-risk.isa_market_risk.alligned_daily_returns` r
INNER JOIN `isa-market-risk.isa_market_risk.instrument_master` i
  ON r.historical_ticker = i.historical_ticker
GROUP BY r.historical_ticker, i.instrument_name, i.asset_type;

-- Current-weight covariance decomposition differs from historical drifting-weight
-- portfolio realised volatility. Individual percentage contributions can be negative.
CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.current_weight_risk_contributions` AS
WITH current_weights AS (
  SELECT historical_ticker, portfolio_weight
  FROM `isa-market-risk.isa_market_risk.current_portfolio_composition`
), covariance_matrix AS (
  SELECT a.historical_ticker AS ticker_1, b.historical_ticker AS ticker_2,
         COVAR_SAMP(a.alligned_return, b.alligned_return) AS covariance
  FROM `isa-market-risk.isa_market_risk.alligned_daily_returns` a
  INNER JOIN `isa-market-risk.isa_market_risk.alligned_daily_returns` b
    ON a.date = b.date
  WHERE a.alligned_return IS NOT NULL AND b.alligned_return IS NOT NULL
  GROUP BY ticker_1, ticker_2
), weighted_covariance AS (
  SELECT c.ticker_1,
         SUM(w2.portfolio_weight * c.covariance) AS covariance_with_portfolio
  FROM covariance_matrix c
  INNER JOIN current_weights w2 ON c.ticker_2 = w2.historical_ticker
  GROUP BY c.ticker_1
), contributions AS (
  SELECT w.historical_ticker, w.portfolio_weight,
         w.portfolio_weight * c.covariance_with_portfolio AS variance_contribution
  FROM current_weights w
  INNER JOIN weighted_covariance c ON w.historical_ticker = c.ticker_1
), portfolio_variance AS (
  SELECT SUM(variance_contribution) AS total_variance FROM contributions
)
SELECT c.historical_ticker, c.portfolio_weight, c.variance_contribution,
       SAFE_DIVIDE(c.variance_contribution, p.total_variance) AS percentage_risk_contribution,
       SAFE_DIVIDE(c.variance_contribution, SQRT(p.total_variance))
         AS absolute_daily_volatility_contribution,
       SQRT(p.total_variance) * SQRT(252) AS implied_annualised_portfolio_volatility
FROM contributions c CROSS JOIN portfolio_variance p;

-- Expected contribution sum 1; implied volatility ~0.150301743.
SELECT SUM(percentage_risk_contribution) AS total_risk_contribution,
       MAX(implied_annualised_portfolio_volatility) AS implied_annualised_volatility
FROM `isa-market-risk.isa_market_risk.current_weight_risk_contributions`;

-- Final single-row dashboard KPI extract.
CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.dashboard_kpis` AS
WITH volatility AS (
  SELECT STDDEV_SAMP(portfolio_return) * SQRT(252) AS annualised_volatility
  FROM `isa-market-risk.isa_market_risk.portfolio_returns`
), drawdowns AS (
  SELECT MIN(drawdown) AS maximum_drawdown
  FROM `isa-market-risk.isa_market_risk.portfolio_drawdowns`
), risk AS (
  SELECT var_95, es_95, var_99, es_99
  FROM `isa-market-risk.isa_market_risk.portfolio_risk_metrics`
), latest_portfolio AS (
  SELECT date AS latest_date, portfolio_value AS latest_portfolio_value
  FROM `isa-market-risk.isa_market_risk.portfolio_values`
  ORDER BY date DESC LIMIT 1
)
SELECT p.latest_date, p.latest_portfolio_value, v.annualised_volatility,
       d.maximum_drawdown, r.var_95, r.es_95, r.var_99, r.es_99
FROM latest_portfolio p CROSS JOIN volatility v
CROSS JOIN drawdowns d CROSS JOIN risk r;
