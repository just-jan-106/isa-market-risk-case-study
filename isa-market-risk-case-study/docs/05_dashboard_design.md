# 05 — Dashboard Design

## Overview

I used Tableau Public to present the results of my ISA portfolio risk analysis.

The workbook contains two dashboards:

1. **ISA Market Risk Overview** — Portfolio composition, instrument-level risk, historical performance, drawdown and correlations.
2. **Benchmark & Risk Analysis** — Performance against the S&P 500, rolling volatility, VaR backtesting, historical stress testing and sensitivity analysis.

The dashboards use results calculated in Google BigQuery and exported into CSV files.

I decided to separate the analysis into two dashboards because they address different aspects of the project. The first focuses on understanding the portfolio itself, while the second examines how it performed relative to the benchmark and how it behaved under historical market stress.

**Published workbook:** [ISA Portfolio Market Risk Analysis](https://public.tableau.com/app/profile/jan.b7461/viz/ISAPortfolioMarketRiskAnalysis/Dashboard1)

## 1. ISA Market Risk Overview

The first dashboard provides an overview of what the portfolio contains, how capital is allocated and where the historical risks originate.

### Portfolio Allocation

**Visualisation:** Treemap

I chose a treemap rather than a bar chart to represent the portfolio holdings visually according to their relative weights.

The size of each rectangle corresponds to the proportion of portfolio value allocated to an instrument. Tickers and instrument categories are displayed to help identify individual positions.

This makes the largest positions immediately visible and provides an overview of the portfolio's concentration.

### Excess Risk Contribution

**Visualisation:** Diverging horizontal bar chart

I chose to display excess risk contribution rather than presenting portfolio weights and volatility contributions together in the same chart.

Excess risk contribution is calculated as:

\[
\text{Excess Risk Contribution}
=
\text{Risk Contribution (\%)}
-
\text{Portfolio Weight (\%)}
\]

Positive values indicate that an instrument contributes a greater percentage of portfolio volatility than its percentage of portfolio value. Negative values indicate the opposite.

The treemap already communicates how much capital is allocated to each instrument. The excess risk contribution chart adds another perspective by showing which instruments contribute disproportionately to the portfolio's volatility.

### Historical Portfolio Value

**Visualisation:** Line chart

The chart displays the simulated historical GBP value of the portfolio.

It allows the changes in portfolio value to be followed over the analysis period and provides context for the drawdown analysis.

The values are based on current quantities applied to historical prices rather than actual historical Trading 212 account balances.

### Historical Drawdown

**Visualisation:** Line chart

The drawdown chart shows the percentage decline from the portfolio's previous historical peak.

I included this alongside the historical portfolio value chart to examine the scale and timing of historical declines.

The chart makes it possible to identify periods when the portfolio experienced sustained losses relative to its earlier peaks.

### Correlation Matrix

**Visualisation:** Heatmap

The correlation matrix displays the pairwise Pearson correlations between the daily GBP-denominated returns of the 21 instruments.

Colour is used to represent the strength and direction of the relationships.

I considered this one of the more useful visualisations because it allows the historical relationships between assets to be examined across the entire portfolio.

### Portfolio Risk Metrics

The dashboard also displays four portfolio-level risk statistics:

| Metric | Result |
|---|---:|
| Annualised volatility | 14.54% |
| Maximum drawdown | −20.79% |
| 95% Expected Shortfall | 2.21% |
| 99% Expected Shortfall | 3.66% |

These provide a numerical summary alongside the holding-level and historical visualisations.

## 2. Benchmark & Risk Analysis

The second dashboard focuses on comparing the simulated portfolio against the S&P 500 benchmark and examining historical risk through additional statistical methods.

### Portfolio vs S&P 500

**Visualisation:** Two-series line chart

The simulated portfolio and VUAG benchmark were indexed to 100 at the beginning of the common analysis period.

This allows their historical relative performance to be compared without relying on the portfolio's monetary value.

I considered this one of the most useful visualisations because a central objective of the project was to compare my combination of ETFs and individual equities with a simpler S&P 500 investment strategy.

### Rolling Volatility

**Visualisation:** Two-series line chart with selectable estimation window

The chart compares rolling annualised volatility for the portfolio and benchmark.

A Tableau parameter allows users to select either:

- 30-observation rolling volatility.
- 90-observation rolling volatility.

I chose to make the estimation window selectable rather than create separate graphs for each calculation.

This reduced the space required on the dashboard while allowing both periods to be examined.

The chart also allows changes in volatility to be compared with periods of historical portfolio drawdown.

### Historical VaR Backtesting

**Visualisation:** VaR threshold line and realised-return marks

The chart compares each realised portfolio return with the corresponding rolling 95% historical VaR threshold.

Returns that breach the threshold are highlighted in a different colour.

The visualisation displays the backtesting results across 426 forecasts, including 23 exceptions.

It provides a way to examine the timing of exceptions rather than relying only on the overall exception rate.

### Historical Stress Loss Attribution

**Visualisation:** Diverging horizontal bar chart with date selection

This chart displays the contributions of individual holdings to the portfolio return on selected historical stress dates.

A dropdown allows the user to choose one of the ten worst portfolio-return dates.

I used an interactive selection rather than displaying separate attribution charts for every stress date.

This keeps the dashboard more compact while allowing the contribution of each instrument to be examined for individual events.

### VaR Sensitivity Analysis

**Visualisation:** Bar chart with reference line

The chart compares the observed 95% historical VaR exception rates for three estimation windows.

| Estimation window | Exception rate |
|---|---:|
| 125 observations | 7.97% |
| 250 observations | 5.98% |
| 375 observations | 5.98% |

A horizontal reference line at 5% represents the nominal exception rate.

All three models were evaluated over the same 301 out-of-sample dates.

This provides a visual comparison of how the estimation-window choice affected the observed backtesting results.

## 3. Design Decisions

### Separating the Analysis

I divided the workbook into two dashboards because I wanted the portfolio overview and the benchmark and stress analysis to remain distinct.

The first dashboard focuses on the assets themselves, their weights, their contribution to risk and the historical behaviour of the portfolio.

The second dashboard focuses on relative performance and the results of the more detailed risk models.

### Choosing Visualisations

One of the main decisions was determining how to present the different data tables.

For portfolio holdings, I preferred a treemap because it provides a visual representation of each instrument's relative stake.

For instrument-level risk, I chose excess risk contribution because it allows users to compare the additional proportion of volatility contributed by each asset relative to its weight, without placing two different sets of percentages on the same chart.

I also used line charts for historical portfolio value, drawdown and volatility because the changes over time were an important part of the analysis.

### Managing Dashboard Space

The most difficult part of building the dashboards was fitting the visualisations together while keeping them readable.

This influenced my decision to separate the workbook into two dashboards and introduce interactive controls.

In particular, allowing users to select volatility estimation windows and historical stress dates meant that multiple analyses could be displayed within the same visualisation rather than requiring additional charts.

## 4. Data Preparation for Tableau

The financial calculations were performed in BigQuery rather than directly in Tableau.

Selected results were exported into CSV files for visualisation.

Separate datasets were prepared for portfolio composition, risk contributions, historical portfolio values, drawdowns, correlations, benchmark performance, rolling volatility, VaR backtesting, stress attribution and sensitivity analysis.

For the sensitivity analysis, the estimation-window field needed to be treated as a discrete category in Tableau. Otherwise, Tableau aggregated the three window values rather than displaying them separately.

Supporting worksheets were hidden from the published workbook navigation, leaving the two main dashboards available to viewers.

## 5. Potential Improvements

### Sector Exposure Analysis

One improvement I would make is adding a sector breakdown of the portfolio.

Although the allocation treemap shows the percentage invested in each instrument, it does not explain how those investments are distributed between economic sectors.

This is particularly relevant because the portfolio includes both ETFs and individual equities, with some of the individual companies already included within the ETFs.

A sector breakdown could help identify where the portfolio has overlapping exposure and whether particular industries account for a disproportionate share of the overall investment allocation.

For a more complete analysis, I would need to account for the underlying sector composition of the ETFs rather than treating each ETF as a single sector.

This was not included in the current version of the dashboards.

## 6. Limitations

The dashboards present the results of a hypothetical fixed-quantity historical portfolio simulation. They do not represent my actual historical Trading 212 account performance.

The displayed results reflect the historical data available at the time of the analysis and do not update automatically.

The correlation matrix measures historical linear relationships rather than causality or future diversification benefits.

The VaR and stress-testing visualisations describe historical outcomes and model estimates, not guaranteed future losses.

Finally, because the workbook is published through Tableau Public, the underlying published data and any downloadable extracts need to be reviewed for privacy and data-licensing restrictions.

The calculations used to create the visualisations are documented in `docs/04_analysis_methods.md` and implemented in the `sql/` directory.
