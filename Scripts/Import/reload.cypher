
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
CREATE (ip:IPv4Address { 
    address  : csv.ipv4Address
})
CREATE (host)-[:HAS_ADDRESS]->(ip)
;

CREATE INDEX ON :IPv4Address(address);



//
// Load balancers
//

CREATE INDEX ON :LoadBalancer(virtualIPv4Address);
CREATE INDEX ON :LoadBalancerBackend(ipv4Address);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///load_balancers.csv" as csv
MERGE (loadbalancer:LoadBalancer { 
    name : csv.name, 
    virtualIPv4Address : csv.virtualIPv4Address 
})
CREATE (backend:LoadBalancerBackend { 
    name         : csv.backendName, 
    ipv4Address  : csv.backendIPv4Address
})
CREATE (loadbalancer)-[:BALANCES_TO]->(backend)
;

//
// Apache Services
//

CREATE INDEX ON :ApacheService(fqdn);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///apache_services.csv" as csv
MERGE (apache_service:ApacheService { 
    fqdn : csv.fqdn
})
CREATE (ip:IPv4Address { 
    address  : csv.ipv4Address
})
CREATE (apache_service)-[:BOUND_TO]->(ip)
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