# 02 — Data Sources

## Data Overview

The analysis uses three main sources of data: my Trading 212 portfolio holdings, historical market prices and historical foreign exchange rates.

The portfolio holdings determine which assets are included in the analysis and their quantities. Market prices and exchange rates are used to estimate the historical value of these holdings in GBP.

Python was used to download and prepare the market data before loading it into Google BigQuery for analysis.

## 1. Portfolio Holdings — Trading 212

**Source:** Personal Trading 212 Stocks & Shares ISA portfolio

The portfolio contains 21 instruments, consisting of 19 individual equities and two ETFs.

The ETFs are:

- VUAG — Vanguard S&P 500 UCITS ETF
- VFEG — Vanguard FTSE Emerging Markets UCITS ETF

The remaining holdings consist of individual equities listed across different exchanges, including the US, UK and France.

The portfolio snapshot provides the quantities required to calculate each holding's value and its contribution to the overall portfolio.

For privacy reasons, the original account information, exact holding quantities and monetary values are not included in the public repository.

## 2. Historical Market Prices — Yahoo Finance

**Source:** [Yahoo Finance](https://finance.yahoo.com/)

**Python library:** [yfinance](https://github.com/ranaroussi/yfinance)

**Requested period:** 9 November 2021 – 9 November 2026

Historical daily prices were downloaded for all 21 instruments using Python and the `yfinance` library.

The download uses `auto_adjust=True`, meaning the closing prices are adjusted for corporate actions such as stock splits and dividends using Yahoo Finance's adjustment data.

The main fields prepared for BigQuery were:

| Field | Description |
|---|---|
| `date` | Trading date |
| `ticker` | Instrument identifier |
| `adjusted_close` | Adjusted closing market price |

The Python scripts used were:

- `src/download_prices.py` — Downloads historical prices and produces a coverage summary.
- `src/download_prices_long.py` — Restructures the price data into long format for BigQuery.

Not every instrument had data available throughout the full requested period.

In particular, GE Vernova (GEV) only had independent listed-price history from March 2024. As the analysis required complete price coverage for all 21 holdings, the common portfolio analysis period began on 27 March 2024.

The resulting historical portfolio dataset contained 677 trading dates, ending on 9 November 2026.

## 3. Foreign Exchange Rates

**Source:** Yahoo Finance

**Python script:** `src/fx_rates.py`

As the portfolio contains instruments traded in different currencies, the market prices needed to be expressed in GBP before calculating portfolio values.

Historical exchange rates were obtained for:

| Currency | Yahoo Finance ticker | Purpose |
|---|---|---|
| USD | `GBP=X` | Convert US dollar-denominated prices to GBP |
| EUR | `EURGBP=X` | Convert euro-denominated prices to GBP |

The exchange-rate data was prepared using the following fields:

| Field | Description |
|---|---|
| `date` | Date of the FX observation |
| `currency` | Currency being converted |
| `gbp_per_unit` | GBP value of one unit of the foreign currency |

UK-listed instruments quoted in GBX (pence sterling) were converted into GBP by dividing their quoted prices by 100.

All portfolio valuation calculations were subsequently performed in GBP.

## 4. Benchmark Data

**Benchmark:** Vanguard S&P 500 UCITS ETF (VUAG.L)

VUAG was selected as the benchmark because the project aimed to compare my portfolio against a simpler S&P 500 investment strategy.

Its historical prices were obtained through the same Yahoo Finance data collection process as the other instruments.

The portfolio and benchmark were compared over the same set of trading dates, using indexed values to measure their relative historical performance.

VUAG is also one of the holdings in my portfolio. Consequently, the benchmark is not independent of the portfolio being evaluated.

## 5. Data Storage and Processing

Google BigQuery was used to store and process the datasets.

**Google Cloud project:** `isa-market-risk`

**BigQuery dataset:** `isa_market_risk`

The initial market-price data was stored in `raw_market_prices`. Additional tables and views were created to perform currency conversion, align trading dates, calculate portfolio values and conduct financial risk analysis.

The SQL scripts used for these calculations are available in the `sql/` directory.

The main processing workflow was:

1. Download historical market prices and exchange rates using Python.
2. Restructure the downloaded data into tabular formats suitable for BigQuery.
3. Convert prices into GBP and align the historical observations.
4. Apply the portfolio quantities to construct a hypothetical historical portfolio.
5. Calculate portfolio returns and risk statistics.
6. Export selected results for visualisation in Tableau.

## 6. Data Limitations

Several limitations need to be considered when interpreting the analysis.

**Historical simulation:** The analysis applies a snapshot of current portfolio quantities to historical market prices. It does not reconstruct the actual transactions or cash flows of my Trading 212 account.

**Limited common history:** Although prices were requested from November 2021, the analysis period was restricted by the availability of data for the most recently listed instruments.

**Market data adjustments:** Adjusted prices depend on the information and adjustment methodology provided by Yahoo Finance.

**Currency conversion:** Converting investments into GBP introduces exchange-rate movements into the estimated portfolio returns and risk.

**Benchmark overlap:** VUAG is both the benchmark and a significant portfolio holding, so comparisons are not between independent investments.

**Data availability:** The downloaded market data and exchange rates are not redistributed through the public GitHub repository because of data-licensing considerations.

The project therefore provides a historical assessment of the selected holdings and allocation, rather than a record of realised account performance.