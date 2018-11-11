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

MATCH (nat:LinkLoadBalancerNat)-[:IN]->(range)-[:HIGH_ADDRESS|:LOW_ADDRESS]->(ip:IPv4Address)
WHERE NOT ip.address =~ $LoadBalancerIPRegex
WITH DISTINCT nat, range, ip
OPTIONAL MATCH (entry:IPSEntry)-[:HAS_ADDRESS]->(ip)
WITH DISTINCT collect(nat) AS nats, range, ip, entry
WHERE entry IS NULL OR entry.lastSync > (datetime() - duration({days: 60}))
WITH count(DISTINCT ip) as value
CREATE (metric:Metric {
    scope: 'Link Load Balancer',
    label: 'Abandonned internal IP (not LB VIP, no IPS entry)',
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
