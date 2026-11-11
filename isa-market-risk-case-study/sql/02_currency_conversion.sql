-- 02 | FX conversion, valid-price returns and common valuation calendar.
-- INPUTS: raw_market_prices(date,ticker,adjusted_close),
--         instrument_master(historical_ticker,instrument_name,currency,asset_type),
--         fx_rates(date,currency,gbp_per_unit), fx_supplements(same columns).
-- The supplements table holds recovered observations previously sourced from Yahoo Finance.
-- LIVE NAMING CONVENTION: alligned_market_prices_gbp (double 'l').
-- Output column remains aligned_price_gbp, as used by the final stress SQL.

-- Supplementary FX rows are assumed disjoint from the base rate table.
-- Validate duplicates below before using UNION ALL.
CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.fx_rates_complete` AS
SELECT date, currency, gbp_per_unit
FROM `isa-market-risk.isa_market_risk.fx_rates`
UNION ALL
SELECT date, currency, gbp_per_unit
FROM `isa-market-risk.isa_market_risk.fx_supplements`;

-- Should return no duplicate FX currency/date pairs.
SELECT date, currency, COUNT(*) AS n
FROM `isa-market-risk.isa_market_risk.fx_rates_complete`
GROUP BY date, currency HAVING COUNT(*) > 1;

-- Convert all source prices into GBP. GBX is GBP pence: divide by 100.
-- USD/EUR prices multiplied by GBP per foreign currency unit.
CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.market_prices_gbp` AS
SELECT p.date, p.ticker, p.adjusted_close, i.instrument_name,
       i.currency, i.asset_type, f.gbp_per_unit,
       CASE
         WHEN p.adjusted_close IS NULL THEN NULL
         WHEN i.currency = 'GBP' THEN p.adjusted_close
         WHEN i.currency = 'GBX' THEN p.adjusted_close / 100.0
         WHEN i.currency IN ('USD', 'EUR') THEN p.adjusted_close * f.gbp_per_unit
         ELSE NULL
       END AS price_gbp
FROM `isa-market-risk.isa_market_risk.raw_market_prices` p
LEFT JOIN `isa-market-risk.isa_market_risk.instrument_master` i
  ON p.ticker = i.historical_ticker
LEFT JOIN `isa-market-risk.isa_market_risk.fx_rates_complete` f
  ON p.date = f.date AND i.currency = f.currency;

-- Original check: 27,153 rows, 25,827 prices, 1,326 missing.
SELECT COUNT(*) AS records, COUNT(DISTINCT ticker) AS instruments,
       COUNTIF(price_gbp IS NULL) AS missing_prices,
       COUNTIF(price_gbp IS NOT NULL) AS valid_prices
FROM `isa-market-risk.isa_market_risk.market_prices_gbp`;

-- FX coverage check: non-null source price with missing converted price
-- requires investigation; do not silently forward-fill missing FX.
SELECT date, ticker, currency, adjusted_close
FROM `isa-market-risk.isa_market_risk.market_prices_gbp`
WHERE adjusted_close IS NOT NULL AND price_gbp IS NULL;

-- Per-instrument valid-price returns: consecutive valid observations, NOT
-- guaranteed to be consecutive exchange sessions.
CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.daily_returns` AS
WITH valid_prices AS (
  SELECT date, ticker, price_gbp
  FROM `isa-market-risk.isa_market_risk.market_prices_gbp`
  WHERE price_gbp IS NOT NULL
), previous_prices AS (
  SELECT date, ticker, price_gbp,
         LAG(price_gbp) OVER (PARTITION BY ticker ORDER BY date) AS previous_price,
         LAG(date) OVER (PARTITION BY ticker ORDER BY date) AS previous_date
  FROM valid_prices
)
SELECT date, ticker, price_gbp, previous_price, previous_date,
       DATE_DIFF(date, previous_date, DAY) AS calendar_days_between,
       SAFE_DIVIDE(price_gbp, previous_price) - 1 AS daily_returns
FROM previous_prices;

-- Common calendar, starting GEV's first available observation 2024-03-27.
-- This creates a complete grid, retains original prices and records forward fill.
CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.alligned_market_prices_gbp` AS
WITH portfolio_dates AS (
  SELECT DISTINCT date
  FROM `isa-market-risk.isa_market_risk.market_prices_gbp`
  WHERE date >= DATE '2024-03-27'
), instruments AS (
  SELECT DISTINCT historical_ticker
  FROM `isa-market-risk.isa_market_risk.instrument_master`
), price_grid AS (
  SELECT d.date, i.historical_ticker, p.price_gbp
  FROM portfolio_dates d
  CROSS JOIN instruments i
  LEFT JOIN `isa-market-risk.isa_market_risk.market_prices_gbp` p
    ON p.date = d.date AND p.ticker = i.historical_ticker
), aligned_prices AS (
  SELECT date, historical_ticker, price_gbp,
         LAST_VALUE(price_gbp IGNORE NULLS) OVER (
           PARTITION BY historical_ticker ORDER BY date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
         ) AS aligned_price_gbp
  FROM price_grid
)
SELECT date, historical_ticker, price_gbp, aligned_price_gbp,
       (price_gbp IS NULL AND aligned_price_gbp IS NOT NULL) AS is_forward_filled
FROM aligned_prices;

-- Expect 14,217 rows; original missing 359; forward filled 359; remaining 0.
SELECT COUNT(*) AS total_records,
       COUNTIF(price_gbp IS NULL) AS original_missing,
       COUNTIF(aligned_price_gbp IS NULL) AS remaining_missing,
       COUNTIF(is_forward_filled) AS forward_filled
FROM `isa-market-risk.isa_market_risk.alligned_market_prices_gbp`;

-- Save returns on the shared portfolio valuation calendar.
-- View and return COLUMN both use the user's final 'alligned' spelling here.
CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.alligned_daily_returns` AS
WITH previous_prices AS (
  SELECT date, historical_ticker, aligned_price_gbp, is_forward_filled,
         LAG(aligned_price_gbp) OVER (
           PARTITION BY historical_ticker ORDER BY date
         ) AS previous_aligned_price
  FROM `isa-market-risk.isa_market_risk.alligned_market_prices_gbp`
)
SELECT date, historical_ticker, aligned_price_gbp,
       previous_aligned_price,
       SAFE_DIVIDE(aligned_price_gbp, previous_aligned_price) - 1 AS alligned_return,
       is_forward_filled
FROM previous_prices;

-- Expect 14,217 rows, 21 null returns, 14,196 valid, 359 flagged.
SELECT COUNT(*) AS records, COUNT(DISTINCT historical_ticker) AS tickers,
       COUNTIF(alligned_return IS NULL) AS initial_null_returns,
       COUNTIF(alligned_return IS NOT NULL) AS valid_returns,
       COUNTIF(is_forward_filled) AS forward_filled,
       COUNTIF(is_forward_filled AND ABS(alligned_return) > 0.000001) AS invalid_fill_returns
FROM `isa-market-risk.isa_market_risk.alligned_daily_returns`;
