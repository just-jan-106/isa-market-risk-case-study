-- 05 | Benchmark indexed comparison and rolling volatility.
-- Benchmark VUAG.L is part of the ISA portfolio, NOT fully independent.
-- All indexed values start at 100 on 2024-03-27 (assuming non-null first price).

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.benchmark_comparison` AS
WITH historical_values AS (
  SELECT p.date, p.portfolio_value,
         b.aligned_price_gbp AS benchmark_price
  FROM `isa-market-risk.isa_market_risk.portfolio_values` p
  INNER JOIN `isa-market-risk.isa_market_risk.alligned_market_prices_gbp` b
    ON p.date = b.date
  WHERE b.historical_ticker = 'VUAG.L'
), starting_values AS (
  SELECT date, portfolio_value, benchmark_price,
         FIRST_VALUE(portfolio_value) OVER (
           ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
         ) AS starting_portfolio_value,
         FIRST_VALUE(benchmark_price) OVER (
           ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
         ) AS starting_benchmark_price
  FROM historical_values WHERE benchmark_price IS NOT NULL
)
SELECT date, portfolio_value, benchmark_price,
       100 * SAFE_DIVIDE(portfolio_value, starting_portfolio_value) AS portfolio_index,
       100 * SAFE_DIVIDE(benchmark_price, starting_benchmark_price) AS benchmark_index,
       100 * (SAFE_DIVIDE(portfolio_value, starting_portfolio_value) - 1)
         AS portfolio_cumulative_return_pct,
       100 * (SAFE_DIVIDE(benchmark_price, starting_benchmark_price) - 1)
         AS benchmark_cumulative_return_pct
FROM starting_values;

-- Expect 677 matched rows, 0 missing indices.
SELECT COUNT(*) AS observations, MIN(date) AS start_date, MAX(date) AS end_date,
       COUNTIF(portfolio_index IS NULL) AS missing_portfolio_values,
       COUNTIF(benchmark_index IS NULL) AS missing_benchmark_values
FROM `isa-market-risk.isa_market_risk.benchmark_comparison`;

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.benchmark_risk_comparison` AS
WITH daily_values AS (
  SELECT date, portfolio_index, benchmark_index,
         LAG(portfolio_index) OVER (ORDER BY date) AS previous_portfolio_index,
         LAG(benchmark_index) OVER (ORDER BY date) AS previous_benchmark_index
  FROM `isa-market-risk.isa_market_risk.benchmark_comparison`
), daily_returns AS (
  SELECT date,
         SAFE_DIVIDE(portfolio_index, previous_portfolio_index) - 1 AS portfolio_return,
         SAFE_DIVIDE(benchmark_index, previous_benchmark_index) - 1 AS benchmark_return
  FROM daily_values
)
SELECT COUNT(*) AS observations,
       STDDEV_SAMP(portfolio_return) * SQRT(252) AS portfolio_annualised_volatility,
       STDDEV_SAMP(benchmark_return) * SQRT(252) AS benchmark_annualised_volatility,
       CORR(portfolio_return, benchmark_return) AS return_correlation,
       SAFE_DIVIDE(COVAR_SAMP(portfolio_return, benchmark_return),
                   VAR_SAMP(benchmark_return)) AS portfolio_beta,
       STDDEV_SAMP(portfolio_return - benchmark_return) * SQRT(252)
         AS annualised_tracking_error
FROM daily_returns
WHERE portfolio_return IS NOT NULL AND benchmark_return IS NOT NULL;

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.benchmark_drawdowns` AS
WITH running_peaks AS (
  SELECT date, portfolio_index, benchmark_index,
         MAX(portfolio_index) OVER (
           ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
         ) AS portfolio_running_peak,
         MAX(benchmark_index) OVER (
           ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
         ) AS benchmark_running_peak
  FROM `isa-market-risk.isa_market_risk.benchmark_comparison`
)
SELECT date,
       SAFE_DIVIDE(portfolio_index, portfolio_running_peak) - 1 AS portfolio_drawdown,
       SAFE_DIVIDE(benchmark_index, benchmark_running_peak) - 1 AS benchmark_drawdown
FROM running_peaks;

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.rolling_volatility` AS
WITH daily_prices AS (
  SELECT date, portfolio_index, benchmark_index,
         LAG(portfolio_index) OVER (ORDER BY date) AS previous_portfolio_index,
         LAG(benchmark_index) OVER (ORDER BY date) AS previous_benchmark_index
  FROM `isa-market-risk.isa_market_risk.benchmark_comparison`
), daily_returns AS (
  SELECT date,
         SAFE_DIVIDE(portfolio_index, previous_portfolio_index) - 1 AS portfolio_return,
         SAFE_DIVIDE(benchmark_index, previous_benchmark_index) - 1 AS benchmark_return
  FROM daily_prices
), rolling_metrics AS (
  SELECT date, portfolio_return, benchmark_return,
         COUNT(portfolio_return) OVER (
           ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
         ) AS observations_30d,
         COUNT(portfolio_return) OVER (
           ORDER BY date ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
         ) AS observations_90d,
         STDDEV_SAMP(portfolio_return) OVER (
           ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
         ) * SQRT(252) AS portfolio_volatility_30d,
         STDDEV_SAMP(benchmark_return) OVER (
           ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
         ) * SQRT(252) AS benchmark_volatility_30d,
         STDDEV_SAMP(portfolio_return) OVER (
           ORDER BY date ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
         ) * SQRT(252) AS portfolio_volatility_90d,
         STDDEV_SAMP(benchmark_return) OVER (
           ORDER BY date ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
         ) * SQRT(252) AS benchmark_volatility_90d
  FROM daily_returns
)
SELECT date,
       IF(observations_30d = 30, portfolio_volatility_30d, NULL) AS portfolio_volatility_30d,
       IF(observations_30d = 30, benchmark_volatility_30d, NULL) AS benchmark_volatility_30d,
       IF(observations_90d = 90, portfolio_volatility_90d, NULL) AS portfolio_volatility_90d,
       IF(observations_90d = 90, benchmark_volatility_90d, NULL) AS benchmark_volatility_90d
FROM rolling_metrics;

-- Expect 677 dates; 647 valid 30-return and 587 valid 90-return windows.
SELECT COUNT(*) AS total_dates,
       COUNT(portfolio_volatility_30d) AS valid_30d,
       COUNT(portfolio_volatility_90d) AS valid_90d,
       MAX(portfolio_volatility_30d) AS peak_30d_volatility,
       MAX(portfolio_volatility_90d) AS peak_90d_volatility
FROM `isa-market-risk.isa_market_risk.rolling_volatility`;
