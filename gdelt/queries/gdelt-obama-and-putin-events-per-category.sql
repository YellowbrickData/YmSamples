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
ORDER BY  nb_events DESC
LIMIT 25;
