-- 07 | Worst observed portfolio dates, daily active return and stress attribution.
-- The 10 selected stress days are portfolio's 10 lowest individual return dates.

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.stress_test_daily_returns` AS
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
SELECT date, portfolio_return, benchmark_return,
       portfolio_return - benchmark_return AS active_return
FROM daily_returns
WHERE portfolio_return IS NOT NULL AND benchmark_return IS NOT NULL;

-- Worst 10 daily returns.
SELECT date, ROUND(portfolio_return * 100, 2) AS portfolio_return_pct,
       ROUND(benchmark_return * 100, 2) AS benchmark_return_pct,
       ROUND(active_return * 100, 2) AS active_return_pp
FROM `isa-market-risk.isa_market_risk.stress_test_daily_returns`
ORDER BY portfolio_return ASC LIMIT 10;

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.stress_loss_attribution` AS
WITH worst_days AS (
  SELECT date, portfolio_return
  FROM `isa-market-risk.isa_market_risk.stress_test_daily_returns`
  ORDER BY portfolio_return ASC LIMIT 10
), instrument_prices AS (
  SELECT date, historical_ticker, aligned_price_gbp,
         LAG(aligned_price_gbp) OVER (
           PARTITION BY historical_ticker ORDER BY date
         ) AS previous_price_gbp
  FROM `isa-market-risk.isa_market_risk.alligned_market_prices_gbp`
), previous_portfolio_values AS (
  SELECT date, LAG(portfolio_value) OVER (ORDER BY date) AS previous_portfolio_value
  FROM `isa-market-risk.isa_market_risk.portfolio_values`
)
SELECT p.date, p.historical_ticker, q.quantity_owned,
       p.aligned_price_gbp, p.previous_price_gbp,
       SAFE_DIVIDE(q.quantity_owned * (p.aligned_price_gbp - p.previous_price_gbp),
                   v.previous_portfolio_value) AS return_contribution,
       100 * SAFE_DIVIDE(q.quantity_owned * (p.aligned_price_gbp - p.previous_price_gbp),
                         v.previous_portfolio_value) AS contribution_pp
FROM instrument_prices p
INNER JOIN `isa-market-risk.isa_market_risk.portfolio_quantities` q
  ON p.historical_ticker = q.historical_ticker
INNER JOIN previous_portfolio_values v ON p.date = v.date
INNER JOIN worst_days w ON p.date = w.date;

-- Expect exactly 10 dates x 21 instruments = 210 rows, differences ~0.
SELECT a.date,
       ROUND(SUM(a.contribution_pp), 4) AS summed_holding_contributions_pp,
       ROUND(100 * s.portfolio_return, 4) AS portfolio_return_pct,
       ROUND(SUM(a.contribution_pp) - 100 * s.portfolio_return, 6)
         AS reconciliation_difference_pp,
       COUNT(*) AS instrument_count
FROM `isa-market-risk.isa_market_risk.stress_loss_attribution` a
INNER JOIN `isa-market-risk.isa_market_risk.stress_test_daily_returns` s
  ON a.date = s.date
GROUP BY a.date, s.portfolio_return ORDER BY a.date;

-- April 3-4 arithmetic daily contribution totals (NOT compounded 2-day attribution).
SELECT historical_ticker,
       ROUND(SUM(contribution_pp), 4) AS combined_contribution_pp,
       ROUND(SUM(IF(date = DATE '2025-04-03', contribution_pp, 0)), 4)
         AS april_3_contribution_pp,
       ROUND(SUM(IF(date = DATE '2025-04-04', contribution_pp, 0)), 4)
         AS april_4_contribution_pp
FROM `isa-market-risk.isa_market_risk.stress_loss_attribution`
WHERE date IN (DATE '2025-04-03', DATE '2025-04-04')
GROUP BY historical_ticker ORDER BY combined_contribution_pp ASC;
