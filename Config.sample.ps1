$Config = @{
  Neo4jUsername      = 'neo4j'
  Neo4jPassword      = 'neo4j'
  Neo4jImportPath    = '/usr/local/Cellar/neo4j/3.4.5/libexec/import/'

  AnalysisParameters = @{
    # Matched IPs are considered LB VIPs and are not expected to have an attached node
    LoadBalancerIPRegex = '1\.0\.[23]\..*'
    
    # Only consider zones contained in those hosts as external
    ExternalDNSNodes    = @('dnssrv1') 
  }
} 