LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  FROM ('/trip data/fhv_tripdata_2017')
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );

