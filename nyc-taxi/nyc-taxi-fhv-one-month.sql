LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  FROM ('/csv_backup/fhv_tripdata_2019-01.csv')
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
  WITH (
    max_bad_rows '-1' );
