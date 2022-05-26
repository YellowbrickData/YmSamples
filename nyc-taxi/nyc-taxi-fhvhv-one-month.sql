LOAD TABLE nyc_taxi.nyc_taxi_trips_fhvhv
  FROM ('/csv_backup/fhvhv_tripdata_2019-02.csv')
  EXTERNAL LOCATION nyc_taxi_location
  WITH (
    max_bad_rows '-1' );

