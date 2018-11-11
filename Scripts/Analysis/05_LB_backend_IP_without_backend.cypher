MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)-[:HAS_ADDRESS]->(ip:IPv4Address)
MATCH (lb)-[:HAS_VIRTUAL_IP]->(vip:IPv4Address)
WHERE vip.address =~ $LoadBalancerIPRegex
OPTIONAL MATCH (apacheService:ApacheService)-[:HAS_ADDRESS]->(ip)

WITH DISTINCT lb, ip, apacheService
WHERE apacheService is null

MERGE (ip)-[:HAS_ANOMALY]->(ano:Anomaly {
  code: 'lb_backend_ip_without_backend',
  description: "No backend found for LB backend IP '" + ip.address + "'" 
})
CREATE (lb)-[:HAS_ANOMALY]->(ano);