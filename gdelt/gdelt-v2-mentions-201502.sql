LOAD TABLE gdelt.mentions
  FROM ('/v2/mentions/201502')
  EXTERNAL LOCATION gdelt.gdelt_location;
