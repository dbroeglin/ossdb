$Neo4jVersion = "3.4.5"
$ImportPath = "/usr/local/Cellar/neo4j/$Neo4jVersion/libexec/import/"
New-Item $ImportPath -Force -Type Container > $Null

. $PSScriptRoot\Connect.ps1

Task Import PrepareImports, {
    Get-ChildItem -Recurse $PSScriptRoot\Sources -Include Reload.cypher | ForEach-Object {
        Write-Verbose "Processing reload script $_..."
        (Get-Content -Raw $_) -split ';' | ForEach-Object {
            Write-Verbose "Processing reload command:`n$_"
            $Session.Run($_)
        }
    }
}

Task Clean {
    Get-ChildItem $ImportPath -Recurse -Include '*.csv' | Remove-Item -Force
}

Task CleanDatabase {
    
    $Session.Run("MATCH (a)-[r]-(b) DETACH DELETE r,a,b")
    $Session.Run("MATCH(a) DETACH DELETE a")
}

Task PrepareImports -Partial -Inputs { 
    Get-ChildItem -Recurse $PSScriptRoot\Sources -File
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
