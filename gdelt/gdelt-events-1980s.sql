LOAD TABLE gdelt.events
  FROM ('/events/198')
  EXTERNAL LOCATION gdelt.gdelt_location;
