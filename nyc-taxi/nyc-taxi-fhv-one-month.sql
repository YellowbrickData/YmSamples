LOAD TABLE nyc_taxi.nyc_taxi_trips_fhv
  FROM ('/trip%20data/fhv_tripdata_2019-02.csv')
  EXTERNAL LOCATION nyc_taxi.nyc_taxi_location;
