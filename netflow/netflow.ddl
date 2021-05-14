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

