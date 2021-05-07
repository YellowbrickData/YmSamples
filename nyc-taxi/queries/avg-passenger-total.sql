SELECT passenger_count,
       avg(total_amount) as avg_total
FROM nyc_taxi.trips
GROUP BY 1
ORDER BY 1;
