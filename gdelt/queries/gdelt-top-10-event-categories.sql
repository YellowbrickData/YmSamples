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
