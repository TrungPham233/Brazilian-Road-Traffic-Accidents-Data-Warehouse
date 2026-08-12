-- 1. State safety priorities: use severity and volume together.
SELECT l.state, COUNT(*) AS accidents, SUM(f.deaths) AS deaths,
       COUNT(*) FILTER (WHERE f.deaths > 0) AS fatal_accidents,
       ROUND(100.0 * SUM(f.deaths) / NULLIF(COUNT(*), 0), 2) AS deaths_per_100_accidents
FROM dw.fact_accident f JOIN dw.dim_location l USING (location_key)
GROUP BY l.state ORDER BY deaths DESC, deaths_per_100_accidents DESC;

-- 2. Causes with high severity. A minimum volume avoids unstable rates.
SELECT c.cause_of_accident, COUNT(*) AS accidents, SUM(f.deaths) AS deaths,
       ROUND(100.0 * COUNT(*) FILTER (WHERE f.deaths > 0) / COUNT(*), 2) AS fatality_rate_pct
FROM dw.fact_accident f JOIN dw.dim_cause c USING (cause_key)
GROUP BY c.cause_of_accident HAVING COUNT(*) >= 100
ORDER BY fatality_rate_pct DESC, deaths DESC;

-- 3. Seasonality by month, across all years.
SELECT d.month, COUNT(*) AS accidents, SUM(f.deaths) AS deaths,
       ROUND(100.0 * SUM(f.deaths) / COUNT(*), 2) AS deaths_per_100_accidents
FROM dw.fact_accident f JOIN dw.dim_date d USING (date_key)
GROUP BY d.month ORDER BY d.month;

-- 4. Road context × accident type risk matrix.
SELECT r.road_type, t.type_of_accident, COUNT(*) AS accidents, SUM(f.deaths) AS deaths,
       ROUND(100.0 * SUM(f.deaths) / COUNT(*), 2) AS deaths_per_100_accidents
FROM dw.fact_accident f
JOIN dw.dim_road r USING (road_key)
JOIN dw.dim_accident_type t USING (accident_type_key)
GROUP BY r.road_type, t.type_of_accident HAVING COUNT(*) >= 50
ORDER BY deaths_per_100_accidents DESC, deaths DESC;

-- 5. Data reconciliation: numeric fact total must equal the loaded source total.
SELECT COUNT(*) AS warehouse_accidents, SUM(deaths) AS warehouse_deaths,
       SUM(people_involved) AS warehouse_people_involved
FROM dw.fact_accident;
