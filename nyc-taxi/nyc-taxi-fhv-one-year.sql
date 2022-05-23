LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  FROM ('/csv_backup/fhv_tripdata_2019')
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );

