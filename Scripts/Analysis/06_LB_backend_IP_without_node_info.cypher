MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)-[:HAS_ADDRESS]->(ip:IPv4Address),
      (entry:IPSEntry {status: 'Used'})-[:HAS_ADDRESS]->(ip)
WHERE entry.lastSync > (datetime() - duration({days: 60}))

MATCH (lb)-[:HAS_VIRTUAL_IP]->(vip:IPv4Address)
WHERE vip.address =~ $DMZLoadBalancerIPRegex                       // Only look for DMZ LBs

OPTIONAL MATCH (node:Node)-[:HAS_ADDRESS]->(ip)

WITH DISTINCT lb, ip, node
WHERE node is null

MERGE (ano:Anomaly {
  code: 'lb_backend_ip_without_node_info',
  description: "No node information was found for backend IPs of LB '" + lb.name + "' (found through LB Backend IPs)" 
})
MERGE (lb)-[:HAS_ANOMALY]->(ano)
CREATE (ip)-[:HAS_ANOMALY]->(ano);