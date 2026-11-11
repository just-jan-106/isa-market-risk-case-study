# Quantitative Market Risk Assessment of an ISA Portfolio

**A personal portfolio risk analysis using Python, Google BigQuery SQL and Tableau**

**Analysis period:** 27 March 2024 – 9 November 2026  
**Portfolio:** 21 instruments (19 equities, 2 ETFs)  
**Benchmark:** Vanguard S&P 500 UCITS ETF (VUAG.L)

[Explore the Tableau Dashboards](https://public.tableau.com/app/profile/jan.b7461/viz/ISAPortfolioMarketRiskAnalysis/Dashboard1)

---

## 1. Project Background

I started this project as part of the GOOGLE Data Analytics Certificate, where I was required to complete a capstone project demonstrating the skills I had developed.

I have been investing through Trading 212 since I was 18, but I had never carried out a detailed quantitative analysis of my portfolio.

I wanted to use the SQL and data analytics skills I had learned to better understand the historical risk associated with my investments. I also saw this as an opportunity to apply statistical concepts from my mathematics degree to a practical financial problem.

My portfolio contains a combination of ETFs and individual equities, including companies that are already represented within the ETFs.

The main question I wanted to investigate was whether this combination of investments provided a worthwhile difference in historical performance compared with simply buying and holding an S&P 500 ETF, and how much additional risk the individual equities introduced.

## 2. Research Objectives

I structured the analysis around four questions:

1. What is the historical risk profile of my current portfolio allocation?
2. Which instruments contribute disproportionately to portfolio risk?
3. How does the portfolio compare with an S&P 500 buy-and-hold benchmark?
4. How effectively can historical risk models describe potential portfolio losses?

I also wanted to investigate whether the results provided reasons to reconsider aspects of my investment strategy.

The project focuses on historical risk measurement rather than forecasting stock prices or producing investment recommendations.

## 3. Data and Technical Approach

The analysis used three main data sources:

- **Trading 212:** A snapshot of my portfolio holdings and quantities.
- **Yahoo Finance:** Historical adjusted closing prices for the 21 instruments.
- **Historical FX data:** Exchange rates used to convert foreign-currency prices into GBP, including a supplementary observation obtained from an independently verified online source.

I used Python and the `yfinance` library to download market prices, with pandas used to restructure the datasets into a format suitable for BigQuery.

Google BigQuery SQL was then used for currency conversion, trading-date alignment, portfolio construction and financial risk calculations.

The final results were exported into Tableau Public to create two interactive dashboards.

### Data Preparation Challenges

**Different trading currencies**

The portfolio contained instruments traded in USD, EUR, GBP and GBX.

All prices needed to be expressed in GBP before the individual holdings could be combined into a portfolio valuation.

I used historical foreign exchange rates to convert USD- and EUR-denominated prices into GBP. UK-listed instruments quoted in GBX were converted by dividing their prices by 100.

**Missing historical FX data**

One of the data-quality issues I encountered was a missing historical foreign exchange observation in the Yahoo Finance dataset.

I identified the missing observation during the data validation process, when checking whether the currency conversion could be completed for the required dates.

Rather than simply forward-filling the previous exchange rate or estimating a replacement, I decided to find the missing historical rate from an alternative online source.

I checked the supplementary observation against the required currency pair and date before incorporating it into a supplementary FX table in BigQuery.

The supplementary rate was then used in the currency conversion process.

This was an important part of the data preparation because the missing rate needed to be addressed before the affected market prices could be converted consistently into GBP.

It also demonstrated the importance of checking whether a dataset is complete before relying on it for financial calculations.

The exact supplementary rate, observation date and source should be retained in the data-cleaning documentation so the correction can be independently verified.

**Different exchange calendars**

The instruments traded on different exchanges, meaning some dates contained missing price observations for certain holdings.

I used forward filling to carry the most recent available price forward where necessary, allowing the portfolio to be valued on a consistent calendar.

This resolved the missing-price issue for the aligned valuation dataset, although it introduced an assumption that must be considered when interpreting daily returns.

This approach was different from how I handled the missing FX observation, where I obtained supplementary historical data rather than carrying forward the preceding rate.

**Limited historical coverage**

Although I initially requested five years of market data, not every instrument had sufficient price history.

GE Vernova, for example, only had independent listed-price history from March 2024.

To retain all 21 instruments, I restricted the portfolio simulation to the common period from 27 March 2024 to 9 November 2026.

This produced 677 portfolio valuation dates and 676 valid daily returns.

## 4. Portfolio Construction and Risk Modelling

I used the quantities from my portfolio snapshot and applied them to historical GBP-adjusted prices.

This produced a **hypothetical fixed-quantity portfolio**, where the number of shares remained constant but their portfolio weights changed with market prices.

It is important to distinguish this from my actual historical investment performance. The simulation does not reconstruct past transactions, deposits or changes to my holdings.

I used BigQuery SQL to calculate:

- Historical portfolio values and daily returns.
- Annualised volatility and maximum drawdown.
- Instrument correlations and covariance-based risk contributions.
- Historical Value at Risk and Expected Shortfall.
- S&P 500 benchmark performance, beta and tracking error.
- Rolling volatility, VaR backtesting and historical stress attribution.

The complete methodology and formulas are documented in [Analysis Methods](docs/04_analysis_methods.md).

## 5. Main Results

### Portfolio Performance

| Metric | Simulated ISA | S&P 500 ETF |
|---|---:|---:|
| Cumulative return | +52.51% | +39.20% |
| Annualised volatility | 14.54% | 13.42% |
| Maximum drawdown | −20.79% | −20.88% |

The simulated portfolio produced a cumulative return 13.31 percentage points higher than the benchmark over the analysis period, but also had higher annualised volatility.

I consider the additional historical return worthwhile relative to the increase in volatility, particularly because a large proportion of the portfolio was already invested in the S&P 500.

However, this is my assessment of the historical results rather than proof of superior risk-adjusted performance.

The portfolio and benchmark also experienced similar maximum drawdowns.

### Portfolio Concentration and Risk Contributions

Approximately 56% of the portfolio was allocated to the two ETFs, with VUAG accounting for around 46%.

The risk contribution analysis showed that several individual equities contributed a greater percentage of portfolio volatility than their respective portfolio weights.

| Instrument | Excess risk contribution |
|---|---:|
| AVGO | +6.65 percentage points |
| VRT | +5.55 percentage points |
| NVDA | +5.03 percentage points |
| VUAG | −14.44 percentage points |

I expected the additional equities to introduce risk, but this analysis helped me understand which individual positions contributed disproportionately to overall volatility.

Several of the instruments with the highest positive excess risk contributions were technology-related companies.

I suspect these holdings may also have contributed to the higher historical returns. However, a separate return-attribution analysis would be needed to establish how much each holding contributed to the portfolio's performance relative to the benchmark.

This also raised questions about concentration, particularly where individual equities overlap with companies already held through the ETFs.

### Downside Risk

| Metric | Historical result |
|---|---:|
| 95% daily VaR | 1.393% |
| 95% daily Expected Shortfall | 2.21% |
| 99% daily Expected Shortfall | 3.66% |
| Maximum drawdown | −20.79% |
| Worst daily return | −4.93% |

I used VaR and Expected Shortfall alongside volatility because I wanted to quantify downside risk rather than only measuring the overall variability of returns.

VaR estimates a loss threshold, while Expected Shortfall measures the average loss within the corresponding lower tail of the historical return distribution.

The maximum drawdown provided a different perspective by measuring the cumulative decline from an earlier portfolio peak.

The largest drawdown reached its trough in April 2025. I would like to investigate the underlying market conditions further to understand the factors behind this period of losses.

### VaR Backtesting

I evaluated the 95% one-day historical VaR model using a rolling window of 250 preceding returns.

The backtest produced 426 forecasts and 23 exceptions, giving an observed exception rate of 5.40%, compared with the nominal rate of 5%.

The Kupiec unconditional coverage and Christoffersen independence tests did not reject their respective null hypotheses at the 5% significance level.

However, these results do not prove the model's future reliability.

I also compared estimation windows of 125, 250 and 375 observations over the same 301 out-of-sample dates.

| Window | Average VaR | Exception rate |
|---|---:|---:|
| 125 observations | 1.300% | 7.97% |
| 250 observations | 1.377% | 5.98% |
| 375 observations | 1.374% | 5.98% |

The shortest estimation window produced the lowest average VaR forecast and the greatest number of exceptions.

This reinforced my understanding that historical risk estimates depend on the period used to calculate them. Changes in market conditions can affect the reliability of models built from previous observations.

The results do not establish that longer estimation windows are always preferable.

## 6. Tableau Dashboards

I created two dashboards to separate the portfolio overview from the more detailed benchmark and risk-model analysis.

**Dashboard 1 — ISA Market Risk Overview**

This contains portfolio allocation, excess risk contributions, simulated historical value, drawdown, correlations and the main risk statistics.

**Dashboard 2 — Benchmark & Risk Analysis**

This contains the S&P 500 comparison, rolling volatility, historical VaR backtesting, stress-loss attribution and VaR sensitivity analysis.

I used interactive controls for the rolling-volatility windows and historical stress dates to allow multiple analyses to be explored without overcrowding the dashboard.

The published Tableau workbook is available here:

[ISA Portfolio Market Risk Analysis — Tableau Public](https://public.tableau.com/app/profile/jan.b7461/viz/ISAPortfolioMarketRiskAnalysis/Dashboard1)

## 7. What I Learned

The project gave me a better understanding of where the risk in my portfolio comes from and how the combination of ETFs and individual equities affected its historical behaviour.

One of the more useful findings was that the largest capital allocations were not necessarily the instruments contributing disproportionately to volatility.

The benchmark comparison was encouraging, although it also showed that the additional historical return came with higher volatility.

The VaR modelling and backtesting demonstrated the importance of examining how model assumptions and estimation windows influence risk estimates.

From a technical perspective, the project gave me practical experience using Python for data preparation, BigQuery SQL for financial calculations and Tableau for communicating results.

It also involved dealing with actual data-quality problems, including incomplete FX data, mismatched trading calendars and differences in historical price availability.

## 8. Limitations and Future Work

The main limitation is that this is a historical simulation of my current holdings, not a reconstruction of my actual investment history.

Other limitations include the relatively short common data period, forward-filled prices, foreign exchange effects, the overlap between the portfolio and benchmark, and the uncertainty associated with historical risk models.

There are three areas I would investigate further:

**Sector exposure:** Calculate the combined sector allocation of individual equities and the underlying ETF holdings to better understand overlapping exposure.

**Return attribution:** Identify which instruments contributed the most to the portfolio's historical outperformance relative to the S&P 500.

**Drawdown investigation:** Examine the market conditions and individual holdings associated with the April 2025 drawdown.

These extensions would provide a more complete assessment of whether the additional exposure to individual equities has been worthwhile.

---

## Project Resources

- [Interactive Tableau dashboards](https://public.tableau.com/app/profile/jan.b7461/viz/ISAPortfolioMarketRiskAnalysis/Dashboard1)
- [Analysis methodology](docs/04_analysis_methods.md)
- [Data cleaning and validation](docs/03_data_cleaning_log.md)
- [Dashboard design](docs/05_dashboard_design.md)
- [Results and conclusions](docs/06_conclusions.md)

**Note:** All reported portfolio performance figures are based on a hypothetical historical simulation using fixed quantities from a portfolio snapshot. They are not realised Trading 212 account returns or investment recommendations.

**Methodology:** Used a SQL `LEFT JOIN` to associate historical price records with the instrument master through their historical ticker identifiers. Checked for missing currency mappings using `IS NULL`, and tested reference-table uniqueness using `GROUP BY`, `COUNT(*)` and `HAVING`.

**Results:**
- Historical price records: 27,153
- Instruments: 21
- Missing currency mappings: 0
- Duplicate historical tickers in instrument master: 0
- Joined records: 27,153

**Conclusion:** The instrument master provides a complete, unique ticker mapping for the historical price dataset. No unmatched or duplicated instrument identifiers were detected.

**Next step:** Acquire historical exchange-rate data and standardise prices into GBP.
