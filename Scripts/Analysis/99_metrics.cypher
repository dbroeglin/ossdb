//
// DNS
// 
MATCH (node:Node)-[:CONTAINS]->(zone:DNSZone)-->
      (dns:DNSRecordName)-[dr:HAS_VALUE]->(dnsValue:DNSRecordValue)
WHERE dns.name <> '@' AND NOT (dr.type IN ['PTR', 'SRV']) AND node.name IN $ExternalDNSNodes
WITH count(DISTINCT dns) as value
CREATE (metric:Metric {
    scope: 'DNS', 
    label: 'FQDNs', 
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

MATCH (nat:LinkLoadBalancerNat)-[:HAS_FQDN]->(llbFQDN:LinkLoadBalancerFQDN)
WITH count(DISTINCT llbFQDN.fqdn) as value
CREATE (metric:Metric {
    scope: 'Link Load Balancer', 
    label: 'Nb of FQDNs', 
    value: value
})
;