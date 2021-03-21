DROP SCHEMA IF EXISTS nyc_taxi CASCADE;
CREATE SCHEMA nyc_taxi;
GRANT ALL ON SCHEMA nyc_taxi TO PUBLIC;

CREATE TABLE nyc_taxi.nyc_taxi_trips_fhv (
  "dispatching_base_num" VARCHAR(max) NULL,
  "pickup_datetime" VARCHAR(max) NULL,
  "dropoff_datetime" VARCHAR(max) NULL,
  "PULocationID" VARCHAR(max) NULL,
  "DOLocationID" VARCHAR(max) NULL,
  "SR_Flag" VARCHAR(max) NULL
);
GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_fhv TO public;

CREATE EXTERNAL STORAGE nyc_taxi.nyc_taxi_storage
  TYPE s3
  ENDPOINT 'https://s3.us-east-1.amazonaws.com/'
  REGION 'us-east-1';
GRANT ALL ON EXTERNAL STORAGE nyc_taxi.nyc_taxi_storage TO public;

CREATE EXTERNAL FORMAT nyc_taxi.nyc_taxi_format
  TYPE csv
  WITH (delimiter ',', num_header_lines 1);
GRANT ALL ON EXTERNAL FORMAT nyc_taxi.nyc_taxi_format TO public;

CREATE EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
  PATH 'nyc-tlc'
  EXTERNAL STORAGE nyc_taxi.nyc_taxi_storage
  EXTERNAL FORMAT nyc_taxi.nyc_taxi_format;
GRANT ALL ON EXTERNAL LOCATION nyc_taxi.nyc_taxi_location TO public;

