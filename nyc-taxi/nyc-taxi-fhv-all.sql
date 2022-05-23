LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  SOURCE FIELDS (
    dispatching_base_num VARCHAR(max),
    pickup_datetime TIMESTAMP,
    pu_location_id VARCHAR(max)
  )
  FROM (
    '/csv_backup/fhv_tripdata_2015',
    '/csv_backup/fhv_tripdata_2016'
  )
  EXTERNAL LOCATION nyc_taxi_location
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
    '/csv_backup/fhv_tripdata_2018'
  )
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );

LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  FROM (
    '/csv_backup/fhv_tripdata_2017',
    '/csv_backup/fhv_tripdata_2019',
    '/csv_backup/fhv_tripdata_202'
  )
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );

