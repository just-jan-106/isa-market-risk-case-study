"""Download USD/GBP and EUR/GBP rates for the portfolio's GBP valuation."""

from pathlib import Path

import pandas as pd
import yfinance as yf


FX_TICKERS = {"GBP=X": "USD", "EURGBP=X": "EUR"}
START_DATE = "2021-11-09"
END_DATE = "2026-11-10"  # Exclusive.
OUTPUT_DIR = Path(__file__).resolve().parents[1] / "data" / "raw_market"


def reshape_fx_rates(download: pd.DataFrame) -> pd.DataFrame:
    """Return date/currency/gbp_per_unit rows for BigQuery."""
    if download.empty or not isinstance(download.columns, pd.MultiIndex):
        raise ValueError("Expected non-empty Yahoo Finance FX output")

    close = download["Close"].copy()
    missing = [ticker for ticker in FX_TICKERS if ticker not in close.columns]
    if missing:
        raise ValueError(f"Missing FX series: {', '.join(missing)}")
    close = close[list(FX_TICKERS)].rename(columns=FX_TICKERS)

    if close.isna().all(axis=0).any():
        missing_currencies = close.columns[close.isna().all(axis=0)].tolist()
        raise ValueError(f"No FX observations for: {', '.join(missing_currencies)}")

    fx_long = (
        close.rename_axis("date")
        .reset_index()
        .melt(id_vars="date", var_name="currency", value_name="gbp_per_unit")
    )
    fx_long["date"] = pd.to_datetime(fx_long["date"]).dt.strftime("%Y-%m-%d")
    return fx_long.sort_values(["date", "currency"]).reset_index(drop=True)


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    download = yf.download(
        tickers=list(FX_TICKERS),
        start=START_DATE,
        end=END_DATE,
        interval="1d",
        auto_adjust=True,
        progress=True,
    )
    fx_rates = reshape_fx_rates(download)
    target = OUTPUT_DIR / "fx_rates.csv"
    fx_rates.to_csv(target, index=False)

    print(f"Saved {len(fx_rates):,} FX observations to {target}")
    print("Missing rates by currency:")
    print(fx_rates.groupby("currency")["gbp_per_unit"].apply(lambda s: s.isna().sum()))
    print(f"Date range: {fx_rates['date'].min()} to {fx_rates['date'].max()}")


if __name__ == "__main__":
    main()
