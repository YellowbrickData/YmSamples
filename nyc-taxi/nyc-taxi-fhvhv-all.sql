DROP SCHEMA IF EXISTS nyc_taxi CASCADE;
CREATE SCHEMA nyc_taxi;
GRANT ALL ON SCHEMA nyc_taxi TO PUBLIC;

CREATE TABLE nyc_taxi.nyc_taxi_trips_fhvhv (
  "hvfhs_license_num" VARCHAR(max),
  "dispatching_base_num" VARCHAR(max),
  "pickup_datetime" VARCHAR(max),
  "dropoff_datetime" VARCHAR(max),
  "PULocationID" VARCHAR(max),
  "DOLocationID" VARCHAR(max),
  "SR_Flag" VARCHAR(max)
);
GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_fhvhv TO public;

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

LOAD TABLE nyc_taxi.nyc_taxi_trips_fhvhv
  FROM ('/trip%20data/fhvhv_tripdata')
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location;
