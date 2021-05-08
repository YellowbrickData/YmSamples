DROP SCHEMA IF EXISTS nyc_taxi CASCADE;
CREATE SCHEMA nyc_taxi;
GRANT ALL ON SCHEMA nyc_taxi TO PUBLIC;

CREATE TABLE nyc_taxi.nyc_taxi_trips_fhv (
  "dispatching_base_num" VARCHAR(max) NULL,
  "pickup_datetime" TIMESTAMP NULL,
  "dropoff_datetime" TIMESTAMP NULL,
  "pu_location_id" VARCHAR(max) NULL,
  "do_location_id" VARCHAR(max) NULL,
  "sr_flag" VARCHAR(max) NULL
);
GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_fhv TO public;

CREATE TABLE nyc_taxi.nyc_taxi_trips_fhvhv (
  "hvfhs_license_num" VARCHAR(max),
  "dispatching_base_num" VARCHAR(max),
  "pickup_datetime" TIMESTAMP,
  "dropoff_datetime" TIMESTAMP,
  "pu_location_id" VARCHAR(max),
  "do_location_id" VARCHAR(max),
  "sr_flag" VARCHAR(max)
);
GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_fhvhv TO public;

CREATE TABLE nyc_taxi.nyc_taxi_trips_green
(
  -- VendorID,lpep_pickup_datetime,lpep_dropoff_datetime,store_and_fwd_flag,RatecodeID,PULocationID,DOLocationID,passenger_count,trip_distance,fare_amount,extra,mta_tax,tip_amount,tolls_amount,ehail_fee,improvement_surcharge,total_amount,payment_type,trip_type,congestion_surcharge
  "vendor_id"  VARCHAR(max),
  "lpep_pickup_datetime" TIMESTAMP,
  "lpep_dropoff_datetime"  VARCHAR(max),
  "store_and_fwd_flag" VARCHAR(max),
  "rate_code_id" INTEGER,
  "pu_location_id" INTEGER,
  "do_location_id" INTEGER,
  "passenger_count" INTEGER,
  "trip_distance" DECIMAL(18,2),
  "fare_amount" DECIMAL(18,2),
  "extra" DECIMAL(18,2),
  "mta_tax" DECIMAL(18,2),
  "tip_amount" DECIMAL(18,2),
  "tolls_amount" DECIMAL(18,2),
  "ehail_fee" DECIMAL(18,2),
  "improvement_surcharge" DECIMAL(18,2),
  "total_amount" DECIMAL(18,2),
  "payment_type" VARCHAR(max),
  "trip_type" DECIMAL(18,2),
  "congestion_surcharge" DECIMAL(18,2)
);
GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_green TO public;

CREATE TABLE nyc_taxi.nyc_taxi_trips_yellow
(
  -- VendorID,tpep_pickup_datetime,tpep_dropoff_datetime,passenger_count,trip_distance,RatecodeID,store_and_fwd_flag,PULocationID,DOLocationID,payment_type,fare_amount,extra,mta_tax,tip_amount,tolls_amount,improvement_surcharge,total_amount,congestion_surcharge
  "vendor_id" VARCHAR(max),
  "tpep_pickup_datetime" TIMESTAMP,
  "tpep_dropoff_datetime" TIMESTAMP,
  "passenger_count" INTEGER,
  "trip_distance" DECIMAL(18,2),
  "rate_code_id" INTEGER,
  "store_and_forward_flag" VARCHAR(max),
  "pu_location_id" INTEGER,
  "do_location_id" INTEGER,
  "payment_type" VARCHAR(max),
  "fare_amount" DECIMAL(18,2),
  "extra" DECIMAL(18,2),
  "mta_tax" DECIMAL(18,2),
  "tip_amount" DECIMAL(18,2),
  "tolls_amount" DECIMAL(18,2),
  "improvement_surcharge" DECIMAL(18,2),
  "total_amount" DECIMAL(18,2),
  "congestion_surcharge" DECIMAL(18,2)
);
GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_yellow TO public;

CREATE VIEW nyc_taxi.trips
AS
  SELECT
     vendor_id
   , 'green' AS cab_type
   , lpep_pickup_datetime AS pickup_datetime
   , lpep_dropoff_datetime AS dropoff_datetime
   , store_and_fwd_flag
   , rate_code_id
   , pu_location_id
   , do_location_id
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
     vendor_id
   , 'yellow' AS cab_type
   , tpep_pickup_datetime AS pickup_datetime
   , tpep_dropoff_datetime AS dropoff_datetime
   , store_and_forward_flag AS store_and_fwd_flag
   , rate_code_id
   , pu_location_id
   , do_location_id
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

CREATE EXTERNAL STORAGE nyc_taxi.nyc_taxi_storage
  TYPE s3
  ENDPOINT 'https://s3.us-east-1.amazonaws.com/'
  REGION 'us-east-1';
GRANT ALL ON EXTERNAL STORAGE nyc_taxi.nyc_taxi_storage TO public;

CREATE EXTERNAL FORMAT nyc_taxi.nyc_taxi_format
  TYPE csv
  WITH (
      delimiter ','
    , num_header_lines 1
    , on_missing_field 'SUPPLYNULL'
    , on_extra_field 'REMOVE'
    , on_string_too_long 'TRUNCATE'
  );
GRANT ALL ON EXTERNAL FORMAT nyc_taxi.nyc_taxi_format TO public;

CREATE EXTERNAL FORMAT nyc_taxi.nyc_taxi_trips_green_yellow_format
  TYPE csv
  WITH (
      delimiter ','
    , nullmarker '"'
    , num_header_lines '1'
    , trim_white 'true'
    , on_extra_field 'REMOVE'
    , on_missing_field 'SUPPLYNULL'
    , skip_blank_lines 'true'
  );
GRANT ALL ON EXTERNAL FORMAT nyc_taxi.nyc_taxi_trips_green_yellow_format TO public;

CREATE EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
  PATH 'nyc-tlc'
  EXTERNAL STORAGE nyc_taxi.nyc_taxi_storage
  EXTERNAL FORMAT nyc_taxi.nyc_taxi_format;
GRANT ALL ON EXTERNAL LOCATION nyc_taxi.nyc_taxi_location TO public;

