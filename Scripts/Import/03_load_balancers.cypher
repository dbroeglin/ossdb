//
// Load balancers
//
// Format: Name,VIP,NatIP,BackendIP,BackendName,BackendDescription
//

CREATE INDEX ON :LoadBalancer(virtualIPv4Address);
CREATE INDEX ON :LoadBalancerBackend(ipv4Address);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///load_balancers.csv" as csv
MERGE (loadbalancer:LoadBalancer { 
    name : csv.Name
})
MERGE (vip:IPv4Address {
  address: csv.VIP 
})
MERGE (loadbalancer)-[:VIP]->(vip)
CREATE (backend:LoadBalancerBackend { 
    name         : csv.BackendName, 
    description  : csv.BackendDescription
})
MERGE (ip:IPv4Address {
  address: csv.BackendIP
})
CREATE (loadbalancer)-[:BALANCES_TO]->(backend)-[:HAS_ADDRESS]->(ip)
;