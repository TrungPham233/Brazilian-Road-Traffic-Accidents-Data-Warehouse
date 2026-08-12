# Data profile & analytical notes

## Snapshot

| Item | Result |
| --- | ---: |
| Source records | 463,152 |
| Accepted analytical records | 462,478 |
| Excluded records | 674 (0.15%) |
| Date coverage | 01 Jan 2017–31 Aug 2023 |
| Recorded deaths | 36,695 |
| Recorded severe injuries | 120,173 |
| Fatal accidents | 31,341 |

The snapshot was generated from `accidents_2017_to_2023_english.csv` using `python -m src.etl`.

## Quality assessment

The ETL rejects a record when its date, state, or city is unavailable, because these attributes are essential to the model grain and core analysis. Descriptive dimensions with missing values are represented as `Unknown`, not dropped. All retained measure columns are non-negative integers and the final extract has no null values in warehouse fields.

The result is suitable for aggregated descriptive analysis. It should not be used as evidence of causal effects, because exposure variables—such as traffic volume, road length, population, or enforcement intensity—are not included.

## Priority insights

### Separate impact from risk

Minas Gerais has the highest absolute death count (4,828). However, Bahia records 14.09 deaths per 100 accidents, compared with 7.88 in Minas Gerais. A prioritisation framework should therefore show both measures: one identifies scale of harm; the other identifies severity conditional on a reported accident.

### Head-on collisions deserve a dedicated view

Head-on collisions account for 11,236 deaths in 30,236 accidents—37.16 deaths per 100 accidents. This is the highest death intensity among accident types with at least 100 records, making it a strong candidate for a dedicated investigation page segmented by state, road type, and road delineation.

### Avoid ranking causes on volume alone

*Driver's lack of attention to conveyance* has the most deaths (5,730) because it is common (107,534 accidents). Other causes may have much higher fatality rates but lower counts. The dashboard therefore uses a minimum-volume threshold for rate rankings and always presents the denominator in tooltips.

## Interpretation guardrails

- **2023 is incomplete:** its observations end on 31 August. Never compare its annual total directly with complete years without normalising to the same period.
- **Reported-accident denominator:** a death rate here is deaths per recorded accident, not risk per vehicle-kilometre or per resident.
- **Geographic precision:** state and city fields support aggregate regional analysis. Do not represent city centroids as exact crash locations.
- **Contributing cause is not causation:** source labels should be read as recorded classifications, not as independently validated causal mechanisms.
