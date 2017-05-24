$Neo4jVersion = "3.1.4"
$ImportPath = "/usr/local/Cellar/neo4j/$Neo4jVersion/libexec/import/"
New-Item $ImportPath -Force -Type Container > $Null

. $PSScriptRoot\Connect.ps1

Task Import PrepareImports, {
    (Get-Content -Raw $PSScriptRoot/reload.cypher) -split ';' | ForEach-Object {
        $Session.Run($_)
    }
}

Task Clean {
    $Session.Run("MATCH (a)-[r]-(b) DETACH DELETE r,a,b")
    $Session.Run("MATCH(a) DETACH DELETE a")
}


task PrepareImports -Partial -Inputs { 
    Get-ChildItem data 
} -Outputs { 
    process { 
        Join-Path $ImportPath (Split-Path $_ -Leaf)
    }
} {
    process {
        Write-Host "-- Processing $_"
        cp $_ $2 
    }
}
