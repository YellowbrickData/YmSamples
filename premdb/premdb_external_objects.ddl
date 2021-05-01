drop external storage if exists premdbs3 cascade;
drop external format if exists premdbs3format;

create external storage premdbs3
type S3 
endpoint 'https://s3.us-west-2.amazonaws.com'
region 'us-west-2'
identity ''
credential '';

create external format premdbs3format 
type csv 
with (skip_blank_lines true, delimiter ',');

create external location premdbs3data 
path 'yb-sampledata-d4f1c23ea7'
external storage premdbs3
external format premdbs3format;

select * from sys.external_storage where name='premdbs3';

select * from sys.external_format where name='premdbs3format';

select * from sys.external_location where name='premdbs3data';
