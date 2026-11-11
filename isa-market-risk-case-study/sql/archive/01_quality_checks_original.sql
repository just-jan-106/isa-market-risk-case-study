-- TEMPLATE ONLY. Replace placeholders after agreeing BigQuery tables/columns.
-- Example checks to implement:
-- 1. COUNT(*) and distinct dates / instruments
-- 2. Duplicate (date, instrument_id) checks
-- 3. NULL/invalid adjusted prices and currency values
-- 4. Coverage by instrument and overlapping dates
-- 5. Reconciliation of returns and risk inputs
-- Keep the actual executable queries here once schemas are fixed.

-- Upload Verivifation
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ticker) AS unique_tickers,
    MIN(date) AS earliest_date,
    MAX(date) AS latest_date
FROM `isa_market_risk.isa_market_risk.raw_market_prices`;
-- RESULTS MATCH EXPECTATION

-- Investigate Missing Prices
SELECT
    ticker,
    COUNT(*) AS total_rows,
    COUNT(adjusted_close) AS valid_prices,
    COUNTIF(adjusted_close IS NULL) AS missing_prices,
    MIN(IF(adjusted_close IS NOT NULL, date, NULL))
        AS first_valid_date,
    MAX(IF(adjusted_close IS NOT NULL, date, NULL))
        AS last_valid_date
FROM `isa_market_risk.isa_market_risk.raw_market_prices`
GROUP BY ticker
ORDER BY missing_prices DESC;
-- OULITER VERTIV AT 635 MISSING PRICES AND AIR.PA AT 12. REST FALL IN 30-40 RANGE

-- DUPLICAT ROW INVESTIGATION
SELECT
    date,
    ticker,
    COUNT(*) AS records
FROM `isa_market_risk.isa_market_risk.raw_market_prices`
GROUP BY date, ticker
HAVING COUNT(*) > 1
ORDER BY records DESC;
-- QUERY RETURNED NO ROWS

-- INVALID PRICES
SELECT
    ticker,
    COUNTIF(adjusted_close <= 0) AS non_positive_prices
FROM `isa_market_risk.isa_market_risk.raw_market_prices`
GROUP BY ticker
ORDER BY non_positive_prices DESC;
-- ALL PRICES RETUNRED > 0

-- DUPLICATE ROW ENTRY CHECK
SELECT
  date,
  ticker,
  COUNT(*) AS record_count
FROM `isa-market-risk.isa_market_risk.raw_market_prices`
GROUP BY date, ticker
HAVING record_count > 1;
-- NO DUPLICATE ROWS FOUND

-- ADD CURRENCY INFO USING JOIN
SELECT
  p.date,
  p.ticker,
  p.adjust_close,
  i.currency
FROM `isa-market-risk.isa_market_risk.raw_market_prices` AS p
LEFT JOIN `isa-market-risk.isa_market_risk.instrument_master` AS i
  ON p.ticker = i.historical_ticker

-- CHECK FOR DUPLICATE INSTRUMENT ENTRIES 
SELECT
    historical_ticker,
    COUNT(*) as ticker_count
FROM `isa-market-risk.isa_market_risk.instrument_master`
GROUP BY historical_ticker
HAVING ticker_count > 1;
-- RETURNED NO ENTRIES, MEANING NO DUPLICATE ENTRIES IN INSTRUMENT MASTER

-- CHECK FOR MISSING EXCHANGE RATE VALUES ON STOCKS TRADED IN FOREIGN CURRENCIES
SELECT
  p.date,
  p.ticker,
  p.adjust_close,
  i.currency,
  f.gbp_per_unit AS gbp,
  f.date AS fx_date
FROM `isa-market-risk.isa_market_risk.raw_market_prices` AS p

LEFT JOIN `isa-market-risk.isa_market_risk.instrument_master` AS i
  ON p.ticker = i.historical_ticker

LEFT JOIN `isa-market-risk.isa_market_risk.fx_rates` AS f
  ON i.currency = f.currency
  AND p.date = f.date

WHERE i.currency IN ('USD','EUR')
AND f.gbp_per_unit IS NULL;
-- RESULTS RETURNED 14 MISSING FX VALUES

-- CREATING A VIEW TABLE 
CREATE OR REPLACE VIEW `isa-market-risk.isa_market_risk.fx_rates_complete` AS

SELECT
  date, currency, gbp_per_unit
FROM `isa-market-risk.isa_market_risk.fx_rates`

UNION ALL

SELECT
  date, currency, gbp_per_unit
FROM `isa-market-risk.isa_market_risk.fx_supplements`
-- MERGED RETRIEVED FX RATES DUE TO INCOMPLETE DATA

-- VERIFICATION OF COMPLETE FX DATA
SELECT
  p.date,
  p.ticker,
  p.adjust_close,
  i.currency,
  f.gbp_per_unit,
  f.date AS fx_date
FROM `isa-market-risk.isa_market_risk.raw_market_prices` AS p

LEFT JOIN `isa-market-risk.isa_market_risk.instrument_master` AS i
  ON p.ticker = i.historical_ticker

LEFT JOIN `isa-market-risk.isa_market_risk.fx_rates_complete` AS f
  ON i.currency = f.currency
  AND p.date = f.date

WHERE f.currency IN ("EUR","USD") 
AND f.gbp_per_unit IS NULL;
-- RETURNED NO ROWS

-- APPLYING ROW CONVERSION
SELECT
  p.date,
  p.ticker,
  p.adjust_close,
  i.currency,
  f.gbp_per_unit,
  f.date as fx_date,

  CASE
    WHEN i.currency = "GBP" THEN p.adjust_close * 1
    WHEN i.currency = "GBX" THEN p.adjust_close / 100
    WHEN i.currency = 'USD' THEN p.adjust_close * f.gbp_per_unit
    WHEN i.currency = 'EUR' THEN p.adjust_close * f.gbp_per_unit
    ELSE p.adjust_close
  END AS price_gbp

FROM `isa-market-risk.isa_market_risk.raw_market_prices` AS p

LEFT JOIN `isa-market-risk.isa_market_risk.instrument_master` as i
  ON p.ticker = i.historical_ticker

LEFT JOIN `isa-market-risk.isa_market_risk.fx_rates_complete` AS f
  ON f.currency = i.currency
  AND f.date = p.date
-- PRICE WAS CONVERTED SUCCESSFULLY

-- VERIFYING CALUCLATION DATA
WITH converted_prices AS (
  SELECT
    p.date,
    p.ticker,
    p.adjust_close,
    i.currency,
    f.gbp_per_unit,
    f.date as fx_date,
    CASE
      WHEN i.currency = "GBP" THEN p.adjust_close * 1
      WHEN i.currency = "GBX" THEN p.adjust_close / 100
      WHEN i.currency = 'USD' THEN p.adjust_close * f.gbp_per_unit
      WHEN i.currency = 'EUR' THEN p.adjust_close * f.gbp_per_unit
      ELSE p.adjust_close
    END AS price_gbp,
  

  FROM `isa-market-risk.isa_market_risk.raw_market_prices` AS p

  LEFT JOIN `isa-market-risk.isa_market_risk.instrument_master` as i
    ON p.ticker = i.historical_ticker

  LEFT JOIN `isa-market-risk.isa_market_risk.fx_rates_complete` AS f
    ON f.currency = i.currency
    AND f.date = p.date
)

SELECT
  date,
  ticker,
  currency,
  adjust_close,
  price_gbp,
  ABS(adjust_close - price_gbp) AS difference
FROM converted_prices
WHERE adjust_close IS NOT NULL
  AND price_gbp IS NULL;
-- RESULTS RETURNED NULL FOR ALL CHECKS

-- VERIFY OBSERVATIONAL WINDOWS FOR DIFFERENT INSTRUMENTS
SELECT
  ticker,
  MIN(CASE
      WHEN price_gbp IS NOT NULL THEN date END) AS first_date
FROM `isa-market-risk.isa_market_risk.market_prices_gbp`
GROUP BY ticker;
-- ONE INSTRUMENT HAD A DIFFERENT START DATE

-- CALCULATING DAILY RETURNS
WITH valid_prices AS(
  SELECT
    ticker,
    date,
    price_gbp
  FROM `isa-market-risk.isa_market_risk.market_prices_gbp`
  WHERE price_gbp IS NOT NULL
),
previous_prices AS (
  SELECT
    ticker,
    date,
    price_gbp,

    LAG(price_gbp) OVER (
      PARTITION BY ticker
      ORDER BY date
    ) AS previous_price

  FROM valid_prices
)

SELECT
  date, ticker, price_gbp, previous_price,
  SAFE_DIVIDE(price_gbp, previous_price) - 1 AS daily_return
FROM previous_prices
-- USED FILTERING BEFORE LAG() TO OMIT NULL ENTRIES

-- INVESTIGATING MISSING CALENDAR DAYS
WITH previous_prices AS (
  SELECT
    date,
    ticker,
    price_gbp,
    LAG(price_gbp) OVER (
      PARTITION BY ticker
      ORDER BY date
    ) AS previous_price,
    LAG(date) OVER (
      PARTITION BY ticker
      ORDER BY date
    ) AS previous_date
  FROM `isa-market-risk.isa_market_risk.market_prices_gbp`
  WHERE price_gbp IS NOT NULL
)

SELECT
  date,
  ticker,
  previous_date,
  DATE_DIFF(
    date,
    previous_date,
    DAY
  ) AS calendar_days_between,
  SAFE_DIVIDE(price_gbp, previous_price) - 1 AS daily_return
FROM previous_prices
-- CONSISTENT WITH NATIONAL HOLIDAYS FOR RESPECTIVE EXCHANGES

-- INVESTIGATED EXTREME VALUES
WITH previous_prices AS (
  SELECT
    date,
    ticker,
    price_gbp,
    LAG(price_gbp) OVER (
      PARTITION BY ticker
      ORDER BY date
    ) AS previous_price,
    LAG(date) OVER (
      PARTITION BY ticker
      ORDER BY date
    ) AS previous_date
  FROM `isa-market-risk.isa_market_risk.market_prices_gbp`
  WHERE price_gbp IS NOT NULL
)

SELECT
  MIN(SAFE_DIVIDE(price_gbp, previous_price) - 1) AS min_change,
  MAX(SAFE_DIVIDE(price_gbp, previous_price) - 1) AS max_change,
  COUNTIF((SAFE_DIVIDE(price_gbp, previous_price) - 1) < -1) AS extreme_negative_change
FROM previous_prices
-- NO EXTREME VALUES

-- FORWARD FILLING MISSING DATES

-- STEP 1: Create a CTE containing unique portfolio dates
WITH portfolio_dates AS (
    SELECT DISTINCT
      date
    FROM `isa-market-risk.isa_market_risk.market_prices_gbp`
    WHERE date >= "2024-03-27"
),

-- STEP 2: Create a CTE containing unique instruments
instruments AS (
    SELECT DISTINCT
        historical_ticker
    FROM `isa-market-risk.isa_market_risk.instrument_master`
),

-- STEP 3: Combine every date with every instrument
price_grid AS(
  SELECT
      d.date,
      i.historical_ticker,
      p.price_gbp

  FROM portfolio_dates AS d

  CROSS JOIN instruments AS i

  LEFT JOIN `isa-market-risk.isa_market_risk.market_prices_gbp` AS p
    ON p.ticker = i.historical_ticker
    AND p.date = d.date
)

SELECT
  date,
  historical_ticker,
  price_gbp,

  Last_VALUE(price_gbp IGNORE NULLS) OVER (
    PARTITION BY historical_ticker
    ORDER BY date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS alligned_price_gbp

FROM price_grid

ORDER BY
  historical_ticker,
  date;
-- IN ORDER TO PREVENT MISSING CALCULATIONS

-- CALCULATING DRAWDOWNS
WITH running_peaks AS (
  SELECT
    date,
    portfolio_value,

    MAX(portfolio_value) OVER (
      ORDER BY date
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_peak

  FROM `isa-market-risk.isa_market_risk.portfolio_returns`
),

drawdowns AS (
  SELECT
    date,
    portfolio_value,
    running_peak,

    SAFE_DIVIDE(portfolio_value, running_peak) -1 AS drawdown
  FROM running_peaks
  ORDER BY date
)

SELECT 
  date,
  portfolio_value,
  running_peak,
  drawdown

FROM drawdowns

ORDER BY drawdown ASC

LIMIT 1;
-- MAXXIMUM DRAWDOWN FOUND

-- CALCULATING EXPECTED SHORTFALL
WITH var_threshold AS (
    SELECT DISTINCT
        PERCENTILE_CONT(
            portfolio_return,
            0.05
        ) OVER () AS fifth_percentile
    FROM `isa-market-risk.isa_market_risk.portfolio_returns`
    WHERE portfolio_return IS NOT NULL
)

SELECT
    AVG(p.portfolio_return) AS average_tail_return

FROM `isa-market-risk.isa_market_risk.portfolio_returns` AS p

CROSS JOIN var_threshold AS v

WHERE p.portfolio_return <= -0.013930423171923528;

-- COUNTNING TAIL OBSERVATIONS

WITH var_threshold AS (
    SELECT DISTINCT
        PERCENTILE_CONT(
            portfolio_return,
            0.05
        ) OVER () AS fifth_percentile
    FROM `isa-market-risk.isa_market_risk.portfolio_returns`
    WHERE portfolio_return IS NOT NULL
)

SELECT
    AVG(p.portfolio_return) AS average_tail_return,
    COUNT(*) AS tail_observations

FROM `isa-market-risk.isa_market_risk.portfolio_returns` AS p

CROSS JOIN var_threshold AS v

WHERE p.portfolio_return <= v.fifth_percentile;
-- 35 TAIL OBSERVATIONS RECORDED

-- COMPLETE ES AND VaR CALCULATIONS
WITH valid_returns AS (
    SELECT
        date,
        portfolio_return
    FROM `isa-market-risk.isa_market_risk.portfolio_returns`
    WHERE portfolio_return IS NOT NULL
),

-- Calculate the historical loss thresholds
var_thresholds AS (
    SELECT DISTINCT
        PERCENTILE_CONT(portfolio_return, 0.05) OVER ()
            AS percentile_05,

        PERCENTILE_CONT(portfolio_return, 0.01) OVER ()
            AS percentile_01

    FROM valid_returns
),

-- Calculate VaR, ES and tail observations
risk_metrics AS (
    SELECT
        COUNT(*) AS total_observations,

        -MAX(v.percentile_05) AS var_95,
        -MAX(v.percentile_01) AS var_99,

        -AVG(
            IF(r.portfolio_return <= v.percentile_05,
               r.portfolio_return,
               NULL)
        ) AS es_95,

        -AVG(
            IF(r.portfolio_return <= v.percentile_01,
               r.portfolio_return,
               NULL)
        ) AS es_99,

        COUNTIF(r.portfolio_return <= v.percentile_05)
            AS tail_observations_95,

        COUNTIF(r.portfolio_return <= v.percentile_01)
            AS tail_observations_99

    FROM valid_returns AS r
    CROSS JOIN var_thresholds AS v
),

-- Retrieve the latest simulated portfolio value
latest_value AS (
    SELECT
        portfolio_value
    FROM `isa-market-risk.isa_market_risk.portfolio_values`
    ORDER BY date DESC
    LIMIT 1
)

SELECT
    r.total_observations,
    l.portfolio_value AS latest_portfolio_value_gbp,

    r.var_95,
    r.es_95,
    r.var_99,
    r.es_99,

    r.tail_observations_95,
    r.tail_observations_99,

    r.var_95 * l.portfolio_value AS var_95_gbp,
    r.es_95 * l.portfolio_value AS es_95_gbp,

    r.var_99 * l.portfolio_value AS var_99_gbp,
    r.es_99 * l.portfolio_value AS es_99_gbp

FROM risk_metrics AS r
CROSS JOIN latest_value AS l;
