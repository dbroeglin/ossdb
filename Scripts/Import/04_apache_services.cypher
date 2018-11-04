//
// Apache services
//
// Format: itEnv,name,service_description,hostname,service_ip,vhost_fqdn,vhost_aliases,worker,backend_hostname,backend_port
//

CREATE INDEX ON :ApacheInstance(name);
CREATE INDEX ON :ApacheService(description);
CREATE INDEX ON :ApacheFQDN(fqdn);

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
MERGE (vhost:ApacheVirtualHost {fqdn: csv.vhost_fqdn})
MERGE (service)-[:CONTAINS]->(vhost)
MERGE (fqdn:ApacheFQDN {fqdn: csv.vhost_fqdn})
MERGE (vhost)-[:HAS_FQDN {isAlias: false}]->(fqdn)
WITH vhost, SPLIT(csv.vhost_aliases, ",") AS fqdns
UNWIND fqdns AS fqdn
MERGE (apacheFQDN:ApacheFQDN {fqdn: fqdn})
MERGE (vhost)-[:HAS_FQDN {isAlias: true}]->(apacheFQDN)
;
