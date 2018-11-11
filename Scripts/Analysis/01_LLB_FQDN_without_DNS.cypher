MATCH (nat:LinkLoadBalancerNat)-[:HAS_FQDN]->(fqdn:LinkLoadBalancerFQDN)
OPTIONAL MATCH (zone:DNSZone)-->
               (dns:DNSRecordName)-[dr:HAS_VALUE]->(dnsValue:DNSRecordValue)
WHERE fqdn.fqdn = dns.name + '.' + zone.name AND
      dr.type IN ['A', 'CNAME']
WITH DISTINCT collect(nat) AS nats, fqdn, dns
WHERE dns IS null
MERGE (fqdn)-[:HAS_ANOMALY]->(ano:Anomaly {
  code: 'llb_fqdn_without_dns',
  description: "No DNS entry for LLB FQDN '" + fqdn.fqdn + "'" 
})
WITH ano, nats
UNWIND nats AS nat
CREATE (nat)-[:HAS_ANOMALY]->(ano)
;