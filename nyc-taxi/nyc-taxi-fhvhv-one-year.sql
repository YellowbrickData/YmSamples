LOAD TABLE nyc_taxi.nyc_taxi_trips_fhvhv
  FROM ('/trip data/fhvhv_tripdata_2019')
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location;
