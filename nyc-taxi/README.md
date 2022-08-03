# :warning: **This example is now deprecated**

The NYC Taxi trip data data was converted to Parquet in Spring 2022, but was soon afterwards shuttered for external S3 bucket access.  As a result, this example data set is provided for educational purposes only.  

The parquet source files are now available via the same NYC TLC site listed below, but are provided via HTTPS access only.  You may be able to gather these files into your own S3 bucket and tailor this example to load from that source.

# NYC Taxi Trip Data

This dataset contains 4 different tables for different classes of taxi/ride trips
in New York City, capturing pick-up and drop-off dates/times, pick-up and drop-off
locations, trip distances, itemized fares, rate types, payment types, and
driver-reported passenger counts.

### Source

 * Website: https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page
 * S3 Bucket: https://s3.amazonaws.com/nyc-tlc

### Tables

 1. **nyc_taxi_trips_fhv** For-Hire Vehicle, provided by bases (Limos, Black Cars, etc)
 2. **nyc_taxi_trips_fhvhv** High Volume For-Hire Vehicle (eg. Uber, Lyft, etc)
 3. **nyc_taxi_trips_green** Green Taxi Vehicles
 4. **nyc_taxi_trips_yellow** Yellow Taxi Vehicles

### Samples

After loading this sample dataset, you can perform analytic queries on the trip data.

Sample query:

```sql

SELECT 'yellow' as source, avg(total_amount) as average_total_amount, avg(tip_amount) as average_tip_amount
FROM nyc_taxi.nyc_taxi_trips_yellow

UNION ALL

SELECT 'green' as source, avg(total_amount) as average_total_amount, avg(tip_amount) as average_tip_amount
FROM nyc_taxi.nyc_taxi_trips_green

```

**Note:** some sample queries were inspired by this great blog article for taxi trip analysis: https://tech.marksblogg.com/omnisci-macos-macbookpro-mbp.html ...thanks!
