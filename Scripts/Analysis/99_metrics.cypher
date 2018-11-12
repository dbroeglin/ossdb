//
// DNS
//
MATCH (node:Node)-[:CONTAINS]->(zone:DNSZone)-->
      (dns:DNSRecordName)-[dr:HAS_VALUE]->(dnsValue:DNSRecordValue)
WHERE dns.name <> '@' AND NOT (dr.type IN ['PTR', 'SRV']) AND node.name IN $ExternalDNSNodes
WITH count(DISTINCT dns) as value
CREATE (metric:Metric {
    scope: 'DNS',
    label: 'FQDNs (servers: ' + reduce(s = head($ExternalDNSNodes), n in tail($ExternalDNSNodes) | s + ', ' + n) + ')',
    value: value
})
;

//
// Link Load Balancer
//
MATCH (nat:LinkLoadBalancerNat)-[:OUT]->(oRange)-[:HIGH_ADDRESS|:LOW_ADDRESS]->(o:IPv4Address)
WITH count(DISTINCT o) as value
CREATE (metric:Metric {
    scope: 'Link Load Balancer',
    label: 'External IPs',
    value: value
})
;

MATCH (nat:LinkLoadBalancerNat)-[:OUT]->(oRange)-[:HIGH_ADDRESS|:LOW_ADDRESS]->(o:IPv4Address)
WHERE nat.type STARTS WITH 'dynamic'
WITH count(DISTINCT o) as value
CREATE (metric:Metric {
    scope: 'Link Load Balancer',
    label: 'External IPs (dynamic NAT)',
    value: value
})
;

MATCH (nat:LinkLoadBalancerNat)-[:OUT]->(oRange)-[:HIGH_ADDRESS|:LOW_ADDRESS]->(o:IPv4Address)
WHERE nat.type STARTS WITH 'static'
WITH count(DISTINCT o) as value
CREATE (metric:Metric {
    scope: 'Link Load Balancer',
    label: 'External IPs (static NAT)',
    value: value
})
;

MATCH (nat:LinkLoadBalancerNat)-[:HAS_FQDN]->(llbFQDN:LinkLoadBalancerFQDN)
WITH count(DISTINCT llbFQDN.fqdn) as value
CREATE (metric:Metric {
    scope: 'Link Load Balancer',
    label: 'Nb of FQDNs',
    value: value
})
;

//
// Load balancers
//
MATCH (lb:LoadBalancer)-[:HAS_VIRTUAL_IP]->(ip:IPv4Address)
WHERE ip.address =~ $DMZLoadBalancerIPRegex
WITH count(DISTINCT lb) as value
CREATE (metric:Metric {
    scope: 'Load Balancer',
    label: 'Nb',
    value: value
})
;