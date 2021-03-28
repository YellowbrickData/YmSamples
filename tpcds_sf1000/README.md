# Load tpcds_sf1000 sample data
Data at https://s3.console.aws.amazon.com/s3/buckets/yb-sampledata-d4f1c23ea7
## Components
* one_button_load_tpcds_sf1000.sql
* create_external_resources.sql
* create_tables.sql
* load_all_tables.sql
* load_<table_name>.sql
## Workflow:
* One buttone load all: 
  * Run one_button_load_tpcds_sf1000.sql to create the schema, external resources, tables and load all tables
* Create resources and tables and load:
  * Run create_external_resources.sql
  * Run create_tables.sql
  * Run load_all_tables.sql / Run each load_<table_name>.sql to load a specific table  
