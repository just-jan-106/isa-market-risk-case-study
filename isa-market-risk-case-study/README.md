# Quantitative Market Risk Assessment — Stocks & Shares ISA

**Status:** Planning | **Case study:** Google Data Analytics Capstone, Track B | **Currency:** GBP (planned)

## Business question
How effectively is an anonymised real Stocks & Shares ISA portfolio diversified, what drives its market risk, and how reliably can historical downside-risk models estimate potential losses?

This project is an independent educational case study, not investment advice. Analysis and results will be added only after they have been calculated and validated.

## Project objectives
1. Evaluate holdings concentration and risk contributions.
2. Calculate volatility, drawdowns and asset correlations from a documented historical window.
3. Estimate and critically assess historical one-day Value at Risk (VaR) and Expected Shortfall (ES).
4. Compare risk with a suitable GBP benchmark and explore stress scenarios, where reliable data allow.
5. Communicate defensible findings in Tableau and a short analyst report.

## Data and privacy
The portfolio composition comes from **private** Trading 212 holdings. Public historical price and FX sources are **to be selected and documented** in [`docs/02_data_sources.md`](docs/02_data_sources.md). Do not upload statements, transaction exports, account IDs, exact account balances, API keys or sensitive source data. Only publish sanitised derived metrics and publicly licensed materials after reviewing redistribution rights and Tableau Public data exposure. The `data/raw_private/` and `data/processed_private/` folders are ignored by Git.

## Workflow / documentation
- [Project status](PROJECT_STATUS.md) — next task, progress and blockers.
- [Research journal](research_journal.md) — important decisions, alternatives and findings.
- [ASK](docs/01_business_task.md) → [PREPARE](docs/02_data_sources.md) → [PROCESS](docs/03_data_cleaning_log.md) → [ANALYZE](docs/04_analysis_methods.md) → [SHARE](docs/05_dashboard_design.md) → [ACT](docs/06_conclusions.md).
- [Technical methods](src/) · [BigQuery SQL](sql/) · [Notebook](notebooks/) · [Dashboard](dashboard/) · [Reports](reports/).

## Methodological safeguards
A *fixed-weight historical simulation using today's holdings* does **not** reproduce actual past ISA performance. Document price adjustments and distributions, historical GBP conversion, trading-calendar alignment, sampling, benchmark comparability, weights/rebalancing assumptions and any model backtesting limitations. Do not label in-sample model checks as out-of-sample backtests.

## Reproduction (to be completed)
1. Choose and cite data sources; record licenses and downloaded file schema.
2. Install dependencies with `pip install -r requirements.txt`.
3. Run ingestion/cleaning and SQL scripts once actual input schemas are agreed.
4. Run analyses, validate checks, and export privacy-safe dashboard data.
5. Publish Tableau dashboard and link findings here.

**No results or dashboard have been created yet.**
