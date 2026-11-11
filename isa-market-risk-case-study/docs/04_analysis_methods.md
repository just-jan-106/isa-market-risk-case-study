# 04 — Analysis Methods

## Overview

This project uses Google BigQuery SQL to analyse the historical performance and risk of my selected ISA holdings. Python was used to collect and prepare the market data, with Tableau used to visualise the results.

The analysis covers 21 instruments over 677 trading dates, from 27 March 2024 to 9 November 2026.

The methods include portfolio returns, volatility, drawdown, correlation, risk contributions, Value at Risk (VaR), Expected Shortfall (ES), benchmark comparisons and backtesting.

## 1. Historical Portfolio Construction

The portfolio was simulated using the quantities held at the time of the portfolio snapshot.

Each instrument's value was calculated by multiplying its quantity by its historical GBP-adjusted price.

For \(n\) instruments:

\[
V_t=\sum_{i=1}^{n}q_iP_{i,t}
\]

where \(q_i\) represents the fixed quantity of instrument \(i\), and \(P_{i,t}\) its GBP-adjusted price on date \(t\).

The historical portfolio weight was calculated as:

\[
w_{i,t}=\frac{q_iP_{i,t}}{V_t}
\]

Quantities remained constant, while weights changed as market prices moved.

This is a hypothetical fixed-quantity simulation. It does not reconstruct my actual historical Trading 212 transactions or realised investment returns.

## 2. Daily Portfolio Returns

Simple daily returns were calculated from consecutive simulated portfolio values:

\[
R_t=\frac{V_t}{V_{t-1}}-1
\]

The first valuation date had no preceding observation, leaving 676 valid portfolio returns.

Returns were calculated from total portfolio values rather than by applying a constant set of weights to individual asset returns.

This is important because the portfolio weights changed historically, even though the quantities were fixed.

## 3. Historical Volatility

Volatility was calculated using the sample standard deviation of daily portfolio returns.

\[
\sigma_d=
\sqrt{\frac{1}{N-1}
\sum_{t=1}^{N}(R_t-\bar R)^2}
\]

The daily estimate was annualised using:

\[
\sigma_{\text{annual}}=\sigma_d\sqrt{252}
\]

The simulated portfolio had annualised historical volatility of approximately **14.54%**.

Volatility measures the variability of returns around their average. It is useful for understanding the degree of fluctuation in portfolio performance, but it does not distinguish positive from negative returns or directly quantify losses in the lower tail.

This was one reason I included additional downside-risk measures.

## 4. Maximum Drawdown

Drawdown was calculated relative to the previous highest portfolio value.

\[
M_t=\max(V_1,\ldots,V_t)
\]

\[
D_t=\frac{V_t}{M_t}-1
\]

Maximum drawdown was the minimum value of the drawdown series:

\[
D_{\max}=\min(D_t)
\]

The simulated portfolio's maximum drawdown was approximately **−20.79%**, with the trough occurring on 7 April 2025.

I used drawdown alongside volatility to examine the extent of historical portfolio declines rather than relying only on the overall variation in daily returns.

## 5. Correlation Analysis

Pearson correlations were calculated using the daily GBP-denominated returns of the 21 instruments.

\[
\rho_{ij}=
\frac{\operatorname{Cov}(R_i,R_j)}
{\sigma_i\sigma_j}
\]

The resulting correlation matrix was displayed as a Tableau heatmap.

Because the returns were denominated in GBP, the measured relationships also incorporate exchange-rate movements for assets originally traded in foreign currencies.

Historical correlations describe the relationships observed in the selected sample and are not assumed to remain constant.

## 6. Portfolio Risk Contributions

I wanted to identify which instruments contributed the most to my portfolio's overall risk and understand how their exposure affected portfolio volatility.

To do this, I used a covariance-based risk decomposition.

For portfolio weights \(w\) and annualised covariance matrix \(\Sigma\):

\[
\sigma_p=\sqrt{w^\mathsf{T}\Sigma w}
\]

The marginal contribution of instrument \(i\) to portfolio volatility is:

\[
MRC_i=\frac{(\Sigma w)_i}{\sigma_p}
\]

Its component contribution is:

\[
RC_i=w_iMRC_i
\]

The percentage risk contribution is:

\[
RC_{i,\%}=\frac{RC_i}{\sigma_p}\times100
\]

The contributions were checked to ensure they summed to 100%, subject to rounding.

I also calculated excess risk contribution:

\[
ERC_i=RC_{i,\%}-100w_i
\]

This compares an instrument's contribution to overall volatility with its share of portfolio value.

The covariance-based portfolio volatility was approximately **15.03%**, compared with 14.54% from the historical portfolio return series.

The difference arises because the covariance calculation uses one set of portfolio weights, while the historical simulation allows weights to drift over time.

The risk-contribution analysis therefore addresses a different question from simply identifying the largest holdings.

## 7. Historical Value at Risk

I included VaR because volatility alone does not directly describe the size of potential losses.

Historical VaR estimates a loss threshold from the lower tail of observed returns.

For a 95% one-day historical VaR:

\[
VaR_{95\%}=-Q_{0.05}(R)
\]

The full-sample historical estimate was approximately **1.393%**.

Under this historical model, approximately 5% of observations fall beyond the estimated loss threshold.

The figure does not represent the maximum possible loss, nor does it predict the exact loss on a future day.

The historical method uses the empirical return distribution rather than imposing a normal distribution assumption. However, its results depend on the observations available in the estimation period.

## 8. Expected Shortfall

I used Expected Shortfall alongside VaR because I also wanted to understand the average severity of losses beyond the estimated VaR threshold.

For confidence level \(c\):

\[
ES_c=-E[R\mid R\leq Q_{1-c}(R)]
\]

The historical results were:

| Measure | Estimated daily loss |
| 95% Expected Shortfall | 2.21% |
| 99% Expected Shortfall | 3.66% |

VaR provides a threshold, whereas Expected Shortfall describes the average loss in the corresponding lower tail.

Both measures depend on the historical sample. Expected Shortfall estimates at high confidence levels are particularly sensitive to extreme observations because relatively few returns fall in the relevant tail.

## 9. Benchmark Comparison

I compared my simulated portfolio with the Vanguard S&P 500 UCITS ETF (VUAG.L).

This followed my original research question about how a portfolio combining ETFs with individual equities would compare with a simpler S&P 500 buy-and-hold investment.

Both series were indexed to 100 at the beginning of the common analysis period:

\[
I_t=100\frac{V_t}{V_0}
\]

For the benchmark, the calculation used its adjusted GBP price series.

Additional statistics included return correlation, beta, tracking error, annualised volatility and maximum drawdown.

Beta was calculated as:

\[
\beta_p=
\frac{\operatorname{Cov}(R_p,R_b)}
{\operatorname{Var}(R_b)}
\]

Tracking error was calculated as:

\[
TE=\operatorname{SD}(R_p-R_b)\sqrt{252}
\]

VUAG was also a significant holding in the simulated portfolio, so the benchmark and portfolio were not independent.

The comparison measures historical differences in performance and risk. It does not establish future outperformance or determine which investment strategy is preferable.

## 10. Rolling Volatility

I calculated rolling volatility because I wanted to investigate changes in portfolio risk over time, particularly around a period of drawdown.

Full-period volatility provides one estimate for the entire sample. Rolling volatility instead measures how the observed variability of returns changes as the estimation window moves through time.

I used 30- and 90-observation windows:

\[
\sigma_{t,k}=
\operatorname{SD}(R_{t-k+1},\ldots,R_t)\sqrt{252}
\]

where \(k\) is the number of daily return observations.

The calculation required a full window before producing a result.

The shorter window is generally more responsive to recent changes in returns, while the longer window incorporates more observations.

Rolling volatility was calculated for both the portfolio and benchmark, with the estimation window selectable in Tableau.

This allowed me to examine the behaviour of volatility during periods of larger price movements, including the drawdown observed in the historical simulation.

## 11. Historical VaR Backtesting

The historical VaR model was evaluated using rolling, out-of-sample forecasts.

For the main backtest, each 95% one-day VaR estimate used the preceding **250 valid daily portfolio returns**.

A breach, or exception, occurred when the realised return fell below the negative VaR threshold:

\[
X_t=
\begin{cases}
1,&R_t<-VaR_t\\
0,&R_t\geq-VaR_t
\end{cases}
\]

The backtest produced:

| Metric | Result |
| Forecast observations | 426 |
| Exceptions | 23 |
| Observed exception rate | 5.40% |
| Nominal exception rate | 5.00% |

### Kupiec Unconditional Coverage Test

The Kupiec test examines whether the overall exception frequency is consistent with the model's nominal probability.

\[
LR_{UC}=
-2\ln\left[
\frac{(1-p)^{N-x}p^x}
{(1-\hat p)^{N-x}\hat p^x}
\right]
\]

where \(p\) is the nominal exception probability, \(x\) the number of exceptions, \(N\) the number of forecasts and \(\hat p=x/N\).

The likelihood-ratio statistic was approximately **0.1394**, below the 5% critical value of 3.841.

The unconditional-coverage null hypothesis was not rejected.

### Christoffersen Independence Test

The independence test examines whether exceptions exhibit statistically significant first-order clustering.

The recorded transition counts were:

| Previous day → Current day | Count |
| Non-exception → Non-exception | 382 |
| Non-exception → Exception | 20 |
| Exception → Non-exception | 20 |
| Exception → Exception | 3 |

The independence statistic was approximately **2.067**, below the 5% critical value of 3.841.

The combined conditional-coverage statistic was approximately **2.206**, below the corresponding critical value of 5.991.

Neither test provided sufficient evidence to reject the relevant null hypothesis at the chosen significance level.

This does not prove that the model is accurate or that future risk estimates will be reliable.

## 12. Historical Stress Testing

The ten worst daily returns were identified from the simulated portfolio.

For each date, the portfolio return was compared with the benchmark return, and individual holding contributions were calculated.

The contribution of instrument \(i\) was:

\[
C_{i,t}=
\frac{q_i(P_{i,t}-P_{i,t-1})}{V_{t-1}}
\]

The contributions satisfy:

\[
R_{p,t}=\sum_{i=1}^{21}C_{i,t}
\]

The individual holding contributions reconciled to the portfolio's daily return at six decimal places.

This analysis helped identify which holdings were associated with the portfolio's largest historical daily declines.

The Tableau dashboard allows a stress date to be selected to view the corresponding holding-level contributions.

This is historical stress analysis, not a simulation of hypothetical future market shocks.

## 13. VaR Sensitivity Analysis

I compared three historical VaR estimation windows to investigate how the model's results changed with the amount of historical data used.

All three models used a 95% one-day VaR specification and were evaluated over the same 301 out-of-sample dates.

| Window | Forecasts | Exceptions | Exception rate |
| 125 observations | 301 | 24 | 7.97% |
| 250 observations | 301 | 18 | 5.98% |
| 375 observations | 301 | 18 | 5.98% |

The 125-observation model produced more exceptions than the two longer-window models.

This suggests that the choice of estimation window affected the model's behaviour during the evaluation period.

However, these results do not establish that VaR always increases or decreases with the estimation window.

Historical VaR depends on the distribution of returns within each window. A shorter window may produce a higher or lower estimate depending on the observations it contains.

The exception counts also do not establish which model is statistically superior without further evaluation.

## 14. Methodological Limitations

The analysis has several limitations that affect how its results should be interpreted.

**Fixed-quantity simulation:** Current holdings were applied retrospectively rather than reconstructing historical transactions.

**Historical sample:** Risk estimates reflect the selected period and may not describe future market conditions.

**Limited common history:** The portfolio simulation begins in March 2024 because of instrument price availability.

**Forward-filled observations:** Missing market prices were carried forward when aligning trading calendars, which can influence measured return variation.

**Currency conversion:** GBP-denominated returns incorporate foreign exchange movements.

**Benchmark overlap:** VUAG is a significant portfolio holding as well as the benchmark.

**Tail-risk estimation:** Historical VaR and Expected Shortfall depend on the empirical distribution, with relatively few observations in the extreme tails.

**Backtesting:** Statistical non-rejection does not establish that a risk model is reliable in all market conditions.

The conclusions of the project are therefore restricted to the historical simulation and the statistical evidence available from the selected sample.

## 15. SQL Implementation

The calculations were implemented using the following BigQuery SQL scripts:

| File | Analysis |
| `03_portfolio_construction.sql` | Portfolio valuation, returns and weights |
| `04_risk_metrics.sql` | Volatility, drawdown, correlations, VaR, ES and risk contributions |
| `05_benchmark_comparison.sql` | Benchmark statistics and rolling volatility |
| `06_var_backtesting.sql` | Historical VaR forecasts and coverage tests |
| `07_stress_testing.sql` | Worst days and holding-level return contributions |
| `08_sensitivity_analysis.sql` | VaR estimation-window comparison |

The recovered SQL should be checked against the live BigQuery views before treating the complete pipeline as independently reproduced.
