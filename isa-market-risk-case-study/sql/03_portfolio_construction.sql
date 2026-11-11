-- 03 | Fixed-quantity simulated portfolio and allocation history.
-- Requires 02_currency_conversion.sql and private BigQuery table portfolio_quantities.
-- This is NOT an actual Trading 212 transaction history. Prices were auto-adjusted.

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.portfolio_values` AS
WITH holding_values AS (
  SELECT p.date, p.historical_ticker, q.quantity_owned,
         p.aligned_price_gbp,
         q.quantity_owned * p.aligned_price_gbp AS holding_value_gbp
  FROM `isa-market-risk.isa_market_risk.alligned_market_prices_gbp` p
  INNER JOIN `isa-market-risk.isa_market_risk.portfolio_quantities` q
    ON p.historical_ticker = q.historical_ticker
)
SELECT date, SUM(holding_value_gbp) AS portfolio_value
FROM holding_values
GROUP BY date;

-- Expect 677 date observations; latest simulated valuation ~GBP 188.84.
SELECT COUNT(*) AS valuation_dates, MIN(date) AS start_date,
       MAX(date) AS end_date,
       ARRAY_AGG(STRUCT(date, portfolio_value) ORDER BY date DESC LIMIT 1)[OFFSET(0)] AS latest
FROM `isa-market-risk.isa_market_risk.portfolio_values`;

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.portfolio_returns` AS
WITH previous_values AS (
  SELECT date, portfolio_value,
         LAG(portfolio_value) OVER (ORDER BY date) AS previous_portfolio_value
  FROM `isa-market-risk.isa_market_risk.portfolio_values`
)
SELECT date, portfolio_value, previous_portfolio_value,
       SAFE_DIVIDE(portfolio_value, previous_portfolio_value) - 1 AS portfolio_return
FROM previous_values;

-- Expect 677 records / 676 valid returns / 1 initial NULL return.
SELECT COUNT(*) AS records, COUNT(portfolio_return) AS valid_returns,
       COUNTIF(portfolio_return IS NULL) AS missing_returns,
       MIN(portfolio_return) AS minimum_return,
       MAX(portfolio_return) AS maximum_return
FROM `isa-market-risk.isa_market_risk.portfolio_returns`;

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.portfolio_weights_history` AS
SELECT p.date, p.historical_ticker, q.quantity_owned, p.aligned_price_gbp,
       q.quantity_owned * p.aligned_price_gbp AS holding_value_gbp,
       v.portfolio_value AS portfolio_value_gbp,
       SAFE_DIVIDE(q.quantity_owned * p.aligned_price_gbp, v.portfolio_value)
         AS portfolio_weight,
       p.is_forward_filled
FROM `isa-market-risk.isa_market_risk.alligned_market_prices_gbp` p
INNER JOIN `isa-market-risk.isa_market_risk.portfolio_quantities` q
  ON p.historical_ticker = q.historical_ticker
INNER JOIN `isa-market-risk.isa_market_risk.portfolio_values` v
  ON p.date = v.date;

-- Expect 21 per date; weights sum to 1 (floating-point tolerance).
SELECT date, COUNT(*) AS instruments, SUM(portfolio_weight) AS weight_sum,
       ABS(SUM(portfolio_weight) - 1) AS deviation
FROM `isa-market-risk.isa_market_risk.portfolio_weights_history`
GROUP BY date ORDER BY deviation DESC LIMIT 10;

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.current_portfolio_composition` AS
SELECT w.date, w.historical_ticker, i.instrument_name, i.asset_type, i.currency,
       w.quantity_owned, w.holding_value_gbp, w.portfolio_value_gbp,
       w.portfolio_weight, w.portfolio_weight * 100 AS weight_pct
FROM `isa-market-risk.isa_market_risk.portfolio_weights_history` w
INNER JOIN `isa-market-risk.isa_market_risk.instrument_master` i
  ON w.historical_ticker = i.historical_ticker
WHERE w.date = (
  SELECT MAX(date) FROM `isa-market-risk.isa_market_risk.portfolio_weights_history`
);

CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.portfolio_concentration` AS
WITH concentration AS (
  SELECT date, COUNT(*) AS instrument_count,
         MAX(portfolio_weight) AS largest_weight,
         SUM(POW(portfolio_weight, 2)) AS hhi,
         COUNTIF(portfolio_weight >= 0.10) AS holdings_above_10pct
  FROM `isa-market-risk.isa_market_risk.portfolio_weights_history`
  GROUP BY date
)
SELECT *, SAFE_DIVIDE(1, hhi) AS effective_holdings
FROM concentration;
