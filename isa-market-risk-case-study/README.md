# Quantitative Market Risk Assessment — Stocks & Shares ISA

**Independent financial risk / data analytics case study** · Python · pandas · Google BigQuery SQL · Tableau Public · GBP

## Research question
How diversified is a 21-instrument Stocks & Shares ISA portfolio, what drives concentration and downside market risk, and how robust are historical risk forecasts?

## Overview
An anonymised current holdings snapshot was applied to historical GBP-adjusted market prices to construct a **hypothetical fixed-quantity historical simulation**. This is **not** the actual trading history or realised account performance. Analysis includes historical volatility, drawdown, correlation, variance risk attribution, historical VaR/Expected Shortfall, benchmark comparisons, rolling volatility, out-of-sample VaR backtesting and stress-day attribution.

## Selected findings
| Measure | Result |
| Holdings | 21 (2 ETFs, 19 equities) |
| Simulated cumulative portfolio return | 52.51% |
| S&P 500 ETF benchmark cumulative return | 39.20% |
| Portfolio annualised volatility | 14.54% |
| Maximum drawdown | -20.79% |
| Rolling 95% VaR backtest | 23 exceptions / 426 days = 5.40% |
| Kupiec coverage statistic | 0.1394 (do not reject at 5%) |
| Christoffersen independence statistic | 2.067 (do not reject at 5%) |

Over the common 301-day sensitivity evaluation period, 125-observation VaR produced 24 exceptions (7.97%); 250- and 375-observation variants each produced 18 (5.98%). These results are descriptive and do not establish future performance or model reliability under every regime.

## Tableau dashboards
[View the published Tableau Public workbook](https://public.tableau.com/app/profile/jan.b7461/viz/ISAPortfolioMarketRiskAnalysis/Dashboard1), containing:
- **ISA Market Risk Overview** — allocation, risk contributions, value simulation, drawdown and correlations
- **Benchmark & Risk Analysis** — relative performance, rolling volatility, VaR breaches, stress attribution and sensitivity

## Structure
- `src/` — Python data preparation scripts
- `sql/` — query archive and analysis-specific SQL files (see SQL recovery status below)
- `docs/` — Google Data Analytics case-study phases: ASK, PREPARE, PROCESS, ANALYSE, SHARE, ACT
- `reports/` — executive summary and technical analysis
- `dashboard/` — Tableau link and reporting notes
- `tests/` — intended validation tests
- `research_journal.md` — chronological research log

## Reproducibility status (important)
The historical analyses ran in Google BigQuery, but **not all view creation statements are present in this archive**. The analytical SQL files `02`–`08` are recovery checklists, not executable pipelines. Export the verified BigQuery view definitions into those files before claiming a full reproducible run. The legacy `sql/01_quality_checks.sql` requires identifier review. Source datasets are intentionally excluded from this GitHub-ready archive for privacy and redistribution reasons. See [`sql/README.md`](sql/README.md) and [`data/README.md`](data/README.md).

## Local setup
```bash
python -m pip install -r requirements.txt
```
Data acquisition requires an internet connection and market-data provider availability; check the documented data licensing and rate limits. Input CSV schemas and paths must be configured before rerunning scripts.

## Limitations
This is an educational historical simulation, not financial advice. Current portfolio quantities were held fixed retrospectively, benchmark exposures differ from the portfolio, and past distributions are not guaranteed to repeat. Historical price adjustment, GBP conversion and market calendar alignment affect estimates. Statistical non-rejection does not prove VaR model validity. Tableau Public extracts can expose underlying datasets; review them before publishing.
