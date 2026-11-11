"""Reshape adjusted daily closes into the long-format BigQuery import schema."""

from pathlib import Path

import pandas as pd


DATA_DIR = Path(__file__).resolve().parents[1] / "data" / "raw_market"


def reshape_prices(closing_prices: pd.DataFrame) -> pd.DataFrame:
    """Return date/ticker/adjusted_close rows, preserving missing observations."""
    if closing_prices.empty:
        raise ValueError("closing_prices.csv contains no data")

    long_prices = (
        closing_prices.rename_axis("date")
        .reset_index()
        .melt(id_vars="date", var_name="ticker", value_name="adjusted_close")
    )
    long_prices["date"] = pd.to_datetime(long_prices["date"]).dt.strftime("%Y-%m-%d")
    return long_prices.sort_values(["date", "ticker"]).reset_index(drop=True)


def main() -> None:
    source = DATA_DIR / "closing_prices.csv"
    if not source.exists():
        raise FileNotFoundError(f"Run download_prices.py first: {source}")

    closing_prices = pd.read_csv(source, index_col=0, parse_dates=True)
    long_prices = reshape_prices(closing_prices)
    target = DATA_DIR / "prices_long.csv"
    long_prices.to_csv(target, index=False)
    print(f"Saved {len(long_prices):,} rows to {target}")
    print(long_prices.head().to_string(index=False))


if __name__ == "__main__":
    main()
