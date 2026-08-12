"""Generate a dependency-free SVG portfolio dashboard from the processed extract."""

from __future__ import annotations

from pathlib import Path
from xml.sax.saxutils import escape

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "data" / "processed" / "accidents_clean.parquet"
OUTPUT = ROOT / "docs" / "dashboard-preview.svg"


def text(value: object) -> str:
    return escape(str(value))


def fmt(value: int | float) -> str:
    return f"{value:,.0f}"


def build_svg(df: pd.DataFrame) -> str:
    total = len(df)
    deaths = int(df["deaths"].sum())
    severe = int(df["severely_injured"].sum())
    fatal_rate = 100 * (df["deaths"] > 0).mean()
    states = (
        df.groupby("state")
        .agg(accidents=("accident_id", "size"), deaths=("deaths", "sum"))
        .assign(deaths_per_100=lambda x: 100 * x.deaths / x.accidents)
        .sort_values("deaths", ascending=False)
        .head(6)
    )
    monthly = df.groupby(["year", "month"]).size()
    annual = df.groupby("year").agg(accidents=("accident_id", "size"), deaths=("deaths", "sum"))
    top_type = (
        df.groupby("type_of_accident")
        .agg(accidents=("accident_id", "size"), deaths=("deaths", "sum"))
        .assign(deaths_per_100=lambda x: 100 * x.deaths / x.accidents)
        .query("accidents >= 100")
        .sort_values("deaths_per_100", ascending=False)
        .index[0]
    )
    top_type_row = (
        df.groupby("type_of_accident").agg(accidents=("accident_id", "size"), deaths=("deaths", "sum"))
        .loc[top_type]
    )
    top_type_rate = 100 * top_type_row.deaths / top_type_row.accidents
    width, height = 1440, 920
    colors = {"navy": "#102a43", "blue": "#1479c9", "teal": "#1da1a2", "orange": "#f59e0b", "red": "#ef5b5b", "muted": "#60758a", "line": "#dce6ef", "bg": "#f4f8fb"}
    out = [f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
    <style>text {{ font-family: Arial, sans-serif; }} .title {{font-size:26px;font-weight:700;fill:{colors['navy']}}} .sub {{font-size:14px;fill:{colors['muted']}}} .label {{font-size:13px;fill:{colors['muted']}}} .value {{font-size:30px;font-weight:700;fill:{colors['navy']}}} .cardtitle {{font-size:14px;font-weight:700;fill:{colors['navy']}}} .small {{font-size:12px;fill:{colors['muted']}}}</style>
    <rect width="100%" height="100%" fill="{colors['bg']}"/>
    <text class="title" x="52" y="58">Brazilian Road Accident Intelligence</text>
    <text class="sub" x="52" y="83">Portfolio preview · processed accident records · 01 Jan 2017 – 31 Aug 2023</text>''']
    cards = [("Accidents", fmt(total), colors["blue"]), ("Deaths", fmt(deaths), colors["red"]), ("Severe injuries", fmt(severe), colors["orange"]), ("Fatal accident rate", f"{fatal_rate:.2f}%", colors["teal"])]
    for index, (label, value, colour) in enumerate(cards):
        x = 52 + index * 338
        out.append(f'''<rect x="{x}" y="115" width="310" height="112" rx="12" fill="#fff" stroke="{colors['line']}"/>
        <rect x="{x}" y="115" width="7" height="112" rx="3" fill="{colour}"/>
        <text class="label" x="{x+25}" y="151">{label}</text><text class="value" x="{x+25}" y="195">{value}</text>''')
    out.append(f'''<rect x="52" y="260" width="790" height="300" rx="12" fill="#fff" stroke="{colors['line']}"/>
    <text class="cardtitle" x="76" y="294">Annual accident volume and deaths</text>
    <text class="small" x="76" y="316">2023 is partial through August; axis values are annual counts</text>''')
    max_accidents = annual.accidents.max()
    for index, (year, row) in enumerate(annual.iterrows()):
        x = 100 + index * 95
        bar_h = 180 * row.accidents / max_accidents
        out.append(f'<rect x="{x}" y="510" width="46" height="{-bar_h:.1f}" rx="4" fill="{colors["blue"]}"/>')
        out.append(f'<text class="small" text-anchor="middle" x="{x+23}" y="535">{year}</text>')
        out.append(f'<text class="small" text-anchor="middle" x="{x+23}" y="{505-bar_h:.1f}">{row.accidents/1000:.1f}k</text>')
    out.append(f'''<rect x="874" y="260" width="514" height="300" rx="12" fill="#fff" stroke="{colors['line']}"/>
    <text class="cardtitle" x="898" y="294">Highest-severity accident type</text>
    <text class="label" x="898" y="329">Minimum sample: 100 accidents</text>
    <text style="font:700 21px Arial;fill:{colors['navy']}" x="898" y="373">{text(top_type)}</text>
    <text style="font:700 44px Arial;fill:{colors['red']}" x="898" y="437">{top_type_rate:.2f}</text>
    <text class="label" x="1025" y="437">deaths / 100 accidents</text>
    <text class="small" x="898" y="475">{fmt(int(top_type_row.deaths))} deaths across {fmt(int(top_type_row.accidents))} accidents</text>''')
    out.append(f'''<rect x="52" y="590" width="1336" height="278" rx="12" fill="#fff" stroke="{colors['line']}"/>
    <text class="cardtitle" x="76" y="625">States with the most recorded deaths</text>
    <text class="small" x="76" y="647">Bars show death count; label shows deaths per 100 accidents to retain the risk context.</text>''')
    max_deaths = states.deaths.max()
    for index, (state, row) in enumerate(states.iterrows()):
        y = 690 + index * 27
        bar = 660 * row.deaths / max_deaths
        out.append(f'<text class="small" text-anchor="end" x="130" y="{y+13}">{text(state)}</text>')
        out.append(f'<rect x="150" y="{y}" width="{bar:.1f}" height="17" rx="3" fill="{colors["blue"]}"/>')
        out.append(f'<text class="small" x="{160+bar:.1f}" y="{y+13}">{fmt(int(row.deaths))} deaths · {row.deaths_per_100:.2f}/100</text>')
    out.append(f'''<text class="small" x="76" y="900">Generated from data/processed/accidents_clean.parquet · Rates are descriptive, not causal estimates.</text></svg>''')
    return "\n".join(out)


def main() -> None:
    if not INPUT.exists():
        raise FileNotFoundError("Run `python -m src.etl` before generating the dashboard preview.")
    OUTPUT.write_text(build_svg(pd.read_parquet(INPUT)), encoding="utf-8")
    print(f"Dashboard preview written to {OUTPUT}")


if __name__ == "__main__":
    main()
