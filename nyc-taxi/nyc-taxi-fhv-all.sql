LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  FROM ('/trip data/fhv_tripdata')
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location;
