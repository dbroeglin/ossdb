//
// DNS Records
//
// Format: zoneName,recName,recType,recValue
//

CREATE INDEX ON :DNSZone(name);
CREATE INDEX ON :DNSRecordName(name);
CREATE INDEX ON :DNSRecordValue(value);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///dns_records.csv" as csv
CREATE (zone:DNSZone { 
    name: csv.zoneName
})
CREATE (name:DNSRecordName { 
    name: csv.recName
})
CREATE (value:DNSRecordValue { 
    value: csv.recValue
})
CREATE (zone)-[:CONTAINS]->(name)
CREATE (name)-[:HAS_VALUE { type: csv.recType }]->(value) 
;