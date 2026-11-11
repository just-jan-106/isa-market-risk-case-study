
# Market Risk Analysis — Technical Report

## 1. Research Question

This project investigates the historical risk profile of my Stocks & Shares ISA portfolio and compares its performance with a simpler S&P 500 investment strategy.

The portfolio contains 21 instruments: 19 individual equities and two ETFs.

The analysis uses a hypothetical fixed-quantity portfolio constructed from my current holdings and historical GBP-adjusted market prices. It does not represent my actual historical transactions or realised investment returns.

**Analysis period:** 27 March 2024 – 9 November 2026.

## 2. Data Preparation

Historical adjusted prices were collected through Yahoo Finance using Python and pandas.

As the portfolio includes instruments traded in different currencies, prices were converted into GBP before portfolio valuation.

Several data-quality issues were addressed:

- **Currency conversion:** USD, EUR and GBX prices were converted into GBP.
- **Missing FX observation:** A missing historical exchange rate was supplemented using externally verified data rather than an estimated or forward-filled value.
- **Trading calendars:** Missing prices resulting from different exchange trading dates were forward-filled to create a consistent valuation dataset.
- **Historical coverage:** The common analysis period was restricted to March 2024 onwards so all 21 instruments could be included.

The resulting portfolio dataset contained 677 valuation dates and 676 valid daily returns.

Further information is available in [Data Cleaning and Validation](../docs/03_data_cleaning_log.md).

## 3. Historical Performance

The simulated portfolio was compared with Vanguard's S&P 500 UCITS ETF (VUAG.L).

Both series were indexed to 100 at the beginning of the analysis period.

| Metric | Simulated ISA | S&P 500 ETF |
|---|---:|---:|
| Cumulative return | +52.51% | +39.20% |
| Annualised volatility | 14.54% | 13.42% |
| Maximum drawdown | −20.79% | −20.88% |

The portfolio produced a cumulative return 13.31 percentage points higher than the benchmark, alongside higher annualised volatility.

I consider the additional historical return worthwhile relative to the increase in volatility. However, this is an assessment of the historical results rather than evidence that the portfolio will continue to outperform.

The similar maximum drawdowns indicate that the two investments experienced comparable worst peak-to-trough declines during the analysed period.

## 4. Portfolio Concentration and Risk Contributions

The portfolio contains two ETFs, VUAG and VFEG, representing approximately 56.07% of portfolio value.

VUAG alone accounts for approximately 46.06%.

To assess the risk introduced by individual positions, I calculated covariance-based contributions to portfolio volatility.

Excess risk contribution compares an instrument's percentage contribution to volatility with its portfolio weight.

| Instrument | Excess risk contribution |
|---|---:|
| AVGO | +6.65 percentage points |
| VRT | +5.55 percentage points |
| NVDA | +5.03 percentage points |
| VUAG | −14.44 percentage points |

The analysis showed that several individual equities contributed disproportionately to overall volatility.

I expected the individual equities to introduce additional risk, but the results helped identify which positions were most responsible.

Several of these instruments are technology-related companies. Their additional risk may be associated with the portfolio's higher historical returns, although this would require a separate return-attribution analysis to establish.

A full sector analysis, including the underlying holdings within the ETFs, was not completed.

## 5. Downside Risk

The following measures were calculated from the simulated historical portfolio returns.

| Risk measure | Result |
|---|---:|
| Annualised volatility | 14.54% |
| Maximum drawdown | −20.79% |
| Historical 95% daily VaR | 1.393% |
| Historical 95% Expected Shortfall | 2.21% |
| Historical 99% Expected Shortfall | 3.66% |
| Worst daily return | −4.93% |

Volatility measures overall return variability but does not directly quantify the severity of losses.

Historical VaR estimates a loss threshold, while Expected Shortfall measures the average loss within the corresponding lower tail.

Maximum drawdown provides a different perspective by measuring the cumulative decline from a previous portfolio peak.

The largest portfolio drawdown reached its trough on 7 April 2025.

The historical stress analysis also identified 3 April 2025 as the worst individual trading day, with a simulated loss of approximately 4.93%.

These observations suggest that the April 2025 period is worth investigating further to understand the underlying market conditions and the instruments contributing to the decline.

## 6. Benchmark Risk Comparison

Beyond cumulative returns, the portfolio was compared with the S&P 500 benchmark using additional statistics.

| Statistic | Result |
|---|---:|
| Return correlation | 0.794 |
| Portfolio beta | 0.86 |
| Annualised tracking error | Approximately 9.04% |

The portfolio and benchmark had a relatively strong positive historical return correlation.

The estimated beta of 0.86 indicates that the portfolio's historical sensitivity to benchmark returns was below one under the fitted linear relationship.

Tracking error measures the variation in daily return differences between the portfolio and benchmark.

Because VUAG is also a major holding in the portfolio, the benchmark and portfolio are not independent.

These statistics describe the historical relationship between the two series rather than their future behaviour.

## 7. Rolling Volatility

Rolling annualised volatility was calculated using 30- and 90-observation windows.

The maximum recorded 30-observation rolling volatility was approximately 29.24%, compared with the full-period annualised volatility of 14.54%.

This illustrates how a single volatility estimate for the entire sample can hide periods of considerably greater return variability.

I was particularly interested in analysing rolling volatility around periods of drawdown to understand how portfolio risk changed during larger market movements.

The Tableau dashboard allows the 30- and 90-observation windows to be selected interactively.

## 8. Historical VaR Backtesting

The historical VaR model was assessed using rolling, out-of-sample forecasts.

For the main backtest, each 95% one-day VaR forecast used the preceding 250 daily returns.

| Metric | Result |
|---|---:|
| Forecast observations | 426 |
| Exceptions | 23 |
| Expected exception rate | 5.00% |
| Observed exception rate | 5.40% |
| Kupiec test statistic | 0.1394 |
| Christoffersen independence statistic | 2.067 |
| Combined conditional-coverage statistic | 2.206 |

The Kupiec unconditional-coverage test did not reject the nominal exception rate at the 5% significance level.

The Christoffersen independence test also did not find sufficient evidence to reject first-order independence of exceptions.

The combined conditional-coverage test was similarly not rejected.

These results are consistent with the tested model properties in this sample, but they do not prove that the model will remain reliable under different market conditions.

### Estimation-Window Sensitivity

Three historical estimation windows were compared over the same 301 out-of-sample dates.

| Window | Average VaR | Exceptions | Exception rate |
|---|---:|---:|---:|
| 125 observations | 1.300% | 24 | 7.97% |
| 250 observations | 1.377% | 18 | 5.98% |
| 375 observations | 1.374% | 18 | 5.98% |

The shortest estimation window produced the lowest average VaR estimate and the most exceptions.

The longer estimation windows produced slightly higher average VaR forecasts and fewer breaches over the common period.

This demonstrated that the historical observations used to estimate risk affect the behaviour of the model.

The results do not establish that a longer estimation window is always preferable.

## 9. Historical Stress Attribution

The ten worst daily portfolio returns were identified and compared with the benchmark.

For each selected day, I calculated the contribution of all 21 holdings to the overall portfolio return.

The contributions were reconciled to the portfolio's daily return at six decimal places.

This allowed the holdings associated with the largest historical losses to be identified.

A Tableau filter allows users to select a specific stress date and inspect the contribution of each holding.

The analysis measures historical loss attribution. It does not model hypothetical future shocks.

## 10. Limitations

The main limitations are:

- **Fixed-quantity simulation:** The analysis does not reproduce my actual historical trading activity.
- **Historical sample:** The common data period begins in March 2024.
- **Currency movements:** Returns incorporate foreign exchange movements because the portfolio is valued in GBP.
- **Forward filling:** Missing market prices were carried forward when aligning trading dates.
- **Benchmark overlap:** VUAG is both a portfolio holding and the benchmark.
- **Sector exposure:** The analysis does not fully account for the underlying holdings of the ETFs.
- **Risk-model uncertainty:** Historical VaR and Expected Shortfall depend on the observed return distribution.
- **Backtesting:** Failure to reject statistical tests does not guarantee future model performance.

The results should therefore be interpreted as historical evidence about a hypothetical portfolio rather than forecasts or investment recommendations.

## 11. Conclusions and Further Research

The simulated portfolio produced higher cumulative returns than the S&P 500 ETF benchmark over the analysis period, alongside higher annualised volatility.

The risk contribution analysis also showed that several individual equities introduced disproportionate volatility relative to their weights.

I consider the historical performance encouraging, but the analysis raised further questions about the concentration of risk and whether the additional exposure to individual equities was responsible for the portfolio's outperformance.

My main priorities for further research are:

1. **Sector exposure:** Investigate the combined exposure of individual equities and the underlying ETF holdings.
2. **Return attribution:** Quantify how much each holding contributed to the portfolio's historical excess return.
3. **Drawdown investigation:** Examine the market conditions and holdings associated with the April 2025 decline.

The project provided a practical application of financial risk modelling, SQL and data analytics to a portfolio I had previously managed without a detailed quantitative assessment.

---

**Interactive dashboards:** [ISA Portfolio Market Risk Analysis — Tableau Public](https://public.tableau.com/app/profile/jan.b7461/viz/ISAPortfolioMarketRiskAnalysis/Dashboard1)

**Methodology:** [Analysis Methods](../docs/04_analysis_methods.md)

*This report describes a hypothetical historical portfolio simulation, not realised investment performance or financial advice.*
