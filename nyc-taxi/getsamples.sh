mkdir ./listings 2>/dev/null
mkdir ./samples 2>/dev/null

aws s3 ls 's3://nyc-tlc/trip data/' --no-sign-request >./listings/trip-data.listing

aws s3 cp 's3://nyc-tlc/trip data/fhv_tripdata_2015-01.csv' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhv_tripdata_2019-02.csv' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhvhv_tripdata_2019-02.csv' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/green_tripdata_2013-08.csv' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2009-01.csv' ./samples --no-sign-request

