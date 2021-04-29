LOAD TABLE gdelt.mentions
  FROM ('/v2/mentions/201502')
  EXTERNAL LOCATION gdelt.gdelt_location
  WITH ( read_sources_concurrently 'ALWAYS', max_bad_rows '-1' );
