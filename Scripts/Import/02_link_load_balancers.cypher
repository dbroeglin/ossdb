//
// Link load balancers
//
// Format: node,type,inRangeLow,inRangeHigh,routerIP,outRangeLow,outRangeHigh,FQDN
//

CREATE INDEX ON :LinkLoadBalancerNat(fqdn, routerIP, node);
CREATE INDEX ON :LinkLoadBalancerFQDN(fqdn);


USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///link_load_balancer.csv" as csv
MERGE (node:Node { 
    name: toLower(csv.node)
})
CREATE (nat:LinkLoadBalancerNat { 
    fqdn: SPLIT(csv.FQDN, " "),
    routerIP: csv.routerIP,
    node: csv.node,
    type: csv.type
})
CREATE (node)-[:CONTAINS]->(nat)

CREATE (inRange:LinkLoadBalancerInRange)
CREATE (nat)-[:IN]->(inRange)
MERGE  (inRangeLow:  IPv4Address {
    address: csv.inRangeLow
})
CREATE (inRange)-[:LOW_ADDRESS]->(inRangeLow)
MERGE  (inRangeHigh:  IPv4Address {
    address: csv.inRangeHigh
})
CREATE (inRange)-[:HIGH_ADDRESS]->(inRangeHigh)

CREATE (outRange:LinkLoadBalancerOutRange)
CREATE (nat)-[:OUT]->(outRange)
MERGE  (outRangeLow:  IPv4Address {
    address: csv.outRangeLow
})
CREATE (outRange)-[:LOW_ADDRESS]->(outRangeLow)
MERGE  (outRangeHigh:  IPv4Address {
    address: csv.outRangeHigh
})
CREATE (outRange)-[:HIGH_ADDRESS]->(outRangeHigh)

WITH nat, csv
WHERE csv.FQDN <> ""

WITH nat, SPLIT(csv.FQDN, " ") AS fqdns
UNWIND fqdns AS fqdn
MERGE (llbFQDN:LinkLoadBalancerFQDN {fqdn: fqdn})
MERGE (nat)-[:HAS_FQDN]->(llbFQDN)
;