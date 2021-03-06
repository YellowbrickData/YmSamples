LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  SOURCE FIELDS (
    dispatching_base_num VARCHAR(max),
    pickup_datetime TIMESTAMP,
    pu_location_id VARCHAR(max)
  )
  FROM (
    '/trip data/fhv_tripdata_2015',
    '/trip data/fhv_tripdata_2016'
  )
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );

LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  SOURCE FIELDS (
    pickup_datetime TIMESTAMP,
    dropoff_datetime TIMESTAMP,
    pu_location_id VARCHAR(max),
    do_location_id VARCHAR(max),
    sr_flag VARCHAR(max),
    dispatching_base_num VARCHAR(max)
  )
  FROM (
    '/trip data/fhv_tripdata_2018'
  )
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );

LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  FROM (
    '/trip data/fhv_tripdata_2017',
    '/trip data/fhv_tripdata_2019',
    '/trip data/fhv_tripdata_202'
  )
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );

