LOAD TABLE gdelt.events
  FROM ('/v2/events/2019')
  EXTERNAL LOCATION gdelt.gdelt_location;
