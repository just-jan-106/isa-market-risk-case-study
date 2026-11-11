# Tableau Dashboards

I used Tableau Public to visualise the results of my ISA portfolio risk analysis.

The workbook contains two dashboards, each focusing on a different part of the analysis.

**[View the interactive Tableau dashboards](https://public.tableau.com/app/profile/jan.b7461/viz/ISAPortfolioMarketRiskAnalysis/Dashboard1)**

## 1. ISA Market Risk Overview

The first dashboard focuses on the portfolio itself, including:

- Portfolio allocation across 21 instruments
- Individual holdings' contributions to portfolio risk
- Simulated historical portfolio value
- Historical drawdowns
- Correlations between instruments
- Summary risk metrics

## 2. Benchmark & Risk Analysis

The second dashboard compares the portfolio with the S&P 500 benchmark and examines its historical risk.

It includes:

- Indexed portfolio performance against VUAG
- Rolling volatility with selectable 30- and 90-observation windows
- Historical 95% VaR backtesting and highlighted exceptions
- Individual holding contributions during the ten worst trading days
- VaR sensitivity analysis using 125-, 250- and 375-observation estimation windows

## Data and Calculations

The financial calculations were completed in Google BigQuery SQL, with the results exported to Tableau for visualisation.

The dashboards use historical data from 27 March 2024 to 9 November 2026.

The displayed portfolio performance is based on a hypothetical simulation using current holding quantities rather than my actual historical investment returns.

For further details, see [Dashboard Design](../docs/05_dashboard_design.md).
