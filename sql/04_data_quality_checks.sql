-- ==============================================================================
-- Brazilian Road Accident Intelligence — Data Warehouse Quality Assertions
-- Runs 15 verification checks on the star schema in PostgreSQL
-- ==============================================================================

-- 1. Fact table completeness (Must not be empty)
SELECT 'Fact table not empty' AS check_name,
       COUNT(*) AS total_rows,
       CASE WHEN COUNT(*) > 400000 THEN 'PASS' ELSE 'FAIL' END AS status
FROM dw.fact_accident;

-- 2. No null foreign keys in fact table
SELECT 'Fact FK Nullability' AS check_name,
       COUNT(*) FILTER (WHERE date_key IS NULL OR location_key IS NULL OR road_key IS NULL 
                           OR cause_key IS NULL OR accident_type_key IS NULL OR handling_unit_key IS NULL) AS null_fk_count,
       CASE WHEN COUNT(*) FILTER (WHERE date_key IS NULL OR location_key IS NULL OR road_key IS NULL 
                                     OR cause_key IS NULL OR accident_type_key IS NULL OR handling_unit_key IS NULL) = 0 
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM dw.fact_accident;

-- 3. Non-negative numeric measures
SELECT 'Non-negative measures' AS check_name,
       COUNT(*) FILTER (WHERE deaths < 0 OR severely_injured < 0 OR slightly_injured < 0 
                           OR uninjured < 0 OR people_involved < 0 OR vehicles_involved < 0) AS invalid_rows,
       CASE WHEN COUNT(*) FILTER (WHERE deaths < 0 OR severely_injured < 0 OR slightly_injured < 0 
                                     OR uninjured < 0 OR people_involved < 0 OR vehicles_involved < 0) = 0 
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM dw.fact_accident;

-- 4. Referential integrity: Fact -> Date Dimension
SELECT 'RI Fact -> Dim Date' AS check_name,
       COUNT(*) AS orphaned_records,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM dw.fact_accident f
LEFT JOIN dw.dim_date d USING (date_key)
WHERE d.date_key IS NULL;

-- 5. Referential integrity: Fact -> Location Dimension
SELECT 'RI Fact -> Dim Location' AS check_name,
       COUNT(*) AS orphaned_records,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM dw.fact_accident f
LEFT JOIN dw.dim_location l USING (location_key)
WHERE l.location_key IS NULL;

-- 6. Referential integrity: Fact -> Road Dimension
SELECT 'RI Fact -> Dim Road' AS check_name,
       COUNT(*) AS orphaned_records,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM dw.fact_accident f
LEFT JOIN dw.dim_road r USING (road_key)
WHERE r.road_key IS NULL;

-- 7. Referential integrity: Fact -> Cause Dimension
SELECT 'RI Fact -> Dim Cause' AS check_name,
       COUNT(*) AS orphaned_records,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM dw.fact_accident f
LEFT JOIN dw.dim_cause c USING (cause_key)
WHERE c.cause_key IS NULL;

-- 8. Referential integrity: Fact -> Accident Type Dimension
SELECT 'RI Fact -> Dim Accident Type' AS check_name,
       COUNT(*) AS orphaned_records,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM dw.fact_accident f
LEFT JOIN dw.dim_accident_type t USING (accident_type_key)
WHERE t.accident_type_key IS NULL;

-- 9. Referential integrity: Fact -> Handling Unit Dimension
SELECT 'RI Fact -> Dim Handling Unit' AS check_name,
       COUNT(*) AS orphaned_records,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM dw.fact_accident f
LEFT JOIN dw.dim_handling_unit h USING (handling_unit_key)
WHERE h.handling_unit_key IS NULL;

-- 10. Date range coverage (2017 to 2023)
SELECT 'Date coverage (2017-2023)' AS check_name,
       MIN(full_date) AS min_date,
       MAX(full_date) AS max_date,
       CASE WHEN MIN(full_date) = '2017-01-01' AND MAX(full_date) >= '2023-08-31' THEN 'PASS' ELSE 'FAIL' END AS status
FROM dw.dim_date;

-- 11. Geographic coverage: All 27 Brazilian states present
SELECT 'Geographic coverage: 27 states' AS check_name,
       COUNT(DISTINCT state) AS state_count,
       CASE WHEN COUNT(DISTINCT state) = 27 THEN 'PASS' ELSE 'FAIL' END AS status
FROM dw.dim_location;

