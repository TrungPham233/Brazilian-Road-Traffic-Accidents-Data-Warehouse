# Dashboard Specification — Brazilian Road Traffic Accidents

This specification defines the 5-page analytical Power BI report designed for road-safety authorities, transport policy makers, and highway patrol commanders.

---

## Page 1 — Executive Safety Overview

**Audience:** Road Safety Leadership, Federal Highway Police (PRF) Directorate.

- **KPI Cards:**
  - `Total Accidents`: Total count of recorded accidents (`COUNTROWS(Fact)`).
  - `Total Fatalities`: Total death count (`SUM(Fact[deaths])`).
  - `Severe Injuries`: Count of severe injury victims (`SUM(Fact[severely_injured])`).
  - `Fatal Accidents`: Count of accidents with $\ge 1$ death (`CALCULATE(COUNTROWS(Fact), Fact[deaths] > 0)`).
- **Key Visuals:**
  - **Accident Volume & Deaths Trend (Line & Clustered Column Combo):** Annual accident volume (bars) vs death count (line) from 2017 to 2023.
  - **Top States by Fatalities (Clustered Bar Chart):** States with the highest absolute fatalities (Minas Gerais, Bahia, Paraná...).
  - **Deaths per 100 Accidents by Type (Clustered Bar Chart):** Highlighting lethal collision types (e.g. Head-on collision carrying $\approx 37.2$ deaths per 100 accidents).
  - **Yearly Severity Overview (Matrix):** Tabular year-over-year summary of volume, deaths, injuries, and fatality rate.
- **Global Slicers:** Year dropdown (top-right), State dropdown (sidebar).

---

## Page 2 — Geographic Hotspots

**Audience:** Regional Highway Patrol Superintendents, State Transport Departments.

- **KPI Cards:**
  - `Total Fatalities`
  - `Total Accidents`
  - `Severe Injuries`
  - `Deaths per 100 Accidents`
- **Key Visuals:**
  - **Fatalities by State (UF) (Clustered Bar Chart):** Distribution of road fatalities across all 27 Brazilian states.
  - **Top 10 Cities with Highest Fatalities (Clustered Bar Chart):** Urban centers and highway corridors requiring priority patrols (Curitiba, Brasília, São Paulo...).
  - **Accidents by PRF Regional Unit (Clustered Bar Chart):** Workload and incident density across police regional commands.
  - **Police Station Hotspot Summary (Matrix):** Operational breakdown by specific PRF police stations (`Delegacia`).
- **Global Slicers:** Year dropdown (top-right), State dropdown (sidebar).

---

## Page 3 — Causes & Severity

**Audience:** Safety Analysts, Driver Education Campaigners, Enforcement Teams.

- **KPI Cards:**
  - `Total Fatalities`
  - `Fatal Accidents`
  - `Severe Injuries`
  - `Vehicles Involved`: Total vehicle exposure involved in incidents.
- **Key Visuals:**
  - **Top Accident Causes by Fatalities (Clustered Bar Chart):** Rank of causes leading to deaths (Lack of driver attention, lane invasion, speeding...).
  - **Fatalities by Accident Type (Clustered Bar Chart):** Comparison of collision types (Colisão frontal, atropelamento, saída de pista...).
  - **Accident Volume by Cause (Clustered Bar Chart):** High-frequency causes vs high-mortality causes.
  - **Accident Type Severity Breakdown (Matrix):** Comprehensive metrics matrix for each accident typology.
- **Global Slicers:** Year dropdown (top-right), Accident Type dropdown (sidebar).

---

## Page 4 — Road & Infrastructure Conditions

**Audience:** Civil Engineers, Highway Concessionaires, Infrastructure Regulators (DNIT/ANTT).

- **KPI Cards:**
  - `Deaths (Dupla)`: Fatalities occurring on dual carriageways.
  - `Deaths (Simples)`: Fatalities occurring on single carriageways.
  - `Accidents on Curva`: Incidents on curved road sections.
  - `Accidents on Reta`: Incidents on straight road sections.
- **Key Visuals:**
  - **Accident Volume by Road Type (Clustered Column Chart):** Distribution across Single (`Simples`), Dual (`Dupla`), and Multiple (`Múltipla`) lane highways.
  - **Fatalities by Road Delineation (Clustered Bar Chart):** Fatalities on straight sections, sharp curves, intersections, and bridges.
  - **Deaths per 100 Acc by Delineation (Clustered Bar Chart):** Comparative lethality index across geometric road profiles.
  - **Road Infrastructure Risk Matrix (Matrix):** Cross-tabulation of road type vs accident volume and severity.
- **Global Slicers:** Year dropdown (top-right), Road Type dropdown (sidebar).

---

## Page 5 — Time & Seasonality Patterns

**Audience:** Tactical Patrol Scheduling, Holiday Safety Operation Planners.

- **KPI Cards:**
  - `Total Accidents`
  - `Total Fatalities`
  - `People Involved`
  - `Vehicles Involved`
- **Key Visuals:**
  - **Monthly Accidents Across Years (Multi-line Chart):** Seasonality trends tracking 12 calendar months over 7 consecutive years (2017–2023).
  - **Fatalities by Month (Clustered Column Chart):** Identification of high-risk months (December holiday travel, July vacation, Carnival).
  - **Accidents by Day of Month (Clustered Column Chart):** Intra-month distribution and weekend surge detection.
  - **Annual Accident & Fatalities Breakdown (Matrix):** Full year-over-year operational ledger.
- **Global Slicers:** Year dropdown (top-right), Month dropdown (sidebar).

---

## Core DAX Measure Formulas

```DAX
// 1. Base Volume
Accidents = COUNTROWS('Fact')

// 2. Casualties
Deaths = SUM('Fact'[deaths])
Severe Injuries = SUM('Fact'[severely_injured])
Slight Injuries = SUM('Fact'[slightly_injured])
Total People Involved = SUM('Fact'[people_involved])
Total Vehicles = SUM('Fact'[vehicles_involved])

// 3. Severity Ratios
Fatal Accidents = CALCULATE([Accidents], 'Fact'[deaths] > 0)
Fatal Accident Rate = DIVIDE([Fatal Accidents], [Accidents])
Deaths per 100 Accidents = DIVIDE([Deaths], [Accidents]) * 100

// 4. Infrastructure-Specific
Deaths on Dupla = CALCULATE([Deaths], 'Road_Dimension'[Road_Type] = "Dupla")
Deaths on Simples = CALCULATE([Deaths], 'Road_Dimension'[Road_Type] = "Simples")
Accidents on Curva = CALCULATE([Accidents], 'Road_Dimension'[Road_Delineation] = "Curva")
Accidents on Reta = CALCULATE([Accidents], 'Road_Dimension'[Road_Delineation] = "Reta")
```
