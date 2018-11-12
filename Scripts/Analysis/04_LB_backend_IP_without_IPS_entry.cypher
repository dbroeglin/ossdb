MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)-[:HAS_ADDRESS]->(ip:IPv4Address)
MATCH (lb)-[:HAS_VIRTUAL_IP]->(vip:IPv4Address)
WHERE vip.address =~ $DMZLoadBalancerIPRegex          // Only look for DMZ LBs

OPTIONAL MATCH (entry:IPSEntry)-[:HAS_ADDRESS]->(ip)

WITH DISTINCT lb, collect(ip) AS ips, entry
WHERE entry IS NULL OR entry.lastSync < (datetime() - duration({days: 60}))

CREATE (ano:Anomaly {
  code: 'lb_backend_ip_without_ips_entry',
  description: "No IPS data for LB backend IP '" + 
    reduce(s = head(ips).address, n IN tail(ips) | s + ', ' + n.address) + "'" 
})
CREATE (lb)-[:HAS_ANOMALY]->(ano)

WITH ips, ano
UNWIND ips AS ip
CREATE (ip)-[:HAS_ANOMALY]->(ano);