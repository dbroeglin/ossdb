//
// DNS Records
//
// Format: srvName,zoneName,recName,recType,recValue
//

CREATE INDEX ON :DNSZone(name);
CREATE INDEX ON :DNSRecordName(name);
CREATE INDEX ON :DNSRecordName(fqdn);
CREATE INDEX ON :DNSRecordValue(value);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///dns_records.csv" as csv
MERGE (node:Node {
    name: toLower(csv.srvName)
})
MERGE (zone:DNSZone { 
    name: csv.zoneName
})
MERGE (node)-[:CONTAINS]->(zone)
MERGE (name:DNSRecordName {
    zone: csv.zoneName,
    name: csv.recName,
    fqdn: csv.recName + '.' + csv.zoneName
})
CREATE (value:DNSRecordValue { 
    value: csv.recValue
})
MERGE (zone)-[:CONTAINS]->(name)
CREATE (name)-[:HAS_VALUE { type: csv.recType }]->(value) 
;