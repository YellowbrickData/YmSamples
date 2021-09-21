-- NB: green taxi data changed schema in 2016
LOAD TABLE nyc_taxi.nyc_taxi_trips_green
  FROM (
    'trip data/green_tripdata_2017',
    'trip data/green_tripdata_2018',
    'trip data/green_tripdata_2019',
    'trip data/green_tripdata_202'
  )
  EXTERNAL LOCATION nyc_taxi_location
  EXTERNAL FORMAT nyc_taxi_trips_green_yellow_format
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );
