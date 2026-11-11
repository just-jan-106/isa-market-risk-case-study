# Python Scripts

This folder contains the Python scripts I used to download and prepare historical market prices and foreign exchange rates for the ISA portfolio analysis.

I used `yfinance` to collect the data and `pandas` to organise it before importing the datasets into Google BigQuery.

The portfolio calculations and financial risk models are available in the [`sql/`](../sql/) folder.

## Scripts

| Script | Purpose | Output |
|---|---|---|
| `download_prices.py` | Downloads historical adjusted closing prices for the 21 holdings and checks data coverage | `historical_prices.pkl`, `closing_prices.csv`, `coverage_summary.csv` |
| `download_prices_long.py` | Converts the downloaded prices from wide format into long format for BigQuery | `prices_long.csv` |
| `fx_rates.py` | Downloads historical USD/GBP and EUR/GBP exchange rates | `fx_rates.csv` |

The files are saved locally in `data/raw_market/`.

## Running the Scripts

From the repository root, install the required Python libraries:

```bash
pip install -r requirements.txt
```

Run the scripts in the following order:

```bash
python src/download_prices.py
python src/download_prices_long.py
python src/fx_rates.py
```

The scripts download historical market data covering the requested period from November 2021 to November 2026.

## Data Preparation

The downloaded stock prices use Yahoo Finance's adjusted closing prices, which account for corporate actions such as stock splits and dividends.

The `prices_long.csv` dataset contains three main columns:

| Column | Description |
|---|---|
| `date` | Date of the price observation |
| `ticker` | Stock or ETF ticker |
| `adjusted_close` | Adjusted closing price |

The FX dataset contains:

| Column | Description |
|---|---|
| `date` | Date of the exchange rate |
| `currency` | Original currency |
| `gbp_per_unit` | GBP value of one unit of the currency |

The currency conversion, missing FX data correction and trading-date alignment were handled in BigQuery.

The original downloaded datasets are not included in the public repository. Further details about the data preparation are available in [Data Cleaning and Validation](../docs/03_data_cleaning_log.md).

