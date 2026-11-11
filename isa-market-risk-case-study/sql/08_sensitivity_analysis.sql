-- 08 | Compare rolling 95% VaR with 125/250/375 prior returns.
-- All three models evaluated on SAME 301 dates (avoid biased comparisons).
-- Forecast excludes the current return (no look-ahead bias).

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.var_sensitivity` AS
WITH ordered_returns AS (
  SELECT date, portfolio_return,
         ROW_NUMBER() OVER (ORDER BY date) AS observation_number
  FROM `isa-market-risk.isa_market_risk.portfolio_returns`
  WHERE portfolio_return IS NOT NULL
), window_sizes AS (
  SELECT window_size FROM UNNEST([125, 250, 375]) AS window_size
), historical_windows AS (
  SELECT current_day.date, current_day.portfolio_return AS realised_return,
         w.window_size, past_day.portfolio_return AS historical_return
  FROM ordered_returns current_day
  CROSS JOIN window_sizes w
  INNER JOIN ordered_returns past_day
    ON past_day.observation_number BETWEEN current_day.observation_number - w.window_size
                                       AND current_day.observation_number - 1
  WHERE current_day.observation_number > 375
), thresholds AS (
  SELECT DISTINCT date, realised_return, window_size,
         COUNT(*) OVER (PARTITION BY date, window_size) AS historical_observations,
         PERCENTILE_CONT(historical_return, 0.05) OVER (PARTITION BY date, window_size)
           AS var_threshold
  FROM historical_windows
)
SELECT date, window_size, realised_return,
       -var_threshold AS forecast_var_95,
       realised_return < var_threshold AS is_exception
FROM thresholds
WHERE historical_observations = window_size;

-- Expected 301 observations per window; exceptions 24/18/18.
CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.var_sensitivity_summary` AS
SELECT window_size, COUNT(*) AS observations,
       COUNTIF(is_exception) AS exceptions,
       ROUND(100 * SAFE_DIVIDE(COUNTIF(is_exception), COUNT(*)), 2) AS exception_rate_pct,
       ROUND(AVG(forecast_var_95) * 100, 3) AS average_var_pct,
       ROUND(MAX(forecast_var_95) * 100, 3) AS maximum_var_pct
FROM `isa-market-risk.isa_market_risk.var_sensitivity`
GROUP BY window_size;

SELECT * FROM `isa-market-risk.isa_market_risk.var_sensitivity_summary`
ORDER BY window_size;
