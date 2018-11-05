//
// Apache services
//
// Format: itEnv,name,service_description,hostname,service_ip,vhost_fqdn,vhost_aliases,worker,backend_hostname,backend_port
//

CREATE INDEX ON :ApacheInstance(name);
CREATE INDEX ON :ApacheService(description);
CREATE INDEX ON :ApacheFQDN(fqdn);

//
// Import Virtual Hosts
//
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///apache_services.csv" as csv
MERGE (itEnv:ITEnv {code : csv.itEnv})
MERGE (instance:ApacheInstance {name: csv.name})
MERGE (itEnv)<-[:HAS_ITENV]-(instance)
MERGE (service:ApacheService {description : csv.service_description})
MERGE (instance)-[:CONTAINS]->(service)
MERGE (node:Node {name: csv.hostname})
MERGE (node)-[:CONTAINS]->(instance)
MERGE (vip:IPv4Address {address: csv.service_ip})
MERGE (service)-[:HAS_ADDRESS {node: csv.hostname}]->(vip)
MERGE (vhost:ApacheVirtualHost {
    fqdn:    csv.vhost_fqdn
})
MERGE (service)-[:CONTAINS]->(vhost)

// handle FQDNs
MERGE (fqdn:ApacheFQDN {fqdn: csv.vhost_fqdn})
MERGE (vhost)-[:HAS_FQDN {isAlias: false}]->(fqdn)
WITH csv, vhost, SPLIT(csv.vhost_aliases, ",") AS fqdns
UNWIND fqdns AS fqdn
MERGE (apacheFQDN:ApacheFQDN {fqdn: fqdn})
MERGE (vhost)-[:HAS_FQDN {isAlias: true}]->(apacheFQDN)
;

//
// Import backends
//

// TODO: is there a simpler way ?
// lead: ensure vhost are mergeable by adding properties ?

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///apache_services.csv" as csv
WITH csv
WHERE csv.worker <> ''
MERGE (instance:ApacheInstance {name: csv.name})
MERGE (itEnv)<-[:HAS_ITENV]-(instance)
MERGE (service:ApacheService {description : csv.service_description})
MERGE (instance)-[:CONTAINS]->(service)
MERGE (node:Node {name: csv.hostname})
MERGE (node)-[:CONTAINS]->(instance)
MERGE (vip:IPv4Address {address: csv.service_ip})
MERGE (service)-[:HAS_ADDRESS {node: csv.hostname}]->(vip)
MERGE (vhost:ApacheVirtualHost {
    fqdn:    csv.vhost_fqdn
})
MERGE (service)-[:CONTAINS]->(vhost)

// handle backends
CREATE (backend:ApacheBackend {
    name:            (csv.worker + '/' + csv.backend_hostname + ':' + csv.backend_port),
    worker:          csv.worker,
    backendHostname: csv.backend_hostname,
    backendPort:     csv.backend_port
})
MERGE (vhost)-[:CONTAINS]->(backend)
