# Published aggregate results

| File | Contents | Important detail |
| --- | --- | --- |
| `portfolio_risk_summary.csv` | Annualised volatility, maximum drawdown, historical VaR and expected shortfall at 95% and 99% | Values are decimal rates: `0.1454` represents 14.54%. Exact account value is excluded. |
| `var_sensitivity_summary.csv` | Out-of-sample 95% VaR exceptions for 125-, 250- and 375-observation estimation windows | The `*_pct` columns are already in percent units: `7.97` means 7.97%, not 797%. |

Both files are derived snapshots of the hypothetical portfolio analysis; neither is sufficient to regenerate the underlying model. The sensitivity rows use the same 301-date evaluation sample.
