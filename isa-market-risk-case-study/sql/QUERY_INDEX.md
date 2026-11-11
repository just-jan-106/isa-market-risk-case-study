# Query index by analysis question

- Raw quality, missing coverage, duplicate price keys, metadata, quantities: `01_quality_checks.sql`
- FX supplements, GBP currency conversion and row-level return preparation: `02_currency_conversion.sql`
- Portfolio calendar, zero returns on carried prices: `02_currency_conversion.sql`
- Current-quantity historical holding values and changing weights: `03_portfolio_construction.sql`
- HHI and effective holdings: `03_portfolio_construction.sql`
- Drawdown and 95%/99% full-sample VaR and expected shortfall: `04_risk_metrics.sql`
- Instrument volatility, correlation heatmap and current-weight volatility contributions: `04_risk_metrics.sql`
- Tableau KPI row: `04_risk_metrics.sql`
- VUAG indexed comparison, beta, tracking error and benchmark drawdowns: `05_benchmark_comparison.sql`
- 30/90-return rolling volatilities: `05_benchmark_comparison.sql`
- 250-return out-of-sample 95% VaR forecasts and exception flags: `06_var_backtesting.sql`
- Kupiec unconditional coverage and Christoffersen exception independence: `06_var_backtesting.sql`
- 10 worst days and exact single-day 21-holding contribution reconciliation: `07_stress_testing.sql`
- April 2025 two-day arithmetic contributions: `07_stress_testing.sql`
- 125/250/375 historical lookback VaR sensitivity and common-sample comparisons: `08_sensitivity_analysis.sql`

## CSVs used by Tableau (views to export)

| Tableau extract | SQL view |
|---|---|
| `current_portfolio_composition.csv` | `current_portfolio_composition` |
| `current_weight_risk_contributions.csv` | `current_weight_risk_contributions` |
| `portfolio_values.csv` | `portfolio_values` |
| `portfolio_drawdowns.csv` | `portfolio_drawdowns` |
| `correlation_matrix.csv` | `correlation_matrix` |
| `dashboard_kpis.csv` | `dashboard_kpis` |
| `benchmark_comparison.csv` | `benchmark_comparison` (choose desired columns) |
| `rolling_volatilit.csv` | `rolling_volatility` |
| `var_backtest_95.csv` | `var_backtest_95` (multiply returns by 100 for Tableau labels) |
| `stress_loss_attribution.csv` | `stress_loss_attribution` |
| `var_sensitivity_summary.csv` | `var_sensitivity_summary` |

BigQuery tables are the source of truth; CSVs are snapshots for visualisation and are not required to run the SQL pipeline.
