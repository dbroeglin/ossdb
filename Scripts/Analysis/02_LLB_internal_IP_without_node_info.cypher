// all internal IPs associated to NAT with a Used status
MATCH (nat:LinkLoadBalancerNat)-[:IN]->(i)-[:LOW_ADDRESS|:HIGH_ADDRESS]->(ip:IPv4Address),
      (ipsEntry:IPSEntry {status: 'Used'})-[:HAS_ADDRESS]->(ip)
WHERE ipsEntry.lastSync > (datetime() - duration({days: 60})) AND // IPs seen in the last 2 months
      NOT ip.address =~ $DMZLoadBalancerIPRegex                      // exclude load balancer VIPs
OPTIONAL MATCH (n:Node)-[:HAS_ADDRESS]->(ip)                      // match associated nodes
WITH DISTINCT collect(nat) as nats, i, ipsEntry, ip, n
WHERE n IS NULL

MERGE (ip)-[:HAS_ANOMALY]->(ano:Anomaly {
  code: 'llb_internal_ip_without_node_info',
  description: "No Node information was found for IP '" + ip.address + "' (found though LLB IN)" 
})
WITH nats, ano
UNWIND nats as nat
CREATE (nat)-[:HAS_ANOMALY]->(ano)
;

