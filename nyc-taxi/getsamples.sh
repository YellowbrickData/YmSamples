mkdir ./listings 2>/dev/null
mkdir ./samples 2>/dev/null

aws s3 ls 's3://nyc-tlc/trip data/' --no-sign-request >./listings/trip-data.listing

aws s3 cp 's3://nyc-tlc/trip data/fhv_tripdata_2015-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhv_tripdata_2016-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhv_tripdata_2017-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhv_tripdata_2017-06.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhv_tripdata_2018-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhv_tripdata_2019-02.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhv_tripdata_2020-01.parquet' ./samples --no-sign-request

aws s3 cp 's3://nyc-tlc/trip data/fhvhv_tripdata_2019-02.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhvhv_tripdata_2020-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhvhv_tripdata_2021-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhvhv_tripdata_2022-01.parquet' ./samples --no-sign-request

aws s3 cp 's3://nyc-tlc/trip data/fhvhv_tripdata_2019-02.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/fhvhv_tripdata_2020-01.parquet' ./samples --no-sign-request

aws s3 cp 's3://nyc-tlc/trip data/green_tripdata_2013-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/green_tripdata_2014-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/green_tripdata_2015-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/green_tripdata_2016-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/green_tripdata_2017-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/green_tripdata_2018-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/green_tripdata_2019-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/green_tripdata_2020-01.parquet' ./samples --no-sign-request

aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2009-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2010-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2011-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2012-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2013-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2014-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2015-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2016-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2017-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2018-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2019-01.parquet' ./samples --no-sign-request
aws s3 cp 's3://nyc-tlc/trip data/yellow_tripdata_2020-01.parquet' ./samples --no-sign-request

