MATCH (nat:LinkLoadBalancerNat)-[:HAS_FQDN]->(fqdn:LinkLoadBalancerFQDN)
OPTIONAL MATCH (zone:DNSZone)-->
               (dns:DNSRecordName)-[dr:HAS_VALUE{type: 'A'}]->(dnsValue:DNSRecordValue)
WHERE fqdn.fqdn = dns.name + '.' + zone.name
WITH nat, fqdn, dns
WHERE dns IS null
MERGE (nat)-[:HAS_ANOMALY]->(ano:Anomaly {
  code: 'llb_fqdn_without_dns',
  description: "No DNS entry for FQDN '" + fqdn.fqdn + "' of NAT entry" 
})