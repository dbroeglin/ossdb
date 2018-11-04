// Graph statistics

MATCH (n)
RETURN DISTINCT
  labels(n),
  count(*) AS SampleSize,
  avg(size(keys(n))) as Avg_PropertyCount,
  min(size(keys(n))) as Min_PropertyCount,
  max(size(keys(n))) as Max_PropertyCount,
  avg(size( (n)-[]-() ) ) as Avg_RelationshipCount,
  min(size( (n)-[]-() ) ) as Min_RelationshipCount,
  max(size( (n)-[]-() ) ) as Max_RelationshipCount
;

// List all DNS names, load balancer and host list

MATCH (zone:DNSZone)-->
      (dns:DNSRecordName)-[dr:HAS_VALUE{type: 'A'}]->(dnsValue:DNSRecordValue)
MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[:HAS_ADDRESS]->(ip:IPv4Address)
WHERE
  lb.virtualIPv4Address = dnsValue.value
  AND ip.address        = lbb.ipv4Address
RETURN
  dns.name + '.' + zone.name as dnsName,
  lb.virtualIPv4Address AS ip,
  collect(host.name) AS hostnames
ORDER BY dnsName

// Find a subgraph with DNS name www.foo.com (where clause)

MATCH (zone:DNSZone{name: 'foo.com'})-->
      (dns:DNSRecordName{name: 'www'})-[dr:HAS_VALUE{type: 'A'}]->(dnsValue:DNSRecordValue)
MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[:HAS_ADDRESS]->(ip:IPv4Address)
WHERE
  lb.virtualIPv4Address = dnsValue.value
  AND ip.address = lbb.ipv4Address
RETURN
  dns.name + '.' + zone.name as dnsName,
  lb.virtualIPv4Address      as ip,
  collect(host.name)         as hostnames
;

// Find a subgraph with DNS name www.foo.com (graph traversal)

MATCH (zone:DNSZone{name: 'foo.com'})-->
      (dns:DNSRecordName{name: 'www'})-[dr:HAS_VALUE{type: 'A'}]->(dnsValue:DNSRecordValue)
MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[:HAS_ADDRESS]->(ip:IPv4Address)
MATCH (dns)-->(lb)
MATCH (lbb)-->(host)
RETURN
  dns.name + '.' + zone.name as dnsName,
  lb.virtualIPv4Address      as ip,
  collect(host.name)         as hostnames
;

// Find a subgraph containing host jeexxx01 (where clause)

MATCH (zone:DNSZone)-->
      (dns:DNSRecordName)-[dr:HAS_VALUE{type: 'A'}]->(dnsValue:DNSRecordValue)
MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[:HAS_ADDRESS]->(ip:IPv4Address)
WHERE
  lb.virtualIPv4Address = dnsValue.value
  AND ip.address = lbb.ipv4Address
WITH zone, dns, lb, collect(host.name) AS hostnames
WHERE any(hostname IN hostnames WHERE hostname = 'jeexxx01')
RETURN
  dns.name + '.' + zone.name as dnsName,
  lb.virtualIPv4Address      as ip,
  hostnames
;

// Find a subgraph containing host jeexxx01 (graph traversal)

MATCH (zone:DNSZone)-->
      (dns:DNSRecordName)-[dr:HAS_VALUE{type: 'A'}]->(dnsValue:DNSRecordValue)
MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)
MATCH (host:Host)-[:HAS_ADDRESS]->(ip:IPv4Address)
MATCH (dns)-->(lb)
MATCH (lbb)-->(host)
WITH zone, dns, lb, collect(host.name) AS hostnames
WHERE any(hostname IN hostnames WHERE hostname = 'jeexxx01')
RETURN
  dns.name + '.' + zone.name as dnsName,
  lb.virtualIPv4Address      as ip,
  hostnames
;

// Find all link load balancer NAT configurations for foo.com

MATCH (i:IPv4Address)<-[*]-(iRange)<-[:IN]-(nat:LinkLoadBalancerNat)-->
      (oRange)-->(o:IPv4Address) 
WHERE 'foo.com' IN nat.fqdn
RETURN nat, i, iRange, o, oRange
;

// Find load balancer for "Foo"

MATCH (lb:LoadBalancer{name: 'Foo'})-->(lbb:LoadBalancerBackend)-[:HAS_ADDRESS]->(bip:IPv4Address)
MATCH (lb)-[:VIP]->(vip:IPv4Address)
RETURN lb, lbb, bip, vip
;