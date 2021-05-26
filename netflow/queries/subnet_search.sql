-- Return all of the source_ip addresses within a given subnet.

select distinct source_ip::varchar from netflow.netflow where contains(ipv4 '42.219.145.0',24,source_ip) limit 100;

