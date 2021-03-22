LOAD TABLE gdelt.events
  FROM ('/v2/events/20190416151500.export.csv')
  EXTERNAL LOCATION gdelt.gdelt_location;
