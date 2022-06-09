LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  FROM ('/trip data/fhv_tripdata_2019-01.parquet')
  EXTERNAL LOCATION nyc_taxi_location
  WITH (
    max_bad_rows '-1' );
