# 01 ASK — Business task

**Status:** Draft. Do not treat proposed analysis as completed.

## Scenario and client
Hypothetical portfolio risk adviser evaluating an anonymised retail Stocks & Shares ISA on behalf of a portfolio owner. The public presentation will be written for a non-specialist investment manager or risk reviewer.

## Central question
How effectively is the portfolio diversified, what are its principal sources of market risk, and how accurately can selected statistical measures characterise potential downside losses?

## Research questions
- **RQ1:** Which holdings, sectors, regions and currencies create concentration?
- **RQ2:** How much diversification is suggested by correlations and variance contributions?
- **RQ3:** What do historical one-day 95% and 99% VaR/ES imply about potential losses?
- **RQ4:** How stable are risk estimates over time, and can any model be independently backtested?
- **RQ5:** How does risk compare with a defensible GBP-denominated benchmark?

## Hypotheses (to be tested, not asserted)
- H1: Risk concentration exceeds what the number of holdings alone suggests.
- H2: Correlated assets provide less diversification than nominal holding counts imply.
- H3: Simple normal-tail assumptions may underestimate some historical losses.

## Stakeholders and decision use
- **Portfolio owner:** Understand exposure, volatility, drawdowns and monitored risk indicators.
- **Risk reviewer:** Check model choices, data integrity, assumptions and limitations.

## Required output
One-page business brief, documented analysis, privacy-safe Tableau risk dashboard and analyst report. No personalised trade advice or predictive guarantee.

## Finalise before PREPARE
- [ ] Snapshot date and instruments established
- [ ] Core vs stretch features approved
- [ ] Metrics and periods defined
- [ ] Stakeholder questions agreed
- [ ] Success criteria confirmed


Data received: Trading 212 current holdings snapshot, 9 November 2026.

Initial observation: The portfolio contains 21 holdings, with approximately 56% allocated to two ETFs and 44% to individual equities.

Potential issue: Individual holdings may overlap with the underlying constituents of the S&P 500 ETF, creating correlated exposures.

Analytical decision: Investigate concentration, diversification and downside risk using historical returns and the portfolio's current weights.

Next step: Verify instrument identifiers, currencies and available historical price data before finalising the modelling period and benchmark.

We now have sufficient information to complete most of Stage 1: ASK and begin planning Stage 2: PREPARE. I would keep the research questions provisional until we've checked the coverage and quality of the historical datasets.
