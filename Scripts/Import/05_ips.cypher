//
// IP information
//
// Format: IP Address,Hostname,MAC Address,Last Synchronization,Status
//

CREATE INDEX ON :MACAddress(address);
CREATE INDEX ON :IPSEntry(address);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///ips.csv" as csv
CREATE (ips:IPSEntry {
  address: csv.`IP Address`,
  lastSync: datetime(csv.`Last Synchronization`),
  status: csv.Status
})
MERGE (ip:IPv4Address { 
  address: csv.`IP Address`
})
MERGE (mac:MACAddress {
  address: csv.`MAC Address`
})
CREATE (ips)-[:HAS_ADDRESS]->(ip)
CREATE (ips)-[:HAS_ADDRESS]->(mac)
;