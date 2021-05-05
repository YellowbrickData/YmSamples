# TPC-DS Data
A 1TB (scale-factor 1000) version of the TPC-DS data set, which is frequently used by database companies for competitive decision-support benchmarking. This data set is pre-loaded into the `yellowbrick_trial` database. Scripts are available for re-creating, loading, and querying these tables.

## Source
* S3 Bucket: `https://s3.console.aws.amazon.com/s3/buckets/yb-sampledata-d4f1c23ea7`

## Tables
TPC-DS 1000 consists of 24 tables of various sizes, holding about 6 billion rows in total. 

## Scripts

* `one_button_load_tpcds_sf1000.sql`
* `create_external_resources.sql`
* `create_tables.sql`
* `load_all_tables.sql`
* `load_<table_name>.sql`
* `query01.sql`...`query99.sql`

## Workflow
You can create everything (schema, external objects, tables), then load all the tables in one step by running `one_button_load_tpcds_sf1000.sql`

Alternatively, you can create external objects and tables separately, then load all tables or specific tables:

  * Run `create_external_resources.sql`
  * Run `create_tables.sql`
  * Run `load_all_tables.sql` or run `load_<table_name>.sql` to load a specific table