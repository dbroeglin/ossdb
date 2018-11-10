$Config = @{
  Neo4jUsername      = 'neo4j'
  Neo4jPassword      = 'neo4j'
  Neo4jImportPath    = '/usr/local/Cellar/neo4j/3.4.5/libexec/import/'

  AnalysisParameters = @{
    LoadBalancerIPRegex = '1\.0\.[23]\..*' 
  }
}