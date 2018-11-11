//
// Hosts
//
// Format: Hostname, IP
//


CREATE INDEX ON :Node(name);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///node_ips.csv" as csv
MERGE (ip:IPv4Address {
    address: csv.IP
})
WITH csv, ip
WHERE csv.Hostname <> '' AND csv.Hostname IS NOT NULL
MERGE(node:Node { 
    name: toLower(csv.Hostname)
}) 
MERGE (node)-[:HAS_ADDRESS]->(ip)
;