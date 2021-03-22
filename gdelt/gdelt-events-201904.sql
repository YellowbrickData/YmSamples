LOAD TABLE gdelt.events
  FROM ('/v2/events/201904')
  EXTERNAL LOCATION gdelt.gdelt_location;
