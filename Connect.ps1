. $PSScriptRoot/Config.ps1

if ($env:NEO4J_USERNAME) {
  $Config.Neo4jUsername = $env:NEO4J_USERNAME
} 
if ($env:NEO4J_PASSWORD) {
  $Config.Neo4jPassword = $env:NEO4J_PASSWORD
}
if ($env:NEO4J_IMPORT_PATH) {
  $Config.Neo4jImportPath = $env:NEO4J_IMPORT_PATH
}

Add-Type -Path "$PSScriptRoot/nuget/Neo4j.Driver.1.6.1/lib/net452/Neo4j.Driver.dll"
Function Invoke-Cypher($query) {
  $session.Run($query)
}

$authToken = [Neo4j.Driver.V1.AuthTokens]::Basic($Config.Neo4jUsername, $Config.Neo4jPassword)

$dbDriver = [Neo4j.Driver.V1.GraphDatabase]::Driver("bolt://localhost:7687",$authToken)
$session = $dbDriver.Session()
