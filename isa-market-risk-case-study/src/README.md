# Python scripts

The scripts in this folder prepare Yahoo Finance prices and exchange rates for ingestion into BigQuery. The portfolio calculations and risk models are in `../sql/`.

| Script | Purpose | Output in `data/raw_market/` |
| --- | --- | --- |
| `download_prices.py` | Download auto-adjusted daily closing prices for 21 holdings and summarise coverage | `historical_prices.pkl`, `closing_prices.csv`, `coverage_summary.csv` |
| `download_prices_long.py` | Reshape wide stock-price data for BigQuery | `prices_long.csv` |
| `fx_rates.py` | Download USD→GBP and EUR→GBP daily exchange rates | `fx_rates.csv` |

From the repository root, install dependencies and run:

```bash
python -m pip install -r requirements.txt
python src/download_prices.py
python src/download_prices_long.py
python src/fx_rates.py
```

Yahoo Finance's `end` parameter is exclusive, so the scripts request observations up to 9 November 2026. `auto_adjust=True` means the exported `Close` values are already adjusted; they are not raw traded closing prices.

The output files are local working data, excluded from Git by `.gitignore`. `prices_long.csv` uses the columns `date`, `ticker`, `adjusted_close`; `fx_rates.csv` uses `date`, `currency`, `gbp_per_unit`. The SQL pipeline handles currency conversion (including GBP pence quotations), non-trading dates, and forward filling on the shared valuation calendar.

Data availability can change between downloads. Review the coverage report and BigQuery quality checks before recreating results; a new download is not guaranteed to exactly reproduce the original snapshot.
