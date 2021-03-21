
-- Count total events, S3 CSV
SELECT COUNT(*)
FROM gdelt.events;

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

-- Show top 10 event categories
SELECT eventcode,
       gdelt.eventcodes.description,
       nb_events
FROM (SELECT gdelt.events.eventcode,
             COUNT(gdelt.events.globaleventid) AS nb_events
      FROM gdelt.events
      GROUP BY gdelt.events.eventcode
      ORDER BY nb_events DESC LIMIT 10) t
  JOIN gdelt.eventcodes ON t.eventcode = gdelt.eventcodes.code
ORDER BY nb_events DESC;


-- Count Obama events per year
SELECT year,
       COUNT(globaleventid) AS nb_events
FROM gdelt.events
WHERE actor1name='BARACK OBAMA'
GROUP BY year
ORDER BY year ASC;


-- Count Obama/Putin events per category
SELECT eventcode,
       gdelt.eventcodes.description,
       nb_events
FROM (SELECT gdelt.events.eventcode,
             COUNT(gdelt.events.globaleventid) AS nb_events
      FROM gdelt.events
      WHERE actor1name='BARACK OBAMA'and actor2name='VLADIMIR PUTIN'
      GROUP BY gdelt.events.eventcode
      ORDER BY nb_events DESC) t
  JOIN gdelt.eventcodes ON t.eventcode = gdelt.eventcodes.code
ORDER BY nb_events DESC;

-- Count Obama/Putin and Putin/Obama events per category
WITH tmp as (SELECT gdelt.events.eventcode,
         COUNT(gdelt.events.globaleventid) AS nb_events
    FROM gdelt.events
    WHERE ((actor1name LIKE '%OBAMA' and actor2name LIKE '%PUTIN')
            OR (actor2name LIKE '%OBAMA' and actor1name LIKE '%PUTIN'))
    GROUP BY  gdelt.events.eventcode
    ORDER BY  nb_events DESC)
SELECT eventcode,
         gdelt.eventcodes.description,
         nb_events
FROM tmp
JOIN gdelt.eventcodes
    ON eventcode = gdelt.eventcodes.code
ORDER BY  nb_events DESC;
