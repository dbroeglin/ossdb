. $PSScriptRoot/Config.ps1

Add-Type -Path "$PSScriptRoot/nuget/Neo4j.Driver.1.6.1/lib/net452/Neo4j.Driver.dll"
Function Invoke-Cypher($query) {
  $session.Run($query)
}

$authToken = [Neo4j.Driver.V1.AuthTokens]::Basic($Neo4jUsername, $Neo4jPassword)

$dbDriver = [Neo4j.Driver.V1.GraphDatabase]::Driver("bolt://localhost:7687",$authToken)
$session = $dbDriver.Session()
