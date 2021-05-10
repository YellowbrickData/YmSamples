SELECT station_id, (((max_temp::float / 10) * 9 ) / 5) + 32 as max_temp_f, year_date, state, station_name
FROM (
  SELECT s.id AS station_id, max_temp, year_date, s.state, s.name AS station_name,
  ROW_NUMBER() OVER(PARTITION BY s.state ORDER BY max_temp DESC) rn
  FROM (
    -- max temp of each date
    SELECT id, year_date, MAX(data_value) as max_temp
    FROM noaa_ghcn_pds.observations
    WHERE element = 'TMAX'
    AND q_flag IS NULL
    GROUP BY 1, 2
  ) mt
  JOIN noaa_ghcn_pds.stations s
  ON mt.id = s.id
  WHERE s.state <> ''
  AND state IS NOT NULL
  AND SUBSTRING(s.id, 1, 2) = 'US'
  AND max_temp IS NOT NULL
  AND year_date >= 20200000
  AND year_date <  20210000
) sums
WHERE rn = 1
ORDER BY max_temp desc
