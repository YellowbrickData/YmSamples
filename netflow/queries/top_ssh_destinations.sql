-- List the top 100 destination IPs for SSH traffic.

select destination_ip, count(*) as packet_count from netflow.netflow
where destination_port=22 group by destination_ip order by packet_count desc limit 100;

