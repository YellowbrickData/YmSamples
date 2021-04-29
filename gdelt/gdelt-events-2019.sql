LOAD TABLE gdelt.events
  FROM ('/v2/events/2019')
  EXTERNAL LOCATION gdelt.gdelt_location
  WITH ( read_sources_concurrently 'ALWAYS', max_bad_rows '-1' );
