LOAD TABLE nyc_taxi.nyc_taxi_trips_fhvhv
  FROM ('/trip%20data/fhvhv_tripdata_2019-02.csv')
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location;
