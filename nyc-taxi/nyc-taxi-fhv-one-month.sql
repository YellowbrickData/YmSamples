
LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  FROM ('/trip data/fhv_tripdata_2018-01.csv')
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location;

