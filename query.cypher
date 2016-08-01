
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

// Graph statistics

MATCH (n) 
RETURN
    DISTINCT labels(n),
    count(*) AS SampleSize,
    avg(size(keys(n))) as Avg_PropertyCount,
    min(size(keys(n))) as Min_PropertyCount,
    max(size(keys(n))) as Max_PropertyCount,
    avg(size( (n)-[]-() ) ) as Avg_RelationshipCount,
    min(size( (n)-[]-() ) ) as Min_RelationshipCount,
    max(size( (n)-[]-() ) ) as Max_RelationshipCount
;

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

MATCH (dns:DNSRecord { name : "www.foo.com" })-[dr:CONTAINS]->(dnsValue:DNSRecordValue) 
MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[:HAS_ADDRESS]->(ip:Ipv4Address)
MATCH (dns)-->(lb)
MATCH (lbb)-->(host)
WHERE 
    dns.type = "A"
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

MATCH (dns:DNSRecord)-[dr:CONTAINS]->(dnsValue:DNSRecordValue) 
MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[:HAS_ADDRESS]->(ip:Ipv4Address)
MATCH (dns)-->(lb)
MATCH (lbb)-->(host)
WHERE 
    dns.type = "A"
WITH dns, lb, collect(host.name) AS hostnames
WHERE any(hostname IN hostnames WHERE hostname = "jeexxx01")
RETURN 
    dns.name as dnsName, 
    lb.virtualIpv4Address as ip, 
    hostnames
;


MATCH (dns:DNSRecord { name : "www.foo994.com" })-[dr:CONTAINS]->(dnsValue:DNSRecordValue) 
MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[:HAS_ADDRESS]->(ip:Ipv4Address)
MATCH (dns)-->(lb)
MATCH (lbb)-->(host)
WHERE 
    dns.type = "A"
RETURN 
    dns.name as dnsName, 
    lb.virtualIpv4Address as ip, 
    collect(host.name) as hostnames
;

