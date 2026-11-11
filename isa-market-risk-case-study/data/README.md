# Data

The analysis uses historical market prices, currency conversion data and a snapshot of portfolio quantities. The full working datasets are **not included** in this public repository.

## Folder contents

- `public_sample/` — two small aggregate extracts supporting the published analysis. These are outputs, not inputs required to run the SQL pipeline.
- `raw_market/` — local working directory created by the Python scripts. Its contents are ignored by Git.

## Data flow

1. `src/download_prices.py` downloads auto-adjusted prices and coverage information.
2. `src/download_prices_long.py` reshapes prices to the columns `date`, `ticker`, `adjusted_close`.
3. `src/fx_rates.py` prepares FX observations as `date`, `currency`, `gbp_per_unit`.
4. The files are loaded to BigQuery; the queries in `sql/` prepare GBP prices, historical portfolio values and risk statistics.
5. Selected BigQuery results were exported as CSVs for Tableau.

The historical portfolio calculation applies a snapshot of quantities to earlier adjusted prices; it is a **hypothetical fixed-quantity simulation**, not realised Trading 212 account performance.

## Files not published

The local working set includes price and FX downloads, intermediate tables, account quantities, exact holding values and detailed Tableau extracts. These are excluded because of account privacy and potential third-party data redistribution restrictions. The source of truth for model calculations is the BigQuery pipeline, not the public CSV samples.

Data access and date coverage may change between Yahoo Finance downloads; a fresh run can differ from the original analysis snapshot. The published dashboard itself may display more holdings-level detail than these sample files, so review Tableau Public visibility separately.
