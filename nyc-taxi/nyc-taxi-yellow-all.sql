--- NB: yellow taxi data has mix of CSV for data prior to 2011. LOAD known parquet sources here
LOAD TABLE nyc_taxi.nyc_taxi_trips_yellow
  FROM (
    'trip data/yellow_tripdata_2011',
    'trip data/yellow_tripdata_2012',
    'trip data/yellow_tripdata_2013',
    'trip data/yellow_tripdata_2014',
    'trip data/yellow_tripdata_2015',
    'trip data/yellow_tripdata_2016',
    'trip data/yellow_tripdata_2017',
    'trip data/yellow_tripdata_2018',
    'trip data/yellow_tripdata_2019',
    'trip data/yellow_tripdata_202'
  )  EXTERNAL LOCATION nyc_taxi_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );
