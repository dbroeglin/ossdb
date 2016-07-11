MATCH (a)-[r]-(b)
DELETE r,a,b;
MATCH(a) DELETE a;

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
CREATE (ip:Ipv4Address { 
    address  : csv.ipv4Address
})
CREATE (host)-[:HAS_ADDRESS]->(ip)
;

CREATE INDEX ON :Ipv4Address(address);


//
// DNS Records
//

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///dns_records.csv" as csv
CREATE (r:DNSRecord { 
    name  : csv.name, 
    type  : csv.type
})
CREATE (v:DNSRecordValue { 
    value : csv.value
})
CREATE (r)-[:CONTAINS]->(v)
;

CREATE INDEX ON :DNSRecord(name);
CREATE INDEX ON :DNSRecord(value);
CREATE INDEX ON :DNSRecordValue(value);

//
// Load balancers
//

CREATE INDEX ON :LoadBalancer(virtualIpv4Address);
CREATE INDEX ON :LoadBalancerBackend(ipv4Address);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///load_balancers.csv" as csv
MERGE (loadbalancer:LoadBalancer { 
    name : csv.name, 
    virtualIpv4Address : csv.virtualIpv4Address 
})
CREATE (backend:LoadBalancerBackend { 
    name         : csv.backendName, 
    ipv4Address  : csv.backendIpv4Address
})
CREATE (loadbalancer)-[:BALANCES_TO]->(backend)
;


// Aggregate data based on IP address 

MATCH (dns:DNSRecord)-[dr:CONTAINS]->(dnsValue:DNSRecordValue)
MATCH (lb:LoadBalancer)-[lbr:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[hr:HAS_ADDRESS]->(ip:Ipv4Address)
WHERE 
  lb.virtualIpv4Address = dnsValue.value 
  AND dns.type = "A"
  AND ip.address = lbb.ipv4Address
MERGE (dns)-[l1:LINKED_TO]->(lb)
MERGE (lbb)-[l2:LINKED_TO]->(host)
RETURN dns, dnsValue, lb, host, lbr, hr, l1, l2;


// List all DNS names, load balancer and host list

MATCH (dns:DNSRecord)-[dr:CONTAINS]->(dnsValue:DNSRecordValue) 
MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[:HAS_ADDRESS]->(ip:Ipv4Address)
WHERE 
    lb.virtualIpv4Address = dnsValue.value 
    AND dns.type = "A"
    AND ip.address = lbb.ipv4Address
RETURN 
    dns.name as dnsName, 
    lb.virtualIpv4Address AS ip, 
    collect(host.name) AS hostnames
ORDER BY dnsName;


// Find a subgraph with DNS name www.foo.com

MATCH (dns:DNSRecord { name : "www.foo.com" })-[dr:CONTAINS]->(dnsValue:DNSRecordValue) 
MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[:HAS_ADDRESS]->(ip:Ipv4Address)
WHERE 
    lb.virtualIpv4Address = dnsValue.value 
    AND dns.type = "A"
    AND ip.address = lbb.ipv4Address
RETURN 
    dns.name as dnsName, 
    lb.virtualIpv4Address as ip, 
    collect(host.name) as hostnames
;

// Find a subgraph containing host jeexxx01

MATCH (dns:DNSRecord)-[dr:CONTAINS]->(dnsValue:DNSRecordValue) 
MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[:HAS_ADDRESS]->(ip:Ipv4Address)
WHERE 
    lb.virtualIpv4Address = dnsValue.value 
    AND dns.type = "A"
    AND ip.address = lbb.ipv4Address
WITH dns, lb, collect(host.name) AS hostnames
WHERE any(hostname IN hostnames WHERE hostname = "jeexxx01")
RETURN 
    dns.name as dnsName, 
    lb.virtualIpv4Address as ip, 
    hostnames
;