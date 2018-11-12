MATCH (lb:LoadBalancer)-[:BALANCES_TO]->(lbb:LoadBalancerBackend)-[:HAS_ADDRESS]->(ip:IPv4Address)
MATCH (lb)-[:HAS_VIRTUAL_IP]->(vip:IPv4Address)
WHERE vip.address =~ $DMZLoadBalancerIPRegex                       // Only look for DMZ LBs
OPTIONAL MATCH (apacheService:ApacheService)-[:HAS_ADDRESS]->(ip)

WITH DISTINCT lb, ip, apacheService
WHERE apacheService is null

MERGE (ano:Anomaly {
  code: 'lb_backend_ip_without_backend',
  description: "No backend found for LB '" + lb.name + "'" 
})
MERGE (lb)-[:HAS_ANOMALY]->(ano)
CREATE (ip)-[:HAS_ANOMALY]->(ano);