from __future__ import annotations

import json
from pathlib import Path

import pandas as pd


def build_quality_report(df: pd.DataFrame, source_rows: int) -> dict:
    """Return transparent, machine-readable ETL quality indicators."""
    numeric = [
        "people_involved", "deaths", "slightly_injured", "severely_injured",
        "uninjured", "ignored", "vehicles_involved",
    ]
    return {
        "source_rows": source_rows,
        "accepted_rows": len(df),
        "rejected_rows": source_rows - len(df),
        "duplicate_accident_rows": int(df.duplicated().sum()),
        "nulls_by_column": {key: int(value) for key, value in df.isna().sum().items()},
        "negative_measure_rows": int((df[numeric] < 0).any(axis=1).sum()),
        "date_range": {
            "min": str(df["date_of_accident"].min()),
            "max": str(df["date_of_accident"].max()),
        },
    }


def write_quality_report(report: dict, output_path: Path) -> None:
    output_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
