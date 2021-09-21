LOAD TABLE openaq.measurements
  FROM ('/daily/2017-09-07.csv')
  EXTERNAL LOCATION openaq_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );
