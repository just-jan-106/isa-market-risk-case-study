-- 01 | Raw market/reference checks and integrity diagnostics

-- Raw import: expected 27,153 rows, 21 tickers, 2021-11-09..2026-11-09.
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT ticker) AS unique_tickers,
       MIN(date) AS earliest_date, MAX(date) AS latest_date,
       COUNTIF(adjusted_close IS NULL) AS missing_prices,
       COUNTIF(adjusted_close IS NOT NULL) AS valid_prices,
       COUNTIF(adjusted_close <= 0) AS non_positive_prices
FROM `isa-market-risk.isa_market_risk.raw_market_prices`;

-- Unique (date,ticker) rows: expect zero rows.
SELECT date, ticker, COUNT(*) AS record_count
FROM `isa-market-risk.isa_market_risk.raw_market_prices`
GROUP BY date, ticker HAVING COUNT(*) > 1;

-- Instrument coverage and first/last valid historical price.
SELECT ticker, COUNT(*) AS total_records,
       COUNTIF(adjusted_close IS NULL) AS missing_prices,
       MIN(IF(adjusted_close IS NOT NULL, date, NULL)) AS first_valid_date,
       MAX(IF(adjusted_close IS NOT NULL, date, NULL)) AS last_valid_date
FROM `isa-market-risk.isa_market_risk.raw_market_prices`
GROUP BY ticker ORDER BY missing_prices DESC;

-- Verify 21 distinct reference tickers and currency breakdown.
SELECT currency, COUNT(*) AS instrument_count
FROM `isa-market-risk.isa_market_risk.instrument_master`
GROUP BY currency ORDER BY currency;

-- Instrument-master ticker uniqueness: expect zero rows.
SELECT historical_ticker, COUNT(*) AS ticker_count
FROM `isa-market-risk.isa_market_risk.instrument_master`
GROUP BY historical_ticker HAVING COUNT(*) > 1;

-- Find raw tickers without metadata; expect zero rows.
SELECT DISTINCT p.ticker
FROM `isa-market-risk.isa_market_risk.raw_market_prices` p
LEFT JOIN `isa-market-risk.isa_market_risk.instrument_master` i
  ON p.ticker = i.historical_ticker
WHERE i.historical_ticker IS NULL;

-- Verify that each portfolio ticker maps to a reference instrument.
SELECT q.historical_ticker
FROM `isa-market-risk.isa_market_risk.portfolio_quantities` q
LEFT JOIN `isa-market-risk.isa_market_risk.instrument_master` i
  ON q.historical_ticker = i.historical_ticker
WHERE i.historical_ticker IS NULL;

-- Quantity structure and invalid holdings; expected 21 distinct, all positive.
SELECT COUNT(*) AS records, COUNT(DISTINCT historical_ticker) AS tickers,
       COUNTIF(quantity_owned IS NULL) AS missing_quantities,
       COUNTIF(quantity_owned <= 0) AS non_positive_quantities
FROM `isa-market-risk.isa_market_risk.portfolio_quantities`;

-- Base FX-key duplicates; expect zero rows.
SELECT date, currency, COUNT(*) AS n
FROM `isa-market-risk.isa_market_risk.fx_rates`
GROUP BY date, currency HAVING COUNT(*) > 1;
