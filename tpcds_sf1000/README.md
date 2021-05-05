# TPC-DS Data
A 1TB (scale-factor 1000) version of the TPC-DS data set, which is frequently used by database companies for competitive decision-support benchmarking. This data set is pre-loaded into the `yellowbrick_trial` database. Scripts are available for re-creating, loading, and querying these tables.

## Source
* S3 Bucket: `https://s3.console.aws.amazon.com/s3/buckets/yb-sampledata-d4f1c23ea7`

## Tables
TPC-DS 1000 consists of 24 tables of various sizes, holding about 6 billion rows in total. 

|          name          |    rows    | compressed_mb
|------------------------|------------|---------------
| call_center            |        630 |            30
| catalog_page           |     450000 |            30
| catalog_returns        |  143996756 |         10298
| catalog_sales          | 1439980416 |        110312
| customer               |   12000000 |           840
| customer_address       |   90000000 |          1860
| customer_demographics  |   28812000 |           120
| date_dim               |    1095735 |            30
| household_demographics |     108000 |            30
| income_band            |        300 |            30
| inventory              |  783000000 |          3618
| item                   |    4500000 |           450
| promotion              |      22500 |            30
| reason                 |        975 |            30
| ship_mode              |        300 |            30
| store                  |      15030 |            30
| store_returns          |  287999764 |         15372
| store_sales            | 2879987999 |        166276
| time_dim               |    1296000 |            30
| warehouse              |        300 |            30
| web_page               |      45000 |            30
| web_returns            |   71997522 |          4890
| web_sales              |  720000376 |         51256
| web_site               |        810 |            30

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
