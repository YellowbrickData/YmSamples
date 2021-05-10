
-- load stations
TRUNCATE TABLE noaa_ghcn_pds.staging;
LOAD TABLE noaa_ghcn_pds.staging
  FROM ('ghcnd-stations.txt')
  EXTERNAL LOCATION noaa_ghcn_pds.noaa_ghcn_pds_location;
INSERT INTO noaa_ghcn_pds.stations
  SELECT
      TRIM(SUBSTRING(line, 1, 11))
    , TRIM(SUBSTRING(line, 13, 7))
    , TRIM(SUBSTRING(line, 22, 7))
    , TRIM(SUBSTRING(line, 32, 7))
    , TRIM(SUBSTRING(line, 39, 2))
    , TRIM(SUBSTRING(line, 42, 30))
    , TRIM(SUBSTRING(line, 73, 3))
    , TRIM(SUBSTRING(line, 77, 3))
    , TRIM(SUBSTRING(line, 81, 4))
  FROM noaa_ghcn_pds.staging;

-- load countries
TRUNCATE TABLE noaa_ghcn_pds.staging;
LOAD TABLE noaa_ghcn_pds.staging
  FROM ('ghcnd-countries.txt')
  EXTERNAL LOCATION noaa_ghcn_pds.noaa_ghcn_pds_location;
INSERT INTO noaa_ghcn_pds.countries
  SELECT
      TRIM(SUBSTRING(line, 1, 2))
    , TRIM(SUBSTRING(line, 3, 64000))
  FROM noaa_ghcn_pds.staging;

-- load states
TRUNCATE TABLE noaa_ghcn_pds.staging;
LOAD TABLE noaa_ghcn_pds.staging
  FROM ('ghcnd-states.txt')
  EXTERNAL LOCATION noaa_ghcn_pds.noaa_ghcn_pds_location;
INSERT INTO noaa_ghcn_pds.states
  SELECT
      TRIM(SUBSTRING(line, 1, 2))
    , TRIM(SUBSTRING(line, 3, 64000))
  FROM noaa_ghcn_pds.staging;

TRUNCATE TABLE noaa_ghcn_pds.staging;

-- load observations
LOAD TABLE noaa_ghcn_pds.observations
  FROM ('/csv.gz/')
  EXTERNAL LOCATION noaa_ghcn_pds.noaa_ghcn_pds_location
  WITH (
    num_readers '30',
    read_sources_concurrently 'ALWAYS',
    max_bad_rows '-1',
    source_compression 'gz' );
