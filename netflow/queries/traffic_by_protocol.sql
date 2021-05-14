-- Lists the total packet count for every protocol, grouped by type.

SELECT count(*) as packet_count, protocols.name AS protocol_name
FROM netflow.protocols protocols
INNER JOIN netflow.netflow netflow ON (protocols.port = netflow.destination_port)
GROUP BY protocols.name order by packet_count desc;
