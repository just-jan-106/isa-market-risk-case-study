# 02 PREPARE — Data source register

**Status:** Sources not yet selected or downloaded.

| Dataset | Purpose | Source/link | Access date | History / fields | Licence and permission | Issues / validation |
|---|---|---|---|---|---|---|
| Trading 212 holdings (private) | Portfolio snapshot | Local private export | TBD | TBD | Private: never publish raw | Check ticker / ISIN, currency, cash, weights |
| Historical market prices | Portfolio risk history | TBD | TBD | TBD | TBD | Check splits, dividends, survivorship and coverage |
| Historical GBP FX | Currency conversion | TBD | TBD | TBD | TBD | Quote direction and trading dates |
| Market benchmark | Comparable baseline | TBD | TBD | TBD | TBD | Match GBP, total-return convention, dates |

## Data integrity and credibility (ROCCC)
- **Reliable:** Is the provider credible and data provenance documented?
- **Original:** Is this primary data or a derived dataset?
- **Comprehensive:** Does it cover all relevant holdings and the analysis window?
- **Current:** When was it updated and downloaded?
- **Cited:** Can a reviewer find the source and licensing terms?

## Instrument mapping
Create a private mapping from T212 ticker/ISIN/exchange to public price ticker, market, quotation currency, asset class and share class. Record exclusions explicitly.

## Exit checks
- [ ] Identify all source URLs and applicable permissions
- [ ] Verify holding-to-market-price mappings
- [ ] Establish an analysis-ready overlapping date range
- [ ] Record currency and adjustment conventions
- [ ] Keep private exports outside Git tracking
