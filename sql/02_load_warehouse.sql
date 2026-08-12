-- Run after \copy data/processed/accidents_clean.csv into stg_accident.
-- Example psql command (adjust absolute path):
-- \copy stg_accident FROM '.../data/processed/accidents_clean.csv' CSV HEADER;

CREATE SCHEMA IF NOT EXISTS stg;
DROP TABLE IF EXISTS stg.accident;
CREATE TABLE stg.accident (
  accident_id bigint, date_of_accident date, state text, city text, road_type text,
  road_delineation text, cause_of_accident text, type_of_accident text, regional text,
  police_station text, people_involved integer, deaths integer, slightly_injured integer,
  severely_injured integer, uninjured integer, ignored integer, vehicles_involved integer,
  year smallint, month smallint, day smallint, day_of_week text
);

INSERT INTO dw.dim_date (date_key, full_date, year, quarter, month, day, day_of_week)
SELECT DISTINCT to_char(date_of_accident, 'YYYYMMDD')::int, date_of_accident, year,
       EXTRACT(QUARTER FROM date_of_accident)::smallint, month, day, day_of_week
FROM stg.accident ON CONFLICT (date_key) DO NOTHING;

INSERT INTO dw.dim_location (state, city)
SELECT DISTINCT state, city FROM stg.accident ON CONFLICT (state, city) DO NOTHING;
INSERT INTO dw.dim_road (road_type, road_delineation)
SELECT DISTINCT road_type, road_delineation FROM stg.accident ON CONFLICT (road_type, road_delineation) DO NOTHING;
INSERT INTO dw.dim_cause (cause_of_accident)
SELECT DISTINCT cause_of_accident FROM stg.accident ON CONFLICT (cause_of_accident) DO NOTHING;
INSERT INTO dw.dim_accident_type (type_of_accident)
SELECT DISTINCT type_of_accident FROM stg.accident ON CONFLICT (type_of_accident) DO NOTHING;
INSERT INTO dw.dim_handling_unit (regional, police_station)
SELECT DISTINCT regional, police_station FROM stg.accident ON CONFLICT (regional, police_station) DO NOTHING;

INSERT INTO dw.fact_accident (
  source_accident_id, date_key, location_key, road_key, cause_key, accident_type_key,
  handling_unit_key, people_involved, deaths, slightly_injured, severely_injured,
  uninjured, ignored, vehicles_involved
)
SELECT s.accident_id, to_char(s.date_of_accident, 'YYYYMMDD')::int, l.location_key,
       r.road_key, c.cause_key, t.accident_type_key, h.handling_unit_key,
       s.people_involved, s.deaths, s.slightly_injured, s.severely_injured,
       s.uninjured, s.ignored, s.vehicles_involved
FROM stg.accident s
JOIN dw.dim_location l ON (l.state, l.city) = (s.state, s.city)
JOIN dw.dim_road r ON (r.road_type, r.road_delineation) = (s.road_type, s.road_delineation)
JOIN dw.dim_cause c ON c.cause_of_accident = s.cause_of_accident
JOIN dw.dim_accident_type t ON t.type_of_accident = s.type_of_accident
JOIN dw.dim_handling_unit h ON (h.regional, h.police_station) = (s.regional, s.police_station)
ON CONFLICT (source_accident_id) DO NOTHING;
