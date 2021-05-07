SELECT EXTRACT(year from pickup_datetime::timestamptz),
       cab_type,
       AVG(fare_amount / trip_distance) AS fare_per_distance
FROM nyc_taxi.trips
WHERE trip_distance > 0
AND EXTRACT(year from pickup_datetime::timestamptz) <= 2021
GROUP BY 1, 2
ORDER BY 1, 2;
