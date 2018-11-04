. $PSScriptRoot\Connect.ps1

New-Item $Neo4jImportPath -Force -Type Container > $Null

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
    Get-ChildItem $Neo4jImportPath -Recurse -Include '*.csv' | Remove-Item -Force
}

Task CleanDatabase {
    
    $Session.Run("MATCH (a)-[r]-(b) DETACH DELETE r,a,b")
    $Session.Run("MATCH(a) DETACH DELETE a")
}

Task PrepareImports -Partial -Inputs { 
    Get-ChildItem -Recurse $PSScriptRoot\Sources -File
} -Outputs { 
    process { 
        Join-Path $Neo4jImportPath (Split-Path $_ -Leaf)
    }
} {
    process {
        Write-Host "-- Processing $_"
        cp $_ $2 
    }
}
