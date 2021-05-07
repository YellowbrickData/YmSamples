-- Count Obama events per year
SELECT year,
       COUNT(globaleventid) AS nb_events
FROM gdelt.events
WHERE actor1name='BARACK OBAMA'
GROUP BY year
ORDER BY year ASC;
