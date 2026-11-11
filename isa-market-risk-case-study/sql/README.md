# BigQuery SQL — ISA Market Risk Analysis

This folder contains the SQL queries used for my ISA portfolio risk analysis.

I used Google BigQuery to prepare historical market data, construct the simulated portfolio and calculate financial risk metrics. The queries are organised in the order of the analysis.

**Google Cloud project:** `isa-market-risk`  
**BigQuery dataset:** `isa_market_risk`  
**SQL dialect:** GoogleSQL

## SQL Files

| File | Purpose |
|---|---|
| `01_quality_checks.sql` | Check missing values, duplicates, instrument information and portfolio quantities |
| `02_currency_conversion.sql` | Convert prices into GBP, incorporate supplementary FX data and align trading dates |
| `03_portfolio_construction.sql` | Calculate historical portfolio values, returns, weights and concentration |
| `04_risk_metrics.sql` | Calculate volatility, drawdowns, correlations, VaR, Expected Shortfall and risk contributions |
| `05_benchmark_comparison.sql` | Compare portfolio performance with VUAG and calculate rolling volatility |
| `06_var_backtesting.sql` | Backtest 95% historical VaR using Kupiec and Christoffersen tests |
| `07_stress_testing.sql` | Identify the worst trading days and calculate individual holding contributions |
| `08_sensitivity_analysis.sql` | Compare VaR estimation windows of 125, 250 and 375 observations |

The scripts are numbered in their intended execution order.

## Required Data

The SQL analysis uses five source tables:

| Table | Contents |
|---|---|
| `raw_market_prices` | Historical adjusted closing prices |
| `instrument_master` | Ticker information, asset type and quotation currency |
| `fx_rates` | Historical foreign exchange rates |
| `fx_supplements` | Supplementary FX observations used to address missing data |
| `portfolio_quantities` | Quantities from my portfolio snapshot |

The source tables need to be loaded into BigQuery before running the analysis.

The original market-price datasets and personal portfolio quantities are not included in the public repository.

## Data Preparation

The market data required several transformations before it could be used for portfolio analysis.

First, I converted the instrument prices into GBP using historical exchange rates. During validation, I found a missing FX observation and supplemented it using historical data verified against an external online source.

I then aligned the different trading calendars and forward-filled missing asset prices where necessary.

The resulting dataset contained:

| Measure | Result |
|---|---:|
| Portfolio instruments | 21 |
| Common trading dates | 677 |
| Aligned instrument-date observations | 14,217 |
| Forward-filled price observations | 359 |
| Missing prices after alignment | 0 |
| Valid daily portfolio returns | 676 |

The common analysis period runs from 27 March 2024 to 9 November 2026.

## Running the SQL

The queries can be run in the Google BigQuery SQL editor.

1. Create the `isa_market_risk` dataset and import the required source tables.
2. Run the SQL files in numerical order, starting with the data-quality checks.
3. Check the outputs before continuing to the next stage.
4. Export the relevant results for visualisation in Tableau.

Some scripts use `CREATE OR REPLACE VIEW`, which updates existing BigQuery views. The code should therefore be reviewed before running it against an existing project.

The SQL has been organised from the original analysis but has not yet been tested as a complete pipeline from the source tables. The results below can be used to check whether the calculations match the original analysis.

## Main Results to Check

| Measure | Expected result |
|---|---:|
| Annualised portfolio volatility | 14.54% |
| Maximum drawdown | −20.79% |
| 95% historical VaR | 1.393% |
| 95% Expected Shortfall | 2.21% |
| Covariance-based portfolio volatility | 15.03% |
| 250-observation VaR backtest | 426 forecasts |
| VaR exceptions | 23 |
| Observed exception rate | 5.40% |
| Kupiec test statistic | 0.1394 |
| Christoffersen independence statistic | 2.067 |

The covariance-based volatility estimate uses the portfolio's current weights, while historical portfolio volatility is calculated from the simulated return series. The two figures are therefore not expected to be identical.

## Notes

The analysis uses a hypothetical fixed-quantity portfolio. Current holding quantities were applied retrospectively to historical prices, so the calculations do not represent my actual historical account performance.

The SQL currently uses the view name `alligned_market_prices_gbp`. I've retained this spelling to remain consistent with the BigQuery analysis.

The VaR backtesting queries use only observations preceding each forecast date to avoid using future returns in the estimation window.

For the full explanation of the financial models, assumptions and limitations, see [Analysis Methods](../docs/04_analysis_methods.md).

The original exploratory quality-check queries are retained in `archive/` for reference.
