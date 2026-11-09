# 04 ANALYZE — Methods and model register

**Status:** Proposed; results not calculated.

## Portfolio definition (decide explicitly)
- Holdings snapshot date: TBD
- GBP historical window: TBD
- Method: Fixed snapshot weights, **daily rebalanced** or **buy-and-hold hypothetical**? TBD
- Market-price/total-return conventions: TBD
- Benchmark and comparison basis: TBD

## Planned core methods
| Metric | Purpose | Required choices / limitations | Implementation / evidence |
|---|---|---|---|
| Holdings concentration | Exposure concentration | Holdings vs look-through ETF exposure | TBD |
| Daily returns | Common analytical unit | Simple vs log; GBP FX; distributions | TBD |
| Annualised volatility | Historical dispersion | Window and annualisation convention | TBD |
| Max drawdown | Historical peak-to-trough loss | Hypothetical path vs realised ISA path | TBD |
| Correlation / covariance | Co-movement and diversification | Sample window and stale price risk | TBD |
| Contribution to variance | Which assets drive risk | Dependence on portfolio weights and covariance | TBD |
| Historical VaR / ES | Downside loss estimates | Horizon, percentile, sample size, tail definition | TBD |
| Rolling risk | Regime change / monitoring | Rolling window and missing-day policy | TBD |
| Benchmark comparison | Relative risk context | Match price/total-return, currency and dates | TBD |
| Stress scenarios | Exposures under adverse assumptions | Scenarios not forecasts | TBD |

## Model review
- [ ] Units, horizon, sample and confidence levels shown on results
- [ ] Validation evidence and manual checks recorded
- [ ] No in-sample evaluation presented as out-of-sample backtest
- [ ] Sensitivity to modelling choices considered
- [ ] Limitations and interpretation written in plain English

## Findings log
| ID | Finding | Numerical evidence | Figure or table | Interpretation / caveat |
|---|---|---|---|---|
| F-001 | TBD | TBD | TBD | TBD |
