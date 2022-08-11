LOAD TABLE nyc_taxi.nyc_taxi_trips_yellow
    FROM ('nyc-taxi/yellow_tripdata_2020-01.parquet')
    EXTERNAL LOCATION nyc_taxi_location
    WITH (max_bad_rows '-1')
