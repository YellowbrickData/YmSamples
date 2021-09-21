-- This script will load a sample dataset with NetFlow data.

CREATE SCHEMA IF NOT EXISTS "netflow";
GRANT ALL ON SCHEMA "netflow" TO public;
SET SEARCH_PATH TO "netflow";

CREATE EXTERNAL STORAGE "netflow_storage" TYPE s3 ENDPOINT 'https://s3.amazonaws.com' REGION 'us-east-1';

CREATE EXTERNAL FORMAT "netflow_format" TYPE csv;

CREATE EXTERNAL LOCATION "netflow_location" PATH 'yb-sampledata-d4f1c23ea7' EXTERNAL STORAGE "netflow_storage" EXTERNAL FORMAT "netflow_format";

CREATE TABLE netflow.netflow (
    "timestamp" timestamp without time zone,
    duration real,
    source_ip ipv4,
    destination_ip ipv4,
    source_port integer,
    destination_port integer,
    protocol character varying(10),
    flags character varying(10),
    forwarding_status integer,
    type_of_service integer,
    packets_exchanged integer,
    total_bytes bigint,
    fg_bg character varying(20)
);

CREATE TABLE netflow.protocols (
    name character varying(30),
    port bigint,
    transport character varying(6)
) DISTRIBUTE REPLICATE ;

LOAD TABLE "netflow"."protocols" FROM ('/netflow/protocols') EXTERNAL LOCATION "netflow_location" EXTERNAL FORMAT "netflow_format";

LOAD TABLE "netflow"."netflow" FROM ('/netflow/netflow2') EXTERNAL LOCATION "netflow_location" EXTERNAL FORMAT "netflow_format" WITH (num_readers '20', read_sources_concurrently 'ALWAYS', max_bad_rows '100');
