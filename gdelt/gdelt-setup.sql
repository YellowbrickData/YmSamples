DROP SCHEMA IF EXISTS gdelt CASCADE;
CREATE SCHEMA gdelt;
GRANT ALL ON SCHEMA gdelt TO PUBLIC;

-- Create tables and load lookups

CREATE TABLE gdelt.events (
  globaleventid INT,
  day INT,
  monthyear INT,
  year INT,
  fractiondate FLOAT,
  actor1code VARCHAR(max),
  actor1name VARCHAR(max),
  actor1countrycode VARCHAR(max),
  actor1knowngroupcode VARCHAR(max),
  actor1ethniccode VARCHAR(max),
  actor1religion1code VARCHAR(max),
  actor1religion2code VARCHAR(max),
  actor1type1code VARCHAR(max),
  actor1type2code VARCHAR(max),
  actor1type3code VARCHAR(max),
  actor2code VARCHAR(max),
  actor2name VARCHAR(max),
  actor2countrycode VARCHAR(max),
  actor2knowngroupcode VARCHAR(max),
  actor2ethniccode VARCHAR(max),
  actor2religion1code VARCHAR(max),
  actor2religion2code VARCHAR(max),
  actor2type1code VARCHAR(max),
  actor2type2code VARCHAR(max),
  actor2type3code VARCHAR(max),
  isrootevent BOOLEAN,
  eventcode VARCHAR(max),
  eventbasecode VARCHAR(max),
  eventrootcode VARCHAR(max),
  quadclass INT,
  goldsteinscale FLOAT,
  nummentions INT,
  numsources INT,
  numarticles INT,
  avgtone FLOAT,
  actor1geo_type INT,
  actor1geo_fullname VARCHAR(max),
  actor1geo_countrycode VARCHAR(max),
  actor1geo_adm1code VARCHAR(max),
  actor1geo_lat FLOAT,
  actor1geo_long FLOAT,
  actor1geo_featureid INT,
  actor2geo_type INT,
  actor2geo_fullname VARCHAR(max),
  actor2geo_countrycode VARCHAR(max),
  actor2geo_adm1code VARCHAR(max),
  actor2geo_lat FLOAT,
  actor2geo_long FLOAT,
  actor2geo_featureid INT,
  actiongeo_type INT,
  actiongeo_fullname VARCHAR(max),
  actiongeo_countrycode VARCHAR(max),
  actiongeo_adm1code VARCHAR(max),
  actiongeo_lat FLOAT,
  actiongeo_long FLOAT,
  actiongeo_featureid INT,
  dateadded INT,
  sourceurl VARCHAR(max))
DISTRIBUTE RANDOM;
GRANT ALL ON TABLE gdelt.events TO public;

CREATE TABLE gdelt.eventcodes (code VARCHAR(max), description VARCHAR(max)) DISTRIBUTE REPLICATE;
GRANT ALL ON TABLE gdelt.eventcodes TO public;
\COPY gdelt.eventcodes FROM './eventcodes.txt' WITH CSV HEADER DELIMITER E'\t';
YFLUSH gdelt.eventcodes;

CREATE TABLE gdelt.types (type VARCHAR(max), description VARCHAR(max)) DISTRIBUTE REPLICATE;
GRANT ALL ON TABLE gdelt.types TO public;
\COPY gdelt.types FROM './types.txt' WITH CSV HEADER DELIMITER E'\t';
YFLUSH gdelt.types;

CREATE TABLE gdelt.groups (_group VARCHAR(max), description VARCHAR(max)) DISTRIBUTE REPLICATE;
GRANT ALL ON TABLE gdelt.groups TO public;
\COPY gdelt.groups FROM './groups.txt' WITH CSV HEADER DELIMITER E'\t';
YFLUSH gdelt.groups;

CREATE TABLE gdelt.countries (code VARCHAR(max), country VARCHAR(max)) DISTRIBUTE REPLICATE;
GRANT ALL ON TABLE gdelt.countries TO public;
\COPY gdelt.countries FROM './countries.txt' WITH CSV HEADER DELIMITER E'\t';
YFLUSH gdelt.countries;

-- Setup EXTERNAL objects
CREATE EXTERNAL STORAGE gdelt.gdelt_storage
  TYPE s3
  ENDPOINT 'https://s3.us-east-1.amazonaws.com/'
  REGION 'us-east-1';
GRANT ALL ON EXTERNAL STORAGE gdelt.gdelt_storage TO public;

CREATE EXTERNAL FORMAT gdelt.gdelt_format
  TYPE text
  WITH (
      delimiter '\t'
    , num_header_lines 0
    , on_invalid_char 'REPLACE'
    , on_unescaped_embedded_quote 'PRESERVE'
    , on_missing_field 'SUPPLYNULL'
    , on_extra_field 'REMOVE'
  );
GRANT ALL ON EXTERNAL FORMAT gdelt.gdelt_format TO public;

CREATE EXTERNAL LOCATION gdelt.gdelt_location
  PATH 'gdelt-open-data'
  EXTERNAL STORAGE gdelt.gdelt_storage
  EXTERNAL FORMAT gdelt.gdelt_format;
GRANT ALL ON EXTERNAL LOCATION gdelt.gdelt_location TO public;
