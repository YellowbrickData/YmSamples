LOAD TABLE nyc_taxi.nyc_taxi_trips_fhvhv
  FROM ('nyc-taxi/fhvhv_tripdata')
  EXTERNAL LOCATION nyc_taxi_location
  WITH (
    num_readers '10',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );

