//
// IP information
//
// Format: IP Address,Hostname,MAC Address,Last Synchronization,Status
//

CREATE INDEX ON :MACAddress(address);
CREATE INDEX ON :IPSEntry(address);
CREATE INDEX ON :IPSEntry(status);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///ips.csv" as csv
CREATE (ips:IPSEntry {
  address: csv.`IP Address`,
  lastSync: CASE WHEN csv.`Last Synchronization` = '' THEN NULL ELSE datetime(csv.`Last Synchronization`) END,
  status: csv.Status
})
MERGE (ip:IPv4Address { 
  address: csv.`IP Address`
})
CREATE (ips)-[:HAS_ADDRESS]->(ip)
WITH ips, csv
WHERE csv.`MAC Address` <> ''
MERGE (mac:MACAddress {
  address: csv.`MAC Address`
})
CREATE (ips)-[:HAS_ADDRESS]->(mac)
;