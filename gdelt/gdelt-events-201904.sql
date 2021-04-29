LOAD TABLE gdelt.events
  FROM ('/v2/events/201904')
  EXTERNAL LOCATION gdelt.gdelt_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );
