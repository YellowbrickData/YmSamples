# NYC Taxi Trip Data

This dataset contains 4 different tables for different classes of taxi/ride trips
in New York City, capturing pick-up and drop-off dates/times, pick-up and drop-off
locations, trip distances, itemized fares, rate types, payment types, and
driver-reported passenger counts.

### Source

 * Website: https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page
 * S3 Bucket: https://s3.amazonaws.com/nyc-tlc

### Tables

 1. **FHV** For-Hire Vehicle, provided by bases (Limos, Black Cars, etc)
 2. **FHVHV** High Volume For-Hire Vehicle (eg. Uber, Lyft, etc)
 3. **green** Green Taxi Vehicles
 4. **yellow** Yellow Taxi Vehicles

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
