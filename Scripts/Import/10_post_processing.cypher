
// Create a :RELATED_TO link between NAT FQDN and Apache FQDN

MATCH (nat:LinkLoadBalancerNat)-[:HAS_FQDN]->(llbFQDN:LinkLoadBalancerFQDN)
MATCH (vhost:ApacheVirtualHost)-[a:HAS_FQDN]->(vhostFQDN:ApacheFQDN)
WHERE vhostFQDN.fqdn = llbFQDN.fqdn
MERGE (vhostFQDN)-[:RELATED_TO]->(llbFQDN)
;

