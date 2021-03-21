LOAD TABLE openaq.measurements
  FROM ('/daily')
  EXTERNAL LOCATION openaq.openaq_location;
