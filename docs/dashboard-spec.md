# Dashboard specification

This specification is deliberately outcome-first: each visual must help a road-safety or operations stakeholder choose where to investigate or intervene.

## Page 1 — Executive safety overview

**Audience:** road-safety leadership.

- KPI cards: accidents, fatal accidents, deaths, deaths per 100 accidents, severe injuries.
- Monthly accident trend with a prior-year comparison.
- State severity matrix: accident volume, deaths, fatality rate, and deaths per 100 accidents.
- Top-10 locations by deaths, with a tooltip showing volume and fatality rate.
- Global slicers: year, state, city, road type, accident type.

**Decision supported:** choose the highest-priority state/city based on both impact and risk.

## Page 2 — Geographic hotspots

**Audience:** regional safety managers.

- Filled map at state level; use a city-level map only when approved coordinates are available.
- Scatter plot: accident volume (x), deaths per 100 accidents (y), bubble size = deaths. The upper-right quadrant identifies high-impact, high-risk areas.
- Drill-through table by city, road type, and handling unit.

**Guardrail:** maps must not imply precision beyond the source geography. Do not plot city centroids as individual accident locations.

## Page 3 — Contributing factors & severity

**Audience:** safety analysts and intervention owners.

- Pareto chart of accident causes by deaths.
- Matrix of accident type × road type coloured by deaths per 100 accidents.
- Monthly seasonality heatmap: month × weekday, with toggle between accidents and fatal accidents.
- Decomposition tree: deaths → state → city → cause → accident type.

**Decision supported:** identify factor combinations that warrant targeted enforcement, engineering, or education initiatives.

## Measure definitions (DAX-ready)

```DAX
Accidents = COUNTROWS(fact_accident)
Deaths = SUM(fact_accident[deaths])
Fatal Accidents = CALCULATE([Accidents], fact_accident[deaths] > 0)
Fatality Rate = DIVIDE([Fatal Accidents], [Accidents])
Deaths per 100 Accidents = 100 * DIVIDE([Deaths], [Accidents])
Severe Injury Rate = DIVIDE(SUM(fact_accident[severely_injured]), SUM(fact_accident[people_involved]))
```

Format rates as percentages except `Deaths per 100 Accidents`. Always display the denominator or count in tooltips.
