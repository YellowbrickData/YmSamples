LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  FROM ('/trip%20data/fhv_tripdata_2017')
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location;
