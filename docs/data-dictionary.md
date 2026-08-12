# Data dictionary

## Fact table: `dw.fact_accident`

**Grain:** one source accident record. The warehouse does not model individual people or vehicles; counts are measures attached to the accident.

| Column | Type | Description |
| --- | --- | --- |
| `accident_key` | bigint | Warehouse surrogate key. |
| `source_accident_id` | bigint | Stable identifier emitted by the ETL extract. |
| `date_key` | int | Date dimension key in `YYYYMMDD` format. |
| `location_key`–`handling_unit_key` | int | Foreign keys to descriptive dimensions. |
| `people_involved` | integer | Total people involved in the accident. |
| `deaths` | integer | Deaths recorded for the accident. |
| `slightly_injured` | integer | Slight injuries recorded. |
| `severely_injured` | integer | Severe injuries recorded. |
| `uninjured` / `ignored` | integer | People uninjured or with an unrecorded outcome. |
| `vehicles_involved` | integer | Vehicles involved. |

## Dimensions

| Table | Natural business key | Main attributes | Purpose |
| --- | --- | --- | --- |
| `dim_date` | calendar date | year, quarter, month, day, weekday | Time trend and seasonality. |
| `dim_location` | state + city | state, city | Geographic hotspots and drill-down. |
| `dim_road` | road type + delineation | road type, road delineation | Road environment risk comparison. |
| `dim_cause` | cause text | cause of accident | Contributing-factor analysis. |
| `dim_accident_type` | accident type text | type of accident | Collision/severity analysis. |
| `dim_handling_unit` | regional + police station | regional, police station | Operational jurisdiction analysis. |

## Data-quality rules

- Records without a valid accident date, state, or city are excluded because they cannot be placed reliably in the core analytical model.
- Missing descriptive values are normalised to `Unknown`; the fact remains available for totals.
- Count measures are parsed as integers; null/invalid values become `0`, and negative values are clipped to `0`.
- Exact duplicate records are removed before keys are generated.
- The ETL writes `quality_report.json` so acceptance/rejection counts are auditable.
