
//
// Hosts
//

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///hosts.csv" as csv 
CREATE (:Host {
    name   : csv.name, 
    memory : toInt(csv.memory), 
    cores  : toInt(csv.cores)
});

CREATE INDEX ON :Host(name);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///hosts_ips.csv" as csv
MATCH(host:Host { 
    name : csv.name
}) 
MERGE (ip:IPv4Address { 
    address  : csv.ipv4Address
})
CREATE (host)-[:HAS_ADDRESS]->(ip)
;


// Aggregate data based on IP address 

MATCH (dns:DNSRecordName)-[dr:HAS_VALUE{type: 'A'}]->(dnsValue:DNSRecordValue)
MATCH (lb:LoadBalancer)-[lbr:BALANCES_TO]->(lbb:LoadBalancerBackend)
WHERE
  lb.virtualIPv4Address = dnsValue.value
MERGE (dns)-[l1:LINKED_TO]->(lb)
;

MATCH (lb:LoadBalancer)-[lbr:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[hr:HAS_ADDRESS]->(ip:IPv4Address)
WHERE
  ip.address = lbb.ipv4Address
MERGE (lbb)-[l2:LINKED_TO]->(host)
;

MATCH (lb:LoadBalancer)-[lbr:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (as:ApacheService)-[bd:BOUND_TO]->(aip:IPv4Address)
WHERE
  lbb.ipv4Address = aip.address
MERGE (lbb)-[l3:LINKED_TO]->(as)