# Research journal

Keep concise, dated entries on **meaningful decisions**, not every keystroke. Add a reference to the relevant code, SQL, output or test. Never include private account details.

## Entry 001 — Project initiation (2026-11-09, ASK)
**Objective:** Define a professional market-risk capstone using an anonymised real ISA portfolio.  
**Decision:** Follow Coursera Track B's ASK / PREPARE / PROCESS / ANALYZE / SHARE / ACT workflow.  
**Rationale:** Supports a reproducible, employer-facing case study with a real decision question.  
**Evidence:** `README.md`, `PROJECT_STATUS.md`, `docs/01_business_task.md`.  
**Unresolved:** Holdings, source licensing, dates, benchmark, rebalancing convention.  
**Next:** Confirm the problem and inspect holdings schema.

---

## New entry template
**Entry ID / date / stage:**  
**Objective / question:**  
**Problem encountered:**  
**Options considered:**  
**Decision and why:**  
**Technical implementation / evidence (path, query, figure):**  
**Validation / checks:**  
**Finding / interpretation (if verified):**  
**Limitations / follow-up:**  

# Research Journal
## Quantitative Market Risk Assessment — Trading 212 Stocks & Shares ISA

**Project:** Google Data Analytics Capstone — Track B  
**Started:** 9 November 2026  
**Tools:** Python, pandas, NumPy, yfinance, Google BigQuery, SQL, Google Sheets and Tableau  
**Status:** PREPARE — Historical market data acquired; database import pending.

---

## Entry 001 — Business Problem Definition

**Date:** 9 November 2026  
**Coursera Stage:** ASK  
**Status:** Initial scope established

### Objective

Define a real-world financial risk problem suitable for an independent data analytics case study.

### Business Context

This project evaluates the financial market risk characteristics of a real Stocks & Shares ISA portfolio held through Trading 212.

The portfolio will be treated as an anonymised investment portfolio requiring independent risk assessment. The intended audience is a hypothetical investment manager or private investment client.

The objective is not to predict which investments will perform best, but to quantify existing risk exposures and evaluate how effectively the portfolio is diversified.

### Central Research Question

How effectively is the portfolio diversified, what are its principal sources of financial market risk, and how accurately can statistical models estimate potential portfolio losses?

### Research Questions

1. **Portfolio Concentration:** How concentrated is the portfolio across individual securities, sectors, regions and currencies?
2. **Diversification:** To what extent do correlations and overlapping exposures reduce diversification?
3. **Downside Risk:** What potential losses are suggested by Value at Risk and Expected Shortfall?
4. **Model Reliability:** How do risk estimates respond to changing market conditions and modelling assumptions?
5. **Benchmark Comparison:** How does the portfolio's historical risk compare with an appropriate benchmark?

### Initial Hypotheses

- H1: The portfolio may be more concentrated than its number of holdings suggests.
- H2: Correlations and overlapping investments may reduce diversification.
- H3: Extreme portfolio losses may be greater than those implied by a normal-distribution model.

These hypotheses are provisional and have not yet been tested.

### Analytical Approach

Use the current portfolio composition and publicly available historical financial data to construct a quantitative risk assessment.

The analysis will include portfolio concentration, returns, volatility, correlations, drawdowns, Value at Risk, Expected Shortfall and selected stress scenarios.

### Important Limitation

Applying current portfolio weights to historical prices produces a hypothetical historical simulation, not the portfolio's actual realised investment performance.

### Outcome

Initial business task, audience, research questions, hypotheses and analytical scope established.

### Next Step

Obtain the current holdings and verify the instruments before collecting historical prices.

---

## Entry 002 — Portfolio Data Collection

**Date:** 9 November 2026  
**Coursera Stage:** PREPARE  
**Status:** Completed — initial portfolio snapshot received

### Objective

Obtain and examine the current holdings of the Trading 212 Stocks & Shares ISA portfolio.

### Data Source

Trading 212 holdings CSV exported on 9 November 2026.

### Method

Reviewed the holdings export to identify the investments included in the portfolio and determine the structure of the available data.

Excluded the portfolio total row from the list of individual securities to avoid double-counting.

### Initial Findings

The portfolio contains **21 holdings**:

- 2 equity exchange-traded funds (ETFs)
- 19 individual company shares

The portfolio snapshot indicated that approximately 56% of the portfolio was allocated to ETFs and 44% to individual equities.

The largest positions included Vanguard S&P 500 UCITS ETF, Vanguard FTSE Emerging Markets UCITS ETF, Broadcom, Nvidia and BlackRock.

### Potential Analytical Issue

Several individually held US companies are also constituents of the S&P 500 index.

This creates a potential overlap between direct equity holdings and the underlying exposures of the S&P 500 ETF.

The degree of concentration and its effect on portfolio risk have not yet been quantified.

### Data Limitations

The available CSV represents a portfolio snapshot rather than a complete historical transaction record.

It can support analysis of the current portfolio's historical risk characteristics but cannot independently reconstruct actual historical investment performance.

### Outcome

Established the portfolio universe of 21 financial instruments and identified potential overlapping market exposures.

### Next Step

Verify instrument identities, exchanges, currencies and historical market data identifiers.

---

## Entry 003 — Instrument Identification and Historical Ticker Mapping

**Date:** 9 November 2026  
**Coursera Stage:** PREPARE  
**Status:** Instrument mapping established; provider-level verification ongoing

### Objective

Identify the correct financial instruments and historical market data tickers required to retrieve reliable price observations.

### Tools

- Trading 212 instrument information
- Google Sheets
- Yahoo Finance ticker conventions

### Methodology

Created an Instrument Master table containing:

- Company or fund name
- Trading 212 ticker
- ISIN
- Exchange
- Historical data ticker
- Trading currency
- Asset type
- Portfolio weight
- Verification status

Matched the 21 investments against Yahoo Finance ticker conventions.

### Historical Data Tickers

| Investment | Historical ticker |
|---|---|
| Vanguard S&P 500 (Acc) | VUAG.L |
| Vanguard Emerging Markets (Acc) | VFEG.L |
| Broadcom | AVGO |
| Nvidia | NVDA |
| Vertiv | VRT |
| Microsoft | MSFT |
| Amazon | AMZN |
| BlackRock | BLK |
| Take-Two Interactive | TTWO |
| Advanced Micro Devices | AMD |
| Palantir | PLTR |
| Rolls-Royce | RR.L |
| Meta Platforms | META |
| GE Vernova | GEV |
| Shell | SHEL.L |
| Tesco | TSCO.L |
| BAE Systems | BA.L |
| BP | BP.L |
| Micron Technology | MU |
| Lockheed Martin | LMT |
| Airbus | AIR.PA |

### Data Quality Considerations

The instrument review identified differences between exchange-specific historical price symbols.

For example:

- London-listed securities generally use the `.L` suffix in Yahoo Finance.
- Airbus uses `AIR.PA` for its Euronext Paris listing.
- Vertiv and BlackRock are listed on the NYSE.
- Certain UK securities are quoted in GBX rather than GBP.
- US equities are primarily quoted in USD.
- Airbus is quoted in EUR.

### Currency Considerations

Portfolio-level analysis will be conducted in GBP.

Historical prices quoted in GBX require conversion from pence to pounds, while USD and EUR instruments require correctly aligned historical foreign-exchange rates.

Currency conversion has not yet been performed.

### Outcome

Created a consistent list of historical data tickers covering the 21 portfolio holdings.

### Next Step

Retrieve historical adjusted closing prices and investigate their availability and quality.

---

## Entry 004 — Historical Market Data Acquisition

**Date:** 9 November 2026  
**Coursera Stage:** PREPARE  
**Status:** Completed — initial data acquisition

### Objective

Collect approximately five years of daily historical market prices for the 21 investments.

### Data Source

Yahoo Finance, accessed through Python's `yfinance` library.

### Requested Date Range

9 November 2021 to 9 November 2026, inclusive.

### Tools and Techniques

- Python
- `yfinance`
- pandas
- `pathlib`
- CSV export
- Data coverage assessment

### Methodology

Created `src/download_prices.py`.

The script requests daily market-price observations for all 21 securities using `yf.download()` with `auto_adjust=True`.

It preserves the retrieved dataset and extracts adjusted closing prices for each instrument.

The script also generates a data-coverage summary showing observation counts, first and last available dates, and missing values.

### Files Generated

- `data/raw_market/historical_prices.pkl`
- `data/raw_market/closing_prices.csv`
- `data/raw_market/coverage_summary.csv`

### Results

The script successfully returned historical data for all 21 requested tickers.

Most individual US equities returned approximately 1,255 daily observations across the requested period.

UK-listed instruments returned slightly different counts because of differences in exchange trading calendars.

GE Vernova returned 658 observations, beginning on 27 March 2024.

### Data Quality Findings

The dataset contains missing observations when evaluated against its combined date index.

Potential explanations include:

- Different exchange trading days and public holidays.
- Different instrument listing histories.
- Market data availability.
- Differences in historical coverage.

These missing values have not yet been classified or corrected.

### Limitations

Successful retrieval does not establish that every observation is correct.

Historical quotation currencies, adjusted-price treatment, missing observations and instrument coverage still require validation.

The complete five-year period cannot be used for every instrument without addressing GE Vernova's shorter trading history.

### Outcome

Historical adjusted closing-price data acquired for all 21 holdings.

### Next Step

Restructure the dataset for relational analysis and import it into BigQuery after validation.

---

## Entry 005 — Historical Market Data Restructuring

**Date:** 9 November 2026  
**Coursera Stage:** PREPARE / PROCESS  
**Status:** Completed — structural transformation

### Objective

Convert the historical price dataset from wide format into long format for relational database storage and SQL analysis.

### Tools and Techniques

- Python
- pandas
- `read_csv()`
- `rename_axis()`
- `reset_index()`
- `melt()`
- `to_csv()`

### Initial Data Structure

The original wide-format dataset contained one date column and a separate adjusted closing-price column for each investment.

This format is convenient for certain numerical calculations but less suitable for relational queries across a changing set of financial instruments.

### Transformation

Created a separate script:

`src/download_prices_long.py`

The script reads the previously downloaded `closing_prices.csv` file.

The pandas `melt()` operation transforms the table into three columns:

- `date`
- `ticker`
- `adjusted_close`

Each row represents a specific date and financial instrument.

### Reason for Transformation

Long-format data supports efficient SQL operations, including:

- Filtering and grouping by financial instrument.
- Counting historical observations.
- Identifying missing values.
- Joining market prices to instrument metadata.
- Integrating exchange-rate information.
- Generating financial-data summaries.

Separating the transformation script from the acquisition script also improves reproducibility.

### Output

**File:** `data/raw_market/prices_long.csv`

**Number of rows:** 27,153

**Number of instruments expected:** 21

### Important Interpretation

The 27,153 rows represent combinations of dates and instruments, not necessarily 27,153 valid market-price observations.

Some observations contain missing values and will require investigation.

The script changes the structure of the data without intentionally modifying the historical prices.

### Validation Still Required

- Confirm that the table contains exactly 21 distinct tickers.
- Check date/ticker uniqueness.
- Count missing and non-positive prices.
- Confirm that numerical and date fields import correctly into BigQuery.
- Verify the data against the original wide-format dataset.

### Outcome

Successfully created and exported a long-format historical market-price table suitable for the next database stage.

### Next Step

Import the dataset into Google BigQuery and perform structured SQL data-quality checks.

---

## Current Project Handover

**Last working date:** 9 November 2026

**Current stage:** PREPARE, transitioning towards PROCESS.

### Completed

- Initial business problem and research questions established.
- Trading 212 holdings snapshot examined.
- Historical ticker mapping established for 21 instruments.
- Five years of historical prices requested and retrieved.
- Initial coverage report generated.
- Long-format dataset created containing 27,153 rows.

### Outstanding

- Upload long-format data into BigQuery.
- Validate missing values, duplicates, price units and data types.
- Confirm final instrument metadata.
- Source historical foreign-exchange rates.
- Convert historical prices consistently into GBP.
- Select the final modelling window and benchmark.
- Begin statistical risk analysis.

### Immediate Next Action

Create the BigQuery dataset `isa_market_risk` and import `prices_long.csv` into a table named `raw_market_prices`.

**Important:** The original Trading 212 exports and personal portfolio values must remain private. The public repository should contain only appropriately sanitised documentation, code and data.

## Entry 006 — BigQuery Data Ingestion and Validation

**Date:** 9 November 2026  
**Coursera stage:** PREPARE / PROCESS  
**Status:** Initial validation completed; duplicate and currency checks pending.

### Objective

Import the long-format historical financial market dataset into Google BigQuery and validate its structure, completeness and price values using SQL.

### Methodology

Imported `prices_long.csv` into the `isa_market_risk.raw_market_prices` table.

Used SQL queries incorporating `COUNT()`, `COUNT(DISTINCT)`, `COUNTIF()`, `MIN()`, `MAX()`, `GROUP BY` and `ORDER BY` to evaluate data coverage and identify missing or invalid observations.

### Results

- Total records: 27,153
- Distinct financial instruments: 21
- Valid price observations: 25,827
- Missing price observations: 1,326 (4.9%)
- Non-positive prices: 0
- Date range: 9 November 2021 to 9 November 2026

### Findings

GE Vernova accounted for 635 missing observations due primarily to its shorter available trading history, beginning on 27 March 2024.

Other missing observations may reflect differences between trading calendars and market holidays.

The absence of non-positive prices provides initial evidence that the imported numerical values are plausible, although this does not independently verify historical price accuracy.

### Decisions

- Preserve missing values as NULL pending investigation.
- Do not replace missing prices with zero.
- Retain the original downloaded data for reproducibility.
- Verify quotation currencies and historical exchange rates before calculating portfolio-level returns.

### Limitations

The initial validation does not establish that all tickers have been matched to the correct listings or that all historical observations are accurate.

Duplicate date/ticker validation remains to be confirmed.

### Next steps

1. Confirm that no duplicate date/ticker combinations exist.
2. Investigate missing observations relative to trading calendars.
3. Collect historical foreign-exchange rates.
4. Standardise historical prices into GBP.
5. Establish the final common analysis period.

### Additional Validation — Duplicate Record Check

**Date:** 9 November 2026  
**Tool:** Google BigQuery (SQL)  
**Status:** Passed

**Objective:** Verify that historical market-price observations are uniquely identified by their trading date and financial instrument ticker.

**Method:** Used SQL `GROUP BY` to group records by `date` and `ticker`, applied `COUNT(*)` to determine the number of observations per combination, and used `HAVING` to identify combinations occurring more than once.

**Result:** The query returned zero rows, confirming that no duplicate `(date, ticker)` combinations were detected in the imported dataset.

**Conclusion:** The dataset satisfies the expected uniqueness requirement for historical price observations. No deduplication is currently necessary.

**Evidence:** `sql/01_data_validation.sql` and the successful BigQuery query result.

### Instrument Master — Relational Integrity Validation

**Objective:** Verify that historical market-price observations can be reliably matched to the correct instrument metadata.

**Methodology:** Used a SQL `LEFT JOIN` to associate historical price records with the instrument master through their historical ticker identifiers. Checked for missing currency mappings using `IS NULL`, and tested reference-table uniqueness using `GROUP BY`, `COUNT(*)` and `HAVING`.

**Results:**
- Historical price records: 27,153
- Instruments: 21
- Missing currency mappings: 0
- Duplicate historical tickers in instrument master: 0
- Joined records: 27,153

**Conclusion:** The instrument master provides a complete, unique ticker mapping for the historical price dataset. No unmatched or duplicated instrument identifiers were detected.

**Next step:** Acquire historical exchange-rate data and standardise prices into GBP.