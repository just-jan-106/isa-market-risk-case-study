"""Download adjusted daily closing prices for the 21 portfolio instruments."""

from pathlib import Path

import pandas as pd
import yfinance as yf


TICKERS = [
    "VUAG.L", "VFEG.L", "AVGO", "NVDA", "VRT", "MSFT", "AMZN",
    "BLK", "TTWO", "AMD", "PLTR", "RR.L", "META", "GEV",
    "SHEL.L", "TSCO.L", "BA.L", "BP.L", "MU", "LMT", "AIR.PA",
]
START_DATE = "2021-11-09"
END_DATE = "2026-11-10"  # Yahoo Finance end date is exclusive.
OUTPUT_DIR = Path(__file__).resolve().parents[1] / "data" / "raw_market"


def extract_closing_prices(download: pd.DataFrame) -> pd.DataFrame:
    """Extract the auto-adjusted Close series from ticker-grouped yfinance data."""
    if download.empty or not isinstance(download.columns, pd.MultiIndex):
        raise ValueError("Expected non-empty, multi-ticker Yahoo Finance output")

    available = set(download.columns.get_level_values(0))
    missing = [ticker for ticker in TICKERS if ticker not in available]
    if missing:
        raise ValueError(f"Missing tickers in download: {', '.join(missing)}")

    close = pd.DataFrame({ticker: download[ticker]["Close"] for ticker in TICKERS})
    if close.isna().all(axis=0).any():
        unavailable = close.columns[close.isna().all(axis=0)].tolist()
        raise ValueError(f"No closing prices returned for: {', '.join(unavailable)}")

    close.index = pd.to_datetime(close.index).tz_localize(None)
    close.index.name = "date"
    return close.sort_index()


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    prices = yf.download(
        tickers=TICKERS,
        start=START_DATE,
        end=END_DATE,
        interval="1d",
        auto_adjust=True,
        group_by="ticker",
        progress=True,
        threads=True,
    )
    closing_prices = extract_closing_prices(prices)

    # Keep the full vendor response locally for audit; it is not a public artifact.
    prices.to_pickle(OUTPUT_DIR / "historical_prices.pkl")
    closing_prices.to_csv(OUTPUT_DIR / "closing_prices.csv")

    coverage = pd.DataFrame({
        "observations": closing_prices.count(),
        "first_date": closing_prices.apply(lambda col: col.first_valid_index()),
        "last_date": closing_prices.apply(lambda col: col.last_valid_index()),
        "missing_values": closing_prices.isna().sum(),
    })
    coverage.to_csv(OUTPUT_DIR / "coverage_summary.csv")
    print("\nHistorical price coverage:\n", coverage.to_string())


if __name__ == "__main__":
    main()
