# 03 — Data Cleaning and Validation

## Overview

The raw market data needed several transformations before it could be used to calculate portfolio returns and financial risk metrics.

The main challenges were differences in trading currencies, missing price observations, different exchange calendars and incomplete historical coverage for some instruments.

Python was used to download and restructure the data, while SQL in Google BigQuery was used for validation, currency conversion and alignment.

This log records the main issues identified during preparation, the methods used to address them and the checks applied to the resulting datasets.

## 1. Restructuring the Historical Price Data

The historical market prices were downloaded using Python and the `yfinance` library.

The initial price dataset was in wide format, with trading dates as rows and individual instruments as columns.

For analysis in BigQuery, the data was converted into long format using pandas.

The resulting dataset contained three main fields:

| Column | Description |
|---|---|
| `date` | Date of the price observation |
| `ticker` | Instrument identifier |
| `adjusted_close` | Adjusted closing price |

The transformation preserved missing observations rather than removing them immediately. This allowed missing values to be identified and investigated during the subsequent SQL checks.

The imported dataset contained 27,153 date–ticker records across 21 instruments.

**Validation:** SQL queries were used to check record counts, ticker coverage, missing values, non-positive prices and duplicate date–ticker combinations.

**Implementation:** `src/download_prices_long.py` and `sql/01_quality_checks.sql`.

## 2. Checking Historical Data Coverage

Although market prices were requested from 9 November 2021, not every instrument had data available throughout the requested period.

One important limitation was GE Vernova (GEV), which only had independent listed-price history from March 2024.

Because the portfolio simulation required prices for all 21 instruments, the common analysis period was restricted to 27 March 2024 through 9 November 2026.

This resulted in 677 portfolio valuation dates.

The shorter analysis period reduced the amount of historical data available for risk estimation but allowed the portfolio to be assessed using the complete set of selected holdings.

**Validation:** The first and last available price dates were examined for each instrument.

**Implementation:** `sql/01_quality_checks.sql` and `sql/02_currency_conversion.sql`.

## 3. Converting Market Prices into GBP

The portfolio includes instruments traded in different currencies, so the original market prices could not be combined directly.

All prices were converted into GBP before calculating holding values and portfolio returns.

The conversion depended on the quotation currency:

| Original currency | Conversion |
|---|---|
| GBP | No conversion required |
| GBX | Divide by 100 |
| USD | Multiply by GBP per USD |
| EUR | Multiply by GBP per EUR |

Historical exchange rates were prepared separately using Python.

The BigQuery process joined the price data to the corresponding exchange-rate observations using the date and currency.

An additional FX supplements table was included in the recovered SQL workflow to incorporate missing exchange-rate observations.

Missing currency conversions were checked by identifying records where a valid original price existed but the GBP-converted price was null.

The recovered SQL does not automatically forward-fill missing FX rates. Any required supplementary FX observations therefore need to be checked against their sources.

**Validation:** Currency metadata, FX date coverage, duplicate date–currency records and missing converted prices.

**Implementation:** `src/fx_rates.py` and `sql/02_currency_conversion.sql`.

### Handling Missing Foreign Exchange Data

During data validation, I identified a missing historical exchange-rate observation in the Yahoo Finance dataset.

Rather than automatically forward-filling the previous available exchange rate, I decided to supplement the missing observation using historical FX data from an external online source.

The replacement rate was checked against the relevant currency pair and observation date before being added to a supplementary FX table in BigQuery.

This allowed the currency conversion process to use an independently sourced historical observation rather than an estimated value.

The supplementary data was then incorporated into the GBP conversion process, with subsequent checks for missing exchange rates and converted prices.

## 4. Aligning Trading Dates and Missing Prices

The instruments were listed on different stock exchanges, including exchanges in the US, UK and Europe.

As a result, some instruments had missing price observations on dates when other instruments were trading.

This presented a problem when constructing a daily portfolio valuation, because the calculation required a price for each holding on every portfolio date.

To address this, the SQL pipeline created a common date–instrument grid and used the most recent available historical price when the current observation was missing.

This method is known as forward filling.

For each instrument, the aligned price was calculated using the last available non-null observation, without using prices from future dates.

The alignment process produced:

| Metric | Recorded result |
|---|---:|
| Portfolio dates | 677 |
| Instruments | 21 |
| Total aligned records | 14,217 |
| Missing original observations within the aligned grid | 359 |
| Forward-filled observations | 359 |
| Remaining missing aligned prices | 0 |

Forward filling allowed the portfolio to be valued on a consistent calendar.

However, it also introduced an assumption: when an instrument lacked a new price on a portfolio date, its previous price was carried forward.

This can produce a zero return for the affected instrument even when other markets have moved. It does not imply that the instrument's economic value remained unchanged.

**Validation:** Counts of missing and forward-filled records, remaining null prices and returns on forward-filled dates.

**Implementation:** `alligned_market_prices_gbp` in `sql/02_currency_conversion.sql`.

## 5. Calculating Daily Returns

After aligning the historical prices, daily simple returns were calculated using:

\[
r_t = \frac{P_t}{P_{t-1}} - 1
\]

where \(P_t\) is the current aligned GBP price and \(P_{t-1}\) is the previous aligned GBP price.

The calculation used SQL's `LAG()` function to obtain the previous price for each instrument.

The first observation for each instrument has no preceding price and therefore produces a null return.

The aligned dataset contained 14,217 instrument-date records, of which 14,196 had valid instrument returns. The remaining 21 corresponded to the first observation for each instrument.

Portfolio-level returns were calculated separately from successive simulated portfolio values.

The portfolio dataset contained 677 valuation dates and 676 valid daily portfolio returns.

**Validation:** Initial null counts, non-null return counts and consistency between aligned prices and calculated returns.

**Implementation:** `alligned_daily_returns` and the portfolio construction SQL.

## 6. Validating the Portfolio Holdings

The historical portfolio simulation used a snapshot of the quantities held in the Trading 212 account.

The quantity data was linked to the historical market-price records using instrument identifiers.

The SQL validation checks were designed to identify:

- Missing or non-positive holding quantities.
- Duplicate instrument records.
- Instruments without corresponding reference metadata.
- Differences between holdings in the portfolio and instruments in the market-price dataset.

The portfolio contained 21 instruments.

The quantities were held constant throughout the historical simulation, while their market values and portfolio weights changed as prices moved.

This distinction is important because the resulting historical returns do not represent the account's actual transaction history.

**Implementation:** `sql/01_quality_checks.sql` and `sql/03_portfolio_construction.sql`.

## 7. Financial Calculation Checks

After preparing the data, additional checks were applied to the portfolio calculations.

These included confirming that portfolio holding weights summed to 100%, checking that individual risk contributions reconciled with total portfolio risk, and comparing portfolio return calculations with movements in simulated portfolio value.

For the historical stress analysis, the individual holdings' daily return contributions were also checked against the overall portfolio return.

The stress attribution calculations reconciled to the portfolio return at six decimal places in the results reviewed during the analysis.

These checks helped identify inconsistencies between intermediate calculations and final risk metrics.

**Implementation:** Portfolio construction, risk metrics and stress-testing SQL.

## 8. Remaining Limitations

The cleaning process produced a consistent dataset for the financial analysis, but several limitations remain.

**Forward-filled prices:** Carrying forward previous prices may reduce measured daily return variation on dates where some exchanges are closed.

**Currency movements:** The risk metrics reflect GBP-denominated returns, incorporating foreign exchange movements alongside underlying asset-price changes.

**Shorter history:** Requiring complete coverage for 21 holdings restricted the simulation to the period beginning in March 2024.

**Adjusted prices:** The analysis depends on Yahoo Finance's historical price adjustments and the availability of corporate-action information.

**Historical holdings:** Current portfolio quantities were applied retrospectively. The resulting returns and risk metrics describe a hypothetical portfolio rather than actual account performance.

These limitations should be considered when interpreting the results and comparing the portfolio with the benchmark.

## 9. Validation Status

The SQL repository includes queries to reproduce the cleaning and validation checks.

The record counts reported above are based on the results previously recorded during the project. The reorganised SQL scripts have not yet been rerun end-to-end against the live BigQuery dataset.

Before treating the repository as fully reproducible, the recovered SQL should be executed against the original data and its outputs compared with the published results.
