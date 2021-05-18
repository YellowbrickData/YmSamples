CREATE TABLE netflow.protocols (
    name character varying(30),
    port bigint,
    transport character varying(6)
) DISTRIBUTE REPLICATE ;
