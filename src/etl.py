from __future__ import annotations

from pathlib import Path

import pandas as pd

from src.quality import build_quality_report, write_quality_report


ROOT = Path(__file__).resolve().parents[1]
INPUT_FILE = ROOT / "data" / "raw" / "accidents_2017_to_2023_english.csv"
OUTPUT_DIR = ROOT / "data" / "processed"

REQUIRED_COLUMNS = {
    "inverse_data", "state", "city", "road_type", "road_delineation",
    "cause_of_accident", "type_of_accident", "regional", "police_station",
    "people", "deaths", "slightly_injured", "severely_injured",
    "uninjured", "ignored", "vehicles_involved",
}
MEASURES = [
    "people_involved", "deaths", "slightly_injured", "severely_injured",
    "uninjured", "ignored", "vehicles_involved",
]
TEXT_COLUMNS = [
    "state", "city", "road_type", "road_delineation", "cause_of_accident",
    "type_of_accident", "regional", "police_station",
]


def normalise_columns(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df.columns = df.columns.str.strip().str.lower().str.replace(" ", "_", regex=False)
    return df


def transform(source: pd.DataFrame) -> pd.DataFrame:
    source = normalise_columns(source)
    missing = REQUIRED_COLUMNS.difference(source.columns)
    if missing:
        raise ValueError(f"Source is missing required columns: {', '.join(sorted(missing))}")

    df = source[sorted(REQUIRED_COLUMNS)].copy().rename(
        columns={"inverse_data": "date_of_accident", "people": "people_involved"}
    )
    df["date_of_accident"] = pd.to_datetime(df["date_of_accident"], errors="coerce")
    df = df.dropna(subset=["date_of_accident", "state", "city"])

    for column in TEXT_COLUMNS:
        df[column] = df[column].astype("string").str.strip().replace({"": pd.NA})
        df[column] = df[column].fillna("Unknown")

    for column in MEASURES:
        df[column] = pd.to_numeric(df[column], errors="coerce").fillna(0).clip(lower=0).astype("int64")

    df = df.drop_duplicates().copy()
    df["year"] = df["date_of_accident"].dt.year.astype("int16")
    df["month"] = df["date_of_accident"].dt.month.astype("int8")
    df["day"] = df["date_of_accident"].dt.day.astype("int8")
    df["day_of_week"] = df["date_of_accident"].dt.day_name()
    df.insert(0, "accident_id", range(1, len(df) + 1))
    return df.sort_values("date_of_accident").reset_index(drop=True)


def main() -> None:
    if not INPUT_FILE.exists():
        raise FileNotFoundError(f"Place the CSV at: {INPUT_FILE}")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    source = pd.read_csv(INPUT_FILE, encoding="utf-8-sig", low_memory=False)
    cleaned = transform(source)
    cleaned.to_csv(OUTPUT_DIR / "accidents_clean.csv", index=False, encoding="utf-8")
    cleaned.to_parquet(OUTPUT_DIR / "accidents_clean.parquet", index=False)
    write_quality_report(build_quality_report(cleaned, len(source)), OUTPUT_DIR / "quality_report.json")
    print(f"Processed {len(cleaned):,} of {len(source):,} source rows.")
    print(f"Output: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
