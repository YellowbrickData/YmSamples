DROP SCHEMA IF EXISTS nyc_taxi CASCADE;
CREATE SCHEMA nyc_taxi;
GRANT ALL ON SCHEMA nyc_taxi TO PUBLIC;

CREATE TABLE nyc_taxi.nyc_taxi_trips_fhv (
  "dispatching_base_num" VARCHAR(max) NULL,
  "pickup_datetime" TIMESTAMP NULL,
  "dropoff_datetime" TIMESTAMP NULL,
  "PULocationID" VARCHAR(max) NULL,
  "DOLocationID" VARCHAR(max) NULL,
  "SR_Flag" VARCHAR(max) NULL
);
GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_fhv TO public;

CREATE TABLE nyc_taxi.nyc_taxi_trips_fhvhv (
  "hvfhs_license_num" VARCHAR(max),
  "dispatching_base_num" VARCHAR(max),
  "originating_base_num" VARCHAR(max),
  "request_datetime" TIMESTAMP NULL,
  "on_scene_datetime" TIMESTAMP NULL,
  "pickup_datetime" TIMESTAMP NULL,
  "dropoff_datetime" TIMESTAMP NULL,
  "PULocationID" VARCHAR(max) NULL,
  "DOLocationID" VARCHAR(max) NULL,
  "trip_miles" DOUBLE PRECISION,
  "trip_time" DOUBLE PRECISION,
  "base_passenger_fare" DOUBLE PRECISION,
  "tolls" DOUBLE PRECISION,
  "bcf" DOUBLE PRECISION,
  "sales_tax" DOUBLE PRECISION,
  "congestion_surcharge" DOUBLE PRECISION,
  "airport_fee" DOUBLE PRECISION,
  "tips" DOUBLE PRECISION,
  "driver_pay" DOUBLE PRECISION,
  "shared_request_flag" VARCHAR(max) NULL,
  "shared_match_flag" VARCHAR(max) NULL,
  "access_a_ride_flag" VARCHAR(max) NULL,
  "wav_request_flag" VARCHAR(max) NULL,
  "wav_match_flag" VARCHAR(max) NULL
);
GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_fhvhv TO public;

CREATE TABLE nyc_taxi.nyc_taxi_trips_green
(
  "VendorID"  VARCHAR(max),
  "lpep_pickup_datetime" TIMESTAMP,
  "lpep_dropoff_datetime"  TIMESTAMP,
  "store_and_fwd_flag" VARCHAR(max),
  "RatecodeID" DOUBLE PRECISION,
  "PULocationID" DOUBLE PRECISION,
  "DOLocationID" DOUBLE PRECISION,
  "passenger_count" DOUBLE PRECISION,
  "trip_distance" DOUBLE PRECISION,
  "fare_amount" DOUBLE PRECISION,
  "extra" DOUBLE PRECISION,
  "mta_tax" DOUBLE PRECISION,
  "tip_amount" DOUBLE PRECISION,
  "tolls_amount" DOUBLE PRECISION,
  "ehail_fee" DOUBLE PRECISION,
  "improvement_surcharge" DOUBLE PRECISION,
  "total_amount" DOUBLE PRECISION,
  "payment_type" DOUBLE PRECISION,
  "trip_type" DOUBLE PRECISION,
  "congestion_surcharge" DOUBLE PRECISION
);
GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_green TO public;

CREATE TABLE nyc_taxi.nyc_taxi_trips_yellow
(
  "VendorID" VARCHAR(max),
  "tpep_pickup_datetime" TIMESTAMP,
  "tpep_dropoff_datetime" TIMESTAMP,
  "passenger_count" DOUBLE PRECISION,
  "trip_distance" DOUBLE PRECISION,
  "RatecodeID" DOUBLE PRECISION,
  "store_and_forward_flag" VARCHAR(max),
  "PULocationID" DOUBLE PRECISION,
  "DOLocationID" DOUBLE PRECISION,
  "payment_type" VARCHAR(max),
  "fare_amount" DOUBLE PRECISION,
  "extra" DOUBLE PRECISION,
  "mta_tax" DOUBLE PRECISION,
  "tip_amount" DOUBLE PRECISION,
  "tolls_amount" DOUBLE PRECISION,
  "improvement_surcharge" DOUBLE PRECISION,
  "total_amount" DOUBLE PRECISION,
  "congestion_surcharge" DOUBLE PRECISION
);
GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_yellow TO public;

CREATE VIEW nyc_taxi.trips
AS
  SELECT
    "VendorID" as vendor_id
   , 'green' AS cab_type
   , lpep_pickup_datetime AS pickup_datetime
   , lpep_dropoff_datetime AS dropoff_datetime
   , store_and_fwd_flag
   , "RatecodeID" as rate_code_id
   , "PULocationID" as pu_location_id
   , "DOLocationID" as do_location_id
   , passenger_count
   , trip_distance
   , fare_amount
   , extra
   , mta_tax
   , tip_amount
   , tolls_amount
   , improvement_surcharge
   , total_amount
   , payment_type
  FROM nyc_taxi.nyc_taxi_trips_green

  UNION ALL

  SELECT
    "VendorID" as vendor_id
   , 'yellow' AS cab_type
   , tpep_pickup_datetime AS pickup_datetime
   , tpep_dropoff_datetime AS dropoff_datetime
   , store_and_forward_flag AS store_and_fwd_flag
   , "RatecodeID" as rate_code_id
   , "PULocationID" as pu_location_id
   , "DOLocationID" as do_location_id
   , passenger_count
   , trip_distance
   , fare_amount
   , extra
   , mta_tax
   , tip_amount
   , tolls_amount
   , improvement_surcharge
   , total_amount
   , payment_type
  FROM nyc_taxi.nyc_taxi_trips_yellow
;
GRANT ALL ON VIEW nyc_taxi.trips TO public;
DROP EXTERNAL STORAGE IF EXISTS nyc_taxi_storage CASCADE;
CREATE EXTERNAL STORAGE nyc_taxi_storage
  TYPE s3
  ENDPOINT 'https://s3.us-east-1.amazonaws.com/'
  REGION 'us-east-1';
GRANT ALL ON EXTERNAL STORAGE nyc_taxi_storage TO public;

DROP EXTERNAL FORMAT IF EXISTS nyc_taxi_format;
CREATE EXTERNAL FORMAT nyc_taxi_format
  TYPE parquet
  WITH (
      ignore_unsupported_schema 'true'
    , serialize_nested_as_json 'true'
  );
GRANT ALL ON EXTERNAL FORMAT nyc_taxi_format TO public;

DROP EXTERNAL LOCATION IF EXISTS nyc_taxi_location;
CREATE EXTERNAL LOCATION nyc_taxi_location
  PATH 'nyc-tlc'
  EXTERNAL STORAGE nyc_taxi_storage
  EXTERNAL FORMAT nyc_taxi_format;
GRANT ALL ON EXTERNAL LOCATION nyc_taxi_location TO public;

