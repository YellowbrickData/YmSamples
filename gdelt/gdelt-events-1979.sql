LOAD TABLE gdelt.events
  FROM ('/events/1979.csv')
  EXTERNAL LOCATION gdelt.gdelt_location;
