MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)-[:HAS_ADDRESS]->(ip:IPv4Address)
MATCH (lb)-[:HAS_VIRTUAL_IP]->(vip:IPv4Address)
WHERE vip.address =~ $LoadBalancerIPRegex
OPTIONAL MATCH (entry:IPSEntry)-[:HAS_ADDRESS]->(ip)
WITH DISTINCT lb, ip, entry
WHERE entry IS NULL OR entry.lastSync < (datetime() - duration({days: 60}))

MERGE (ip)-[:HAS_ANOMALY]->(ano:Anomaly {
  code: 'lb_backend_ip_without_ips_entry',
  description: "No IPS data for LB backend IP '" + ip.address + "'" 
})
CREATE (lb)-[:HAS_ANOMALY]->(ano);