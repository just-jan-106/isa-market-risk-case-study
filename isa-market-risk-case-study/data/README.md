# Data

This folder contains sample results and information about the datasets used in my ISA portfolio risk analysis.

I used historical market prices, foreign exchange rates and a snapshot of my Trading 212 portfolio holdings to calculate portfolio performance and financial risk.

## Folder Contents

| Folder | Description |
|---|---|
| `public_sample/` | Summary results from the portfolio risk analysis |
| `raw_market/` | Local folder used to store downloaded market prices and exchange rates |

The `public_sample/` folder contains two CSV files:

- `portfolio_risk_summary.csv` — Portfolio volatility, drawdown, VaR and Expected Shortfall results.
- `var_sensitivity_summary.csv` — Results comparing the 125-, 250- and 375-observation historical VaR models.

## Data Sources

The analysis used three main sources:

| Source | Data |
|---|---|
| Trading 212 | Portfolio holdings and quantities |
| Yahoo Finance | Historical adjusted stock and ETF prices |
| Historical FX data | Exchange rates used to convert prices into GBP |

Historical market data was collected using Python and prepared for analysis in Google BigQuery.

## Data Preparation

The original data required several transformations before the financial calculations could be performed.

The main steps were:

1. Download historical adjusted prices for the 21 instruments.
2. Download USD/GBP and EUR/GBP exchange rates.
3. Supplement a missing historical FX observation using verified data from an external source.
4. Convert all instrument prices into GBP.
5. Align trading dates across different exchanges and forward-fill missing asset prices.
6. Construct the historical portfolio and calculate its risk metrics in BigQuery.

The final analysis covered 677 trading dates between 27 March 2024 and 9 November 2026.

Further information about the preparation process is available in [Data Cleaning and Validation](../docs/03_data_cleaning_log.md).

## Original Datasets

The original Yahoo Finance downloads and my personal portfolio quantities are not included in this public repository.

The market data has redistribution restrictions, while the portfolio data contains information about my personal holdings.

The Python scripts used to collect the data are available in [`src/`](../src/), and the SQL queries used for the analysis are available in [`sql/`](../sql/).

The two public CSV files contain summary results rather than the complete datasets needed to reproduce the analysis.
