DROP SCHEMA IF EXISTS noaa_ghcn_pds CASCADE;
CREATE SCHEMA noaa_ghcn_pds;
GRANT ALL ON SCHEMA noaa_ghcn_pds TO PUBLIC;

CREATE TABLE noaa_ghcn_pds.staging (
  line VARCHAR(max)
);

CREATE TABLE noaa_ghcn_pds.observations(
  id varchar(11),
  year_date int,
  element varchar(max),
  data_value float,
  m_flag varchar(max),
  q_flag varchar(max),
  s_flag varchar(max),
  obs_time varchar(max)
)
DISTRIBUTE RANDOM;
GRANT ALL ON TABLE noaa_ghcn_pds.observations TO public;

-- Doc: https://docs.opendata.aws/noaa-ghcn-pds/readme.html
CREATE TABLE noaa_ghcn_pds.stations(
  id varchar(11),              -- ID	1-11	Character	EI000003980
  latitude float,              -- LATITUDE	13-20	Real	55.3717
  longitude float,             -- LONGITUDE	22-30	Real	-7.3400
  elevation float,             -- ELEVATION	32-37	Real	21.0
  state varchar(2),            -- STATE	39-40	Character
  name varchar(30),            -- NAME	42-71	Character	MALIN HEAD
  gsn_flag varchar(3),         -- GSN FLAG	73-75	Character	GSN
  hcn_crn_flag varchar(3),     -- HCN/CRN FLAG	77-79	Character
  wmo_id varchar(4)            -- WMO ID	81-85	Character	03980
)
DISTRIBUTE REPLICATE;
GRANT ALL ON TABLE noaa_ghcn_pds.stations TO public;

CREATE TABLE noaa_ghcn_pds.countries(
  id varchar(2),              -- ID	1-2
  name varchar(max)           -- the rest
)
DISTRIBUTE REPLICATE;
GRANT ALL ON TABLE noaa_ghcn_pds.countries TO public;

CREATE TABLE noaa_ghcn_pds.states(
  id varchar(2),              -- ID	1-2
  name varchar(max)           -- the rest
)
DISTRIBUTE REPLICATE;
GRANT ALL ON TABLE noaa_ghcn_pds.states TO public;

CREATE EXTERNAL STORAGE noaa_ghcn_pds.noaa_ghcn_pds_storage
  TYPE s3
  ENDPOINT 'https://s3.us-east-1.amazonaws.com/'
  REGION 'us-east-1';
GRANT ALL ON EXTERNAL STORAGE noaa_ghcn_pds.noaa_ghcn_pds_storage TO public;

CREATE EXTERNAL FORMAT noaa_ghcn_pds.noaa_ghcn_pds_format
  TYPE csv
  WITH (
      delimiter ','
    , num_header_lines 0
    , on_invalid_char 'REPLACE'
    , on_unescaped_embedded_quote 'PRESERVE'
    , on_missing_field 'SUPPLYNULL'
    , on_extra_field 'REMOVE'
    , on_string_too_long 'TRUNCATE'
  );
GRANT ALL ON EXTERNAL FORMAT noaa_ghcn_pds.noaa_ghcn_pds_format TO public;

CREATE EXTERNAL LOCATION noaa_ghcn_pds.noaa_ghcn_pds_location
  PATH 'noaa-ghcn-pds'
  EXTERNAL STORAGE noaa_ghcn_pds.noaa_ghcn_pds_storage
  EXTERNAL FORMAT noaa_ghcn_pds.noaa_ghcn_pds_format;
GRANT ALL ON EXTERNAL LOCATION noaa_ghcn_pds.noaa_ghcn_pds_location TO public;
