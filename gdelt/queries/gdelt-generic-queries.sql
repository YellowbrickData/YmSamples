
-- Count total events, S3 CSV
SELECT COUNT(*)
FROM gdelt.events;

-- Count total mentions, S3 CSV
SELECT COUNT(*)
FROM gdelt.mentions;

-- Count total gkg, S3 CSV
SELECT COUNT(*)
FROM gdelt.gkg;

-- Show 10 events
SELECT *
FROM gdelt.events LIMIT 10;

-- Show 10 event codes
SELECT *
FROM gdelt.eventcodes LIMIT 10;

-- Show 10 types
SELECT *
FROM gdelt.types LIMIT 10;

-- Show 10 groups
SELECT *
FROM gdelt.groups LIMIT 10;

-- Show 10 countries
SELECT *
FROM gdelt.countries LIMIT 10;

-- Find the number of events per year
SELECT year,
       COUNT(globaleventid) AS nb_events
FROM gdelt.events
GROUP BY year
ORDER BY year ASC;

-- Find the top 10 countries with the most events
SELECT day,
       COUNT(globaleventid) AS nb_events
FROM gdelt.events
GROUP BY day
ORDER BY nb_events DESC limit 10;

-- Find the top 10 days with the most events
SELECT day,
       COUNT(globaleventid) AS nb_events
FROM gdelt.events
GROUP BY day
ORDER BY nb_events DESC limit 10;


