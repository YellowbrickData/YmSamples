DROP SCHEMA IF EXISTS openaq CASCADE;
CREATE SCHEMA openaq;
GRANT ALL ON SCHEMA openaq TO PUBLIC;

CREATE TABLE openaq.measurements(
  city varchar(max),
  value varchar(max),
  unit varchar(max),
  parameter varchar(max),
  country varchar(max),
  region varchar(max),
  provider varchar(max),
  date_utc varchar(max),
  date_local varchar(max),
  authority varchar(max),
  col5_unknown varchar(max),
  latitude varchar(max),
  longitude varchar(max),
  period varchar(max),
  measure varchar(max)
)
DISTRIBUTE RANDOM;
GRANT ALL ON TABLE openaq.measurements TO public;

CREATE EXTERNAL STORAGE openaq.openaq_storage
  TYPE s3
  ENDPOINT 'https://s3.us-east-1.amazonaws.com/'
  REGION 'us-east-1';
GRANT ALL ON EXTERNAL STORAGE openaq.openaq_storage TO public;

CREATE EXTERNAL FORMAT openaq.openaq_format
  TYPE csv
  WITH (
      delimiter ','
    , num_header_lines 0
    , escape_char 'י'
    , on_invalid_char 'REPLACE'
    , on_unescaped_embedded_quote 'PRESERVE'
    , on_missing_field 'SUPPLYNULL'
    , on_extra_field 'REMOVE'
  );
GRANT ALL ON EXTERNAL FORMAT openaq.openaq_format TO public;

CREATE EXTERNAL LOCATION openaq.openaq_location
  PATH 'openaq-fetches'
  EXTERNAL STORAGE openaq.openaq_storage
  EXTERNAL FORMAT openaq.openaq_format;
GRANT ALL ON EXTERNAL LOCATION openaq.openaq_location TO public;
