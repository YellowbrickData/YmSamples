DROP SCHEMA IF EXISTS nyc_taxi CASCADE;
CREATE SCHEMA nyc_taxi;
GRANT ALL ON SCHEMA nyc_taxi TO PUBLIC;

CREATE TABLE nyc_taxi.nyc_taxi_trips_fhv (
  "pickup_datetime" VARCHAR(max) NULL,
  "dropoff_datetime" VARCHAR(max) NULL,
  "PULocationID" VARCHAR(max) NULL,
  "DOLocationID" VARCHAR(max) NULL,
  "SR_Flag" VARCHAR(max) NULL,
  "Dispatching_base_number" VARCHAR(max) NULL,
  "dispatching_base_num" VARCHAR(max) NULL
);
GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_fhv TO public;

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

CREATE TABLE nyc_taxi.nyc_taxi_trips_green
(
    "VendorID"  VARCHAR(max),
    "lpep_pickup_datetime" VARCHAR(max),
    "Lpep_dropoff_datetime"  VARCHAR(max),
    "Store_and_fwd_flag" VARCHAR(max),
    "RateCodeID" VARCHAR(max),
    "Pickup_longitude" VARCHAR(max),
    "Pickup_Latitude" VARCHAR(max),
    "Dropoff_longitude" VARCHAR(max),
    "Dropoff_latitude" VARCHAR(max),
    "Passenger_count" VARCHAR(max),
    "Trip_distance" VARCHAR(max),
    "Fare_amount" VARCHAR(max),
    "Extra" VARCHAR(max),
    "MTA_tax" VARCHAR(max),
    "Tip_amount" VARCHAR(max),
    "Tolls_amount" VARCHAR(max),
    "Ehail_fee" VARCHAR(max),
    "Total_amount" VARCHAR(max),
    "Payment_type" VARCHAR(max),
    "Trip_type" VARCHAR(max)
);

GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_green TO public;

CREATE TABLE nyc_taxi.nyc_taxi_trips_yellow
(
    "vendor_name" VARCHAR(max),
    "Trip_Pickup_Datetime" VARCHAR(max),
    "Trip_Dropoff_Datetime" VARCHAR(max),
    "Passenger_Count" VARCHAR(max),
    "Trip_Distance" VARCHAR(max),
    "Start_Lon" VARCHAR(max),
    "Start_Lat" VARCHAR(max),
    "Rate_Code" VARCHAR(max),
    "store_and_forward" VARCHAR(max),
    "End_lon" VARCHAR(max),
    "End_Lat" VARCHAR(max),
    "Payment_Type" VARCHAR(max),
    "Fare_Amt" VARCHAR(max),
    "surcharge" VARCHAR(max),
    "mta_tax" VARCHAR(max),
    "Tip_Amt" VARCHAR(max),
    "Tolls_Amt" VARCHAR(max),
    "Total_Amt" VARCHAR(max)
);

GRANT ALL ON TABLE nyc_taxi.nyc_taxi_trips_yellow TO public;

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

CREATE EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
  PATH 'nyc-tlc'
  EXTERNAL STORAGE nyc_taxi.nyc_taxi_storage
  EXTERNAL FORMAT nyc_taxi.nyc_taxi_format;
GRANT ALL ON EXTERNAL LOCATION nyc_taxi.nyc_taxi_location TO public;


CREATE EXTERNAL FORMAT nyc_taxi.nyc_taxi_trips_green_yellow_format TYPE csv WITH (delimiter ',', nullmarker '"', num_header_lines '1', trim_white 'true', on_extra_field 'REMOVE', on_missing_field 'SUPPLYNULL', skip_blank_lines 'true')

GRANT ALL ON EXTERNAL FORMAT nyc_taxi.nyc_taxi_trips_green_yellow_format TO public;
