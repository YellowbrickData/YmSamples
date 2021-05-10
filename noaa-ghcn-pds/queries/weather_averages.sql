-- Source: https://aws.amazon.com/blogs/big-data/visualize-over-200-years-of-global-climate-data-using-amazon-athena-and-amazon-quicksight/
SELECT element,
         round(avg(CAST(data_value AS real)/10),2) AS value
FROM noaa_ghcn_pds.observations
WHERE element IN ('TMIN', 'TMAX', 'PRCP')
GROUP BY  element;
