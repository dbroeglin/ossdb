//
// Hosts
//
// Format: Hostname, IP
//


CREATE INDEX ON :Node(name);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///node_ips.csv" as csv
MERGE(node:Node { 
    name : csv.Hostname
}) 
MERGE (ip:IPv4Address { 
    address  : csv.IP
})
MERGE (node)-[:HAS_ADDRESS]->(ip)
;