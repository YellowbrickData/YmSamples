LOAD TABLE nyc_taxi.nyc_taxi_trips_green
    FROM ('/trip data/green_tripdata_2013-08.csv')
    EXTERNAL LOCATION nyc_taxi.nyc_taxi_location
    EXTERNAL FORMAT nyc_taxi.nyc_taxi_trips_green_format
    WITH (max_bad_rows '-1')