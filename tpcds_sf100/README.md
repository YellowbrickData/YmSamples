# TPC-DS Data
A 1TB (scale-factor 100) version of the TPC-DS data set, which is frequently used by database companies for competitive decision-support benchmarking. This data set is pre-loaded into the `yellowbrick_trial` database. Scripts are available for re-creating, loading, and querying these tables.

## Source
* S3 Bucket: `https://s3.console.aws.amazon.com/s3/buckets/yb-sampledata-d4f1c23ea7`

## Tables
TPC-DS 100 consists of 24 tables of various sizes, holding about 6 billion rows in total. 

|          Name          |   # Rows   | Size (MiB)
|------------------------|------------|---------------
| call_center            |         30 |          0.01
| catalog_page           |      20400 |           2.7
| catalog_returns        |   14404374 |          2150
| catalog_sales          |  143997065 |         29696
| customer               |    2000000 |           257
| customer_address       |    1000000 |           106
| customer_demographics  |    1920800 |            77
| date_dim               |      73049 |           9.8
| household_demographics |       7200 |          0.14
| income_band            |         20 |             0
| inventory              |  399330000 |          8192
| item                   |     204000 |            56
| promotion              |       1000 |          0.12
| reason                 |         55 |             0
| ship_mode              |         20 |             0
| store                  |        402 |           0.1
| store_returns          |   28795080 |          3277
| store_sales            |  287997024 |         38912
| time_dim               |      86400 |           4.9
| warehouse              |         15 |             0
| web_page               |       2040 |          0.19
| web_returns            |    7197670 |          1005
| web_sales              |   72001237 |         14336
| web_site               |         24 |          0.01

## Scripts

* `one_button_load_tpcds_sf100.sql`
* `create_external_resources.sql`
* `create_tables.sql`
* `load_all_tables.sql`
* `load_<table_name>.sql`
* `query01.sql`...`query99.sql`

## Workflow
You can create everything (schema, external objects, tables), then load all the tables in one step by running `one_button_load_tpcds_sf100.sql`

Alternatively, you can create external objects and tables separately, then load all tables or specific tables:

  * Run `create_external_resources.sql`
  * Run `create_tables.sql`
  * Run `load_all_tables.sql` or run `load_<table_name>.sql` to load a specific table
