SELECT (dropoff_datetime - pickup_datetime)::VARCHAR(max) AS trip_duration
FROM nyc_taxi.nyc_taxi_trips_fhvhv
ORDER BY 1 DESC LIMIT 10;
