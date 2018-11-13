MATCH (nat:LinkLoadBalancerNat)-[:IN]->(range)-[:HIGH_ADDRESS|:LOW_ADDRESS]->(ip:IPv4Address)
WHERE NOT ip.address =~ $DMZLoadBalancerIPRegex                  // Exclude DMZ LB VIPs
WITH DISTINCT ip, nat

OPTIONAL MATCH (entry:IPSEntry)-[:HAS_ADDRESS]->(ip)
WITH DISTINCT ip, entry, nat

WHERE entry IS NULL OR entry.lastSync < (datetime() - duration({days: 60}))
WITH DISTINCT ip, collect(nat) AS nats

MERGE (ip)-[:HAS_ANOMALY]->(ano:Anomaly {
  code: 'llb_internal_ip_without_ips_entry',
  description: "No IPS data for LLB internal IP '" + ip.address + "'" 
})
WITH nats, ano
UNWIND nats as nat
CREATE (nat)-[:HAS_ANOMALY]->(ano);