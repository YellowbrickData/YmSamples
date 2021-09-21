LOAD TABLE gdelt.mentions
  FROM ('/v2/mentions/2015')
  EXTERNAL LOCATION gdelt_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1' );
