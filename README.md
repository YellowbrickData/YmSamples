# Test Drive Samples

Various data sets (DDL scripts, source files, and sample queries) are available for use in Yellowbrick Manager. The DDL scripts in this repository reference AWS S3 files in a public bucket. You can load S3 data into Yellowbrick tables, using either the Load Assistant or SQL commands in the Query Editor.  

The YmSamples site and the referenced S3 bucket are both public. You do not need an AWS S3 account to access the source S3 data that will be loaded into the sample tables. 

Scripts are available for building and loading the following data sets:

* **gdelt**: The [GDELT Project](https://www.gdeltproject.org) is the largest, most comprehensive, and highest resolution open database of human society ever created. Just the 2015 data alone records nearly three quarters of a trillion emotional snapshots and more than 1.5 billion location references, while its total archives span more than 215 years, making it one of the largest open-access spatio-temporal datasets in existance and pushing the boundaries of "big data" study of global human society.
* **nyc-taxi**: Yellow and green [taxi trip records](https://data.cityofnewyork.us/Transportation/2018-Yellow-Taxi-Trip-Data/t29m-gskq) include fields capturing pick-up and drop-off dates/times, pick-up and drop-off locations, trip distances, itemized fares, rate types, payment types, and driver-reported passenger counts. 
* **openaq**: [Air quality data](https://openaq.org/#/projects?page=1), including sensor data as a pilot and reference-grade data. Real-time and historical data is accessible. 
* **premdb**: A tiny database that contains actual English Premier League soccer results for about 20 seasons and details about each team in the league. You can run a script that creates and loads five small tables in about 5 seconds. These tables are used extensively in the main Yellowbrick documentation to provide simple, reproducible examples of SQL commands and functions. 
* **tpcds_sf1000**: A 1TB version of the [TPC-DS](http://www.tpc.org/tpcds/) data set, which is frequently used by database companies for competitive benchmarking. This data set is pre-loaded into the yellowbrick_trial database. Scripts are available for re-creating and loading these tables. 

For example, to quickly build, load, and query the premdb tables:

1. Click Load Sample Data on the Yellowbrick Manager home page. 
2. Select the premdb/premdb_testdrive.ddl script. 
3. Run the DDL script in the Query Editor and inspect the results. You should have five new tables belonging to schema premdb in the yellowbrick_trial database. Users that belong to the consumer role have full access to these tables. 
4. Select some sample queries in the /premdb/queries directory and run them in the Query Editor. 
