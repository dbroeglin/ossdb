Add-Type -Path "$PSScriptRoot/nuget/Neo4j.Driver.1.3.0/lib/net46/Neo4j.Driver.dll"

Function Invoke-Cypher($query) {
  $session.Run($query)
}

$authToken = [Neo4j.Driver.V1.AuthTokens]::Basic('neo4j','passw0rd')

$dbDriver = [Neo4j.Driver.V1.GraphDatabase]::Driver("bolt://localhost:7687",$authToken)
$session = $dbDriver.Session()