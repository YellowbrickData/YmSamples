-- List the source IPs with the greatest amount of outgoing SSH traffic.

select source_ip::varchar, count(*) as packet_count from netflow.netflow
where destination_port=22 group by source_ip order by packet_count desc limit 200;

