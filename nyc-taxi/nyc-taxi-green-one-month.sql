LOAD TABLE nyc_taxi.nyc_taxi_trips_green
    FROM ('/csv_backup/green_tripdata_2020-01.csv')
    EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
    EXTERNAL FORMAT nyc_taxi.nyc_taxi_trips_green_yellow_format
    WITH (max_bad_rows '-1')
