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
