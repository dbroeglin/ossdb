if ($env:NEO4J_USERNAME) {
  $Neo4jUsername = $env:NEO4J_USERNAME
} else {
  $Neo4jUsername = 'neo4j'
}
if ($env:NEO4J_PASSWORD) {
  $Neo4jPassword = $env:NEO4J_PASSWORD
} else {
  $Neo4jPassword = 'passw0rd'
}
if ($env:NEO4J_IMPORT_PATH) {
  $Neo4jImportPath = $env:NEO4J_IMPORT_PATH
} else {
  $Neo4jImportPath = "/usr/local/Cellar/neo4j/3.4.5/libexec/import/"
}