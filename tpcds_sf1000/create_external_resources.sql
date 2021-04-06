CREATE SCHEMA IF NOT EXISTS "tpcds_sf1000";
CREATE EXTERNAL STORAGE "tpcds_sf1000"."sample_tpcds_qa_es" TYPE S3 ENDPOINT 'https://s3.us-west-2.amazonaws.com/' REGION 'us-west-2' IDENTITY '' CREDENTIAL '';
CREATE EXTERNAL FORMAT IF NOT EXISTS "tpcds_sf1000"."sample_tpcds_qa_ef" TYPE CSV WITH (DELIMITER '|', ON_MISSING_FIELD 'SUPPLYNULL', ON_EXTRA_FIELD 'REMOVE');
CREATE EXTERNAL LOCATION "tpcds_sf1000"."sample_tpcds_qa_el" PATH 'yb-sampledata-d4f1c23ea7' EXTERNAL STORAGE "tpcds_sf1000"."sample_tpcds_qa_es" EXTERNAL FORMAT "tpcds_sf1000"."sample_tpcds_qa_ef";
