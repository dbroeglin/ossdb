//
// Link load balancers
//
// Format: node,type,inRangeLow,inRangeHigh,routerIP,outRangeLow,outRangeHigh,FQDN
//

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///link_load_balancer.csv" as llb
MERGE (node:Node { 
    name: llb.node
})
CREATE (nat:LinkLoadBalancerNat { 
    fqdn: SPLIT(llb.FQDN, " "),
    routerIP: llb.routerIP
})
CREATE (node)-[:CONTAINS]->(nat)

CREATE (inRange:LinkLoadBalancerInRange)
CREATE (nat)-[:IN]->(inRange)
MERGE  (inRangeLow:  IPv4Address {
    address: llb.inRangeLow
})
CREATE (inRange)-[:LOW_ADDRESS]->(inRangeLow)
MERGE  (inRangeHigh:  IPv4Address {
    address: llb.inRangeHigh
})
CREATE (inRange)-[:HIGH_ADDRESS]->(inRangeHigh)

CREATE (outRange:LinkLoadBalancerOutRange)
CREATE (nat)-[:OUT]->(outRange)
MERGE  (outRangeLow:  IPv4Address {
    address: llb.outRangeLow
})
CREATE (outRange)-[:LOW_ADDRESS]->(outRangeLow)
MERGE  (outRangeHigh:  IPv4Address {
    address: llb.outRangeHigh
})
CREATE (outRange)-[:HIGH_ADDRESS]->(outRangeHigh)
;