LOAD TABLE openaq.measurements
  FROM ('/daily')
  EXTERNAL LOCATION openaq.openaq_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );
