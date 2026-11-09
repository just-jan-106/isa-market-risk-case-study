# 03 PROCESS — Cleaning and validation log

**Status:** No data processed yet.

## Pipeline
`private holdings + licensed market prices/FX -> Python/pandas -> validated GBP-aligned price panel -> BigQuery SQL checks -> risk-model inputs`

## Record each substantive transformation
| ID | Date | Input | Issue / reason | Transformation | Validation and evidence | Output |
|---|---|---|---|---|---|---|
| CL-001 | TBD | TBD | TBD | TBD | TBD | TBD |

## Essential checks
- [ ] Schema and type conversions tested
- [ ] Duplicates, missing rows and stale values investigated
- [ ] Date alignment and market holidays treated explicitly
- [ ] Corporate actions, distributions and adjusted prices documented
- [ ] GBP FX conversion independently checked for direction
- [ ] Prices and returns not inadvertently mixed
- [ ] No future information appears in earlier model training windows
- [ ] SQL aggregates reconcile to Python checks

## Do not do
Do not automatically forward-fill every missing market value, mix price-only and total-return series without disclosure, or upload raw account history to a public repository.
