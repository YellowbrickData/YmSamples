# NETFLOW UGR16

This is a sample dataset, containing 500 million rows of NetFlow data.  NetFlow is a service that sits on network routers and collects information on IP traffic as it enters or exits an interface.  It collects things like the source and destination addresses, ports, protocols, and the amount of data transmitted.  By analyzing the data provided by NetFlow, a network administrator can generate a summary of network activity, find sources of network congestion, and identify potential security threats.

This is a subset of the UGR16 dataset.   It was built using real network traffic from an ISP in Spain.  It was collected and published by University of Granada (UGR) Network Engineering department.


### Source

 * Website: https://nesg.ugr.es/nesg-ugr16/

### Tables

 1. **netflow.protocols**: A mapping of port numbers and their associated protocols. 
 2. **netflow.netflow**: A fact table of packet headers.

### References


 https://nesg.ugr.es/nesg-ugr16/

### Samples

  Here is a sample query that lists the top 100 destination IPs for SSH traffic. 

  select source_ip::varchar, count(*) as packet_count 
  from netflow.netflow
  where destination_port=22 
  group by source_ip 
  order by packet_count desc 
  limit 200;

