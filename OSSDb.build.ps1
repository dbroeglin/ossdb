Param(
    [String]
    $SourcesPath = "$PSScriptRoot\Sources"
)
. $PSScriptRoot\Connect.ps1

Task Reload CleanDatabase, Import

Task Import PrepareImports, {
    Get-ChildItem -Recurse $PSScriptRoot\Scripts\Import -Include *.cypher |
    Sort-Object -Property Name |
    ForEach-Object {
        Write-Information "Processing reload script $_..."
        (Get-Content -Raw $_) -split ';' |
        Where-Object { -not [String]::IsNullOrWhiteSpace($_) } |
        ForEach-Object {
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
    Get-ChildItem -Recurse $SourcesPath -File
} -Outputs { 
    process { 
        Join-Path $Neo4jImportPath (Split-Path $_ -Leaf)
    }
} {
    begin {
        New-Item $Neo4jImportPath -Force -Type Container > $Null
    }
    process {
        Write-Host "-- Processing $_ -> $2"
        Copy-Item -Path $_ -Destination $2 
    }
}
