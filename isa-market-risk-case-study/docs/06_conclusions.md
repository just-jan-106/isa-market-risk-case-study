# 06 — Results and Conclusions

## 1. Overview

The objective of this project was to investigate the historical risk profile of my ISA portfolio and compare its performance with a simpler S&P 500 investment strategy.

The analysis covered 21 instruments over 677 trading dates, from 27 March 2024 to 9 November 2026.

The portfolio was simulated using current holding quantities applied retrospectively to historical market prices. The results therefore represent hypothetical historical performance rather than my actual investment returns.

The main areas investigated were portfolio concentration, individual risk contributions, historical performance, downside risk and the reliability of historical VaR estimates.

## 2. Portfolio Performance Against the S&P 500

The simulated portfolio was compared with the Vanguard S&P 500 UCITS ETF (VUAG.L).

Both series were indexed to 100 at the beginning of the analysis period.

| Metric | ISA Portfolio | S&P 500 ETF |
|---|---:|---:|
| Cumulative return | 52.51% | 39.20% |
| Annualised volatility | 14.54% | 13.42% |
| Maximum drawdown | −20.79% | −20.88% |

The simulated portfolio returned 13.31 percentage points more than the benchmark over the historical period.

I consider this a good result relative to the additional volatility of the portfolio, particularly because a large proportion of my holdings are already invested in the S&P 500 through VUAG.

Based on this period, I would consider the higher historical return a worthwhile trade-off for the increased volatility.

However, this is a personal assessment of the observed results. The analysis does not establish that the portfolio delivered superior risk-adjusted performance or that the same trade-off would be worthwhile in future market conditions.

The similar maximum drawdowns also show that the difference in annualised volatility did not translate into a substantially different worst peak-to-trough decline over this particular period.

## 3. Portfolio Concentration and Risk Contributions

The portfolio contained 19 individual equities and two ETFs.

VUAG represented approximately 46.06% of portfolio value, while VFEG represented approximately 10.01%.

Together, the ETFs accounted for approximately 56.07% of the portfolio.

The analysis showed that several individual equities contributed disproportionately to portfolio volatility relative to their weights.

| Instrument | Excess risk contribution |
|---|---:|
| AVGO | +6.65 percentage points |
| VRT | +5.55 percentage points |
| NVDA | +5.03 percentage points |
| VUAG | −14.44 percentage points |

I expected the individual equities to introduce additional risk. However, the analysis helped me understand which instruments contributed the most risk relative to the amount of capital allocated to them.

One observation was that several of the holdings with the highest positive excess risk contributions were concentrated in technology-related businesses.

I think these investments may also have contributed to the portfolio's higher historical growth, although the risk contribution calculation alone cannot establish this. A separate return-attribution analysis would be needed to measure how much each holding contributed to the portfolio's outperformance.

I also recognise that the same exposure could increase losses during periods when these companies or their sectors perform poorly.

This makes the concentration of risk in individual equities an important consideration when evaluating the portfolio.

The current analysis did not include a complete look-through of the ETFs' underlying holdings, so I cannot yet quantify the total overlap or combined sector exposure.

## 4. Historical Losses and Downside Risk

The main portfolio risk results were:

| Metric | Result |
|---|---:|
| Annualised volatility | 14.54% |
| Maximum drawdown | −20.79% |
| Historical 95% VaR | 1.393% |
| Historical 95% Expected Shortfall | 2.21% |
| Historical 99% Expected Shortfall | 3.66% |

The maximum drawdown reached its trough on 7 April 2025.

The VaR and Expected Shortfall estimates provided a different perspective from the maximum drawdown.

VaR estimates a daily loss threshold, while Expected Shortfall measures the average loss within the corresponding worst tail of the historical return distribution.

Maximum drawdown instead captures the cumulative decline from an earlier portfolio peak.

These measures helped me understand that daily downside risk and sustained portfolio losses should be investigated separately.

The maximum drawdown was particularly interesting because I would like to investigate the underlying market conditions and the individual holdings that contributed to that decline.

Although the stress attribution analysis identifies which instruments contributed to the worst daily losses, it does not fully explain the economic or market events behind the entire drawdown.

I would therefore consider further analysis of the April 2025 decline a useful extension of this project.

## 5. VaR Backtesting and Model Reliability

The 95% historical VaR model was backtested using the preceding 250 observations for each forecast.

| Metric | Result |
|---|---:|
| Forecast observations | 426 |
| Recorded exceptions | 23 |
| Observed exception rate | 5.40% |
| Expected exception rate | 5.00% |
| Kupiec test statistic | 0.1394 |
| Christoffersen independence statistic | 2.067 |
| Combined conditional-coverage statistic | 2.206 |

At the 5% significance level, the statistical tests did not reject their respective null hypotheses.

The observed exception rate was also relatively close to the nominal 5% rate.

However, I recognise that these results do not prove the model will be reliable in different market conditions.

Historical risk models depend on the observations used to estimate them. Market news, economic developments and periods of increased volatility can change the behaviour of returns, which may affect the accuracy of historical estimates.

### VaR Sensitivity Analysis

To investigate the importance of the estimation window, I compared three historical VaR models over the same 301 out-of-sample dates.

| Window | Average VaR | Exceptions | Exception rate |
|---|---:|---:|---:|
| 125 observations | 1.300% | 24 | 7.97% |
| 250 observations | 1.377% | 18 | 5.98% |
| 375 observations | 1.374% | 18 | 5.98% |

The 125-observation model produced the lowest average VaR estimate and the most exceptions.

The longer-window models produced slightly higher average loss thresholds and fewer breaches during the common evaluation period.

This demonstrated that the choice of estimation window affected the behaviour of the model.

My main conclusion is that historical risk estimates should not be treated as fixed measures independent of the market conditions and historical observations used to produce them.

Although the longer windows performed better in terms of exception frequency in this sample, the analysis does not establish that longer estimation windows are always more accurate.

## 6. Historical Stress Analysis

The analysis identified the ten worst daily returns in the simulated portfolio.

The largest daily loss was approximately −4.93% on 3 April 2025.

For each stress date, I calculated the contribution of every holding to the portfolio's total daily return.

These calculations allowed me to identify which instruments were responsible for the largest negative contributions during particular trading days.

The results were presented through an interactive Tableau chart, allowing individual dates to be selected and examined.

This analysis provides holding-level attribution for historical losses, but further research would be required to identify the economic causes of those market movements.

## 7. Limitations

Several limitations affect the interpretation of the results.

**Historical simulation:** The portfolio was constructed using current holding quantities applied to historical prices, not my actual historical transactions.

**Limited historical period:** The analysis starts in March 2024 because of the available price history of the selected instruments.

**Historical risk modelling:** The results depend on the observed market conditions and may change when the estimation period changes.

**Market calendar alignment:** Some prices were forward-filled to align instruments traded on different exchanges.

**Currency movements:** Portfolio values and returns were calculated in GBP, incorporating foreign exchange movements.

**Benchmark overlap:** VUAG was both the benchmark and a significant portfolio holding.

**Incomplete sector analysis:** The study did not perform a full analysis of the underlying holdings within the ETFs.

**Backtesting uncertainty:** Failure to reject statistical coverage tests does not guarantee the model's future reliability.

These limitations are particularly important when considering whether the historical results provide sufficient evidence to change an investment strategy.

## 8. Areas for Further Research

### Sector Exposure and ETF Overlap

One improvement would be a more detailed sector breakdown.

I would like to investigate the sector allocation of the individual equities alongside the underlying holdings of VUAG and VFEG.

This would help determine the extent to which the portfolio is exposed to the same sectors or companies through multiple investments.

### Return Attribution

The risk analysis identified several equities with disproportionately high volatility contributions.

A separate return-attribution analysis would help determine whether these same equities were responsible for the portfolio's additional historical returns relative to the S&P 500.

This would provide stronger evidence when evaluating whether the additional risk was worthwhile.

### April 2025 Drawdown

I would also like to investigate the market conditions surrounding the portfolio's largest drawdown.

The current analysis identifies the magnitude, timing and holding-level contributions of historical losses, but a further event-based investigation could help explain the underlying movements.

## 9. Final Reflection

This project allowed me to apply SQL, statistical methods and financial risk modelling to a portfolio I had previously managed without carrying out a detailed quantitative analysis.

The results gave me a better understanding of which instruments contributed the most risk and how my combination of ETFs and individual equities compared with an S&P 500 benchmark.

The historical performance comparison was encouraging, but it also highlighted the additional volatility associated with the selected allocation.

The VaR backtesting and sensitivity analysis demonstrated that historical risk estimates depend on the data and estimation windows used.

Overall, the project has given me quantitative measures with which to assess my portfolio, while also identifying questions that would require further analysis before drawing stronger conclusions about my investment strategy.