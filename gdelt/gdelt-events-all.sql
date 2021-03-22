LOAD TABLE gdelt.events
  FROM ('/events/')
  EXTERNAL LOCATION gdelt.gdelt_location;
