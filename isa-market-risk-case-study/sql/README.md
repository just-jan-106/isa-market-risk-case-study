# BigQuery SQL — recovered analysis pipeline

This directory contains **eight ordered SQL scripts** reconstructed from the project conversation (November 2026), plus `archive/01_quality_checks_original.sql` copied *unchanged* from the user's original repository.

**Project:** `isa-market-risk`  
**Dataset:** `isa_market_risk`  
**Dialect:** GoogleSQL / BigQuery Standard SQL

## What was recovered, and what was repaired

The `CREATE OR REPLACE VIEW` definitions for the main risk, benchmark, VaR backtesting, stress and sensitivity models were recovered from the SQL supplied throughout the conversation. Smaller exploratory calculations were recovered from the existing `01_quality_checks.sql` and from the same conversation. They were consolidated into the files below.

This is a **reconstruction, not a byte-for-byte extraction from BigQuery**. The scripts have been cleaned for consistent project identifiers, corrected column names (`adjusted_close`), CTE aliases and declared dependencies. Additional read-only validation queries have been included; some missing upstream view definitions were recreated based on the saved SQL and the established workflow. The reconstructed scripts have **not** been executed against the user's live BigQuery account. Compare the table schemas before replacing any functioning views.

## Run order and dependencies

| Order | File | Key outputs |
|---|---|---|
| 01 | `01_quality_checks.sql` | Read-only checks on raw data, instrument metadata, quantities |
| 02 | `02_currency_conversion.sql` | `fx_rates_complete`, `market_prices_gbp`, `daily_returns`, `alligned_market_prices_gbp`, `alligned_daily_returns` |
| 03 | `03_portfolio_construction.sql` | `portfolio_values`, `portfolio_returns`, `portfolio_weights_history`, `current_portfolio_composition`, `portfolio_concentration` |
| 04 | `04_risk_metrics.sql` | `portfolio_drawdowns`, `portfolio_risk_metrics`, `correlation_matrix`, `instrument_volatility`, `current_weight_risk_contributions`, `dashboard_kpis` |
| 05 | `05_benchmark_comparison.sql` | `benchmark_comparison`, `benchmark_risk_comparison`, `benchmark_drawdowns`, `rolling_volatility` |
| 06 | `06_var_backtesting.sql` | `var_backtest_95`, `kupiec_pof_test`, `christoffersen_independence_test` |
| 07 | `07_stress_testing.sql` | `stress_test_daily_returns`, `stress_loss_attribution` |
| 08 | `08_sensitivity_analysis.sql` | `var_sensitivity`, `var_sensitivity_summary` |

**Pre-existing BigQuery tables needed** (not created by this folder):

- `raw_market_prices`: `date DATE`, `ticker STRING`, `adjusted_close FLOAT64`
- `instrument_master`: `historical_ticker`, `instrument_name`, `currency`, `asset_type`
- `fx_rates`: `date`, `currency`, `gbp_per_unit`
- `fx_supplements`: `date`, `currency`, `gbp_per_unit` — Yahoo FX gap supplements, as in the original exploratory script
- `portfolio_quantities`: `historical_ticker`, `quantity_owned` — **private source table, not included in public repository**

You must import source/reference tables before running the scripts. In the BigQuery editor, scripts can contain multiple semicolon-terminated statements. `CREATE OR REPLACE VIEW` will overwrite existing view definitions of the same name; review the SQL before using it in your live project.

## Spelling/column convention — verify this before executing

The user expressly named the saved price view **`alligned_market_prices_gbp`** (double `l`) and the final stress-test SQL used the column `aligned_price_gbp`. The code in this recovery uses:

- `alligned_market_prices_gbp` (**view name**)
- `aligned_price_gbp` (**GBP-aligned price column**)
- `alligned_daily_returns` (**view name**)
- `alligned_return` (**individual aligned-return column**)
- `portfolio_return` (**portfolio-level return column**)

Some earlier conversation queries used the correctly spelled `aligned_daily_returns` and `aligned_return`. **This live name has not been verified independently**: open the BigQuery Schema panel and confirm. If the live return view/column is actually `aligned_daily_returns`/`aligned_return`, replace occurrences in `04_risk_metrics.sql` (and, if appropriate, `02_currency_conversion.sql`) consistently. Renaming can invalidate dashboard sources or dependent views; avoid replacing an existing view without confirming the current schema.

## Important modelling cautions

- Current quantities applied to historical **Yahoo auto-adjusted** prices give a **hypothetical adjusted-value fixed-quantity proxy**, *not* actual historical account performance or a literal no-trades share count across dividends and splits.
- FX conversion multiplies USD/EUR source prices by GBP per unit, and divides GBX prices by 100. Exchange closing-time and dividend FX conventions differ.
- Forward filling 359 GBP price gaps is a portfolio **valuation convention**. Not every gap was independently proven to be an exchange holiday. Original values and flags are retained.
- The common sample starts `2024-03-27` because GEV's history starts later; expected 677 valuation dates.
- VUAG is already a major portfolio holding. The benchmark is useful but **not independent**.
- `current_weight_risk_contributions` is a covariance decomposition at **current static weights**. Its ~15.03% implied annualised volatility need not equal the 14.54% empirical volatility of the historically drifting fixed-quantity portfolio.
- The 95% historical VaR backtest uses 250 *previous* returns, not the tested return. The Kupiec and Christoffersen tests have limited power, especially with few exceptions.
- Use validated, permission-appropriate exports only; don't commit personal accounts, full holdings quantities or redistributable third-party market-price datasets without a rights review.

## Expected reconciliation checkpoints from the conversation

| Metric | Expected |
|---|---:|
| Raw rows / raw valid / raw missing | 27,153 / 25,827 / 1,326 |
| Common price-grid observations | 14,217 = 677 dates × 21 tickers |
| Forward-filled prices | 359 |
| Missing prices after alignment | 0 |
| Valid aligned instrument returns | 14,196 |
| Portfolio valuations / valid returns | 677 / 676 |
| Latest simulated GBP portfolio value | ~188.838514 |
| Sample annualised portfolio volatility | ~0.14542267 |
| Max portfolio drawdown | ~-0.20786751 |
| 95% VaR / ES | ~0.01393042 / ~0.02205053 |
| 99% VaR / ES | ~0.02366132 / ~0.03657138 |
| Current-weight risk contribution sum | ~1.000000 |
| Current-weight implied annualised volatility | ~0.15030174 |
| 250-return VaR backtest observations / exceptions | 426 / 23 |
| Kupiec LR / independence LR | ~0.1394 / ~2.067 |
| Stress attribution | 10 dates × 21 holdings; zero reconciliation gap |
| Sensitivity: 125/250/375 windows | 301 observations each; exceptions 24/18/18 |

**Do not force matches:** if actual results differ, investigate changed source data, table schema, corporate-action/FX assumptions and look-ahead logic.

## Original work

`archive/01_quality_checks_original.sql` is the exact file supplied in `Project.zip`, including typos, draft statements and historical commentary. It is provided for audit history and **should not be executed without review**.
