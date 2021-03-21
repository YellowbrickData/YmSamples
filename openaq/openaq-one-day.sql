LOAD TABLE openaq.measurements
  FROM ('/daily/2017-09-07.csv')
  EXTERNAL LOCATION openaq.openaq_location;
