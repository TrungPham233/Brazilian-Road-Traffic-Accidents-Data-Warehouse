-- PostgreSQL 15+. Re-runnable dimensional model for Brazilian accident analytics.
CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE IF NOT EXISTS dw.dim_date (
    date_key        integer PRIMARY KEY,
    full_date       date NOT NULL UNIQUE,
    year            smallint NOT NULL,
    quarter         smallint NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    month           smallint NOT NULL CHECK (month BETWEEN 1 AND 12),
    day             smallint NOT NULL CHECK (day BETWEEN 1 AND 31),
    day_of_week     varchar(12) NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_location (
    location_key serial PRIMARY KEY, state varchar(100) NOT NULL, city varchar(150) NOT NULL,
    UNIQUE (state, city)
);
CREATE TABLE IF NOT EXISTS dw.dim_road (
    road_key serial PRIMARY KEY, road_type varchar(100) NOT NULL, road_delineation varchar(150) NOT NULL,
    UNIQUE (road_type, road_delineation)
);
CREATE TABLE IF NOT EXISTS dw.dim_cause (
    cause_key serial PRIMARY KEY, cause_of_accident varchar(255) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS dw.dim_accident_type (
    accident_type_key serial PRIMARY KEY, type_of_accident varchar(255) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS dw.dim_handling_unit (
    handling_unit_key serial PRIMARY KEY, regional varchar(150) NOT NULL, police_station varchar(150) NOT NULL,
    UNIQUE (regional, police_station)
);

CREATE TABLE IF NOT EXISTS dw.fact_accident (
    accident_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_accident_id bigint NOT NULL UNIQUE,
    date_key integer NOT NULL REFERENCES dw.dim_date(date_key),
    location_key integer NOT NULL REFERENCES dw.dim_location(location_key),
    road_key integer NOT NULL REFERENCES dw.dim_road(road_key),
    cause_key integer NOT NULL REFERENCES dw.dim_cause(cause_key),
    accident_type_key integer NOT NULL REFERENCES dw.dim_accident_type(accident_type_key),
    handling_unit_key integer NOT NULL REFERENCES dw.dim_handling_unit(handling_unit_key),
    people_involved integer NOT NULL DEFAULT 0 CHECK (people_involved >= 0),
    deaths integer NOT NULL DEFAULT 0 CHECK (deaths >= 0),
    slightly_injured integer NOT NULL DEFAULT 0 CHECK (slightly_injured >= 0),
    severely_injured integer NOT NULL DEFAULT 0 CHECK (severely_injured >= 0),
    uninjured integer NOT NULL DEFAULT 0 CHECK (uninjured >= 0),
    ignored integer NOT NULL DEFAULT 0 CHECK (ignored >= 0),
    vehicles_involved integer NOT NULL DEFAULT 0 CHECK (vehicles_involved >= 0)
);

CREATE INDEX IF NOT EXISTS ix_fact_accident_date ON dw.fact_accident(date_key);
CREATE INDEX IF NOT EXISTS ix_fact_accident_location ON dw.fact_accident(location_key);
CREATE INDEX IF NOT EXISTS ix_fact_accident_cause ON dw.fact_accident(cause_key);
