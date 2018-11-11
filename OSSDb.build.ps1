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
        (Get-Content -Raw $_) -split ';' | # TODO: potential bug if ; in comments, also multiline
        Where-Object { -not [String]::IsNullOrWhiteSpace(($_ -replace '//.*', '')) } |
        ForEach-Object {
            Write-Verbose "Processing reload command:`n$_"
            Invoke-Neo4j -Session $Session -Query $_
        }
    }
}

Task Clean {
    Get-ChildItem $Config.Neo4jImportPath -Recurse -Include '*.csv' | Remove-Item -Force
}

Task CleanDatabase {
    $Session.Run("MATCH(a) DETACH DELETE a")
}

Task PrepareImports -Partial -Inputs {
    Get-ChildItem -Recurse $SourcesPath -File
} -Outputs { 
    process { 
        Join-Path $Config.Neo4jImportPath (Split-Path $_ -Leaf)
    }
} {
    begin {
        New-Item $Config.Neo4jImportPath -Force -Type Container > $Null
    }
    process {
        Write-Host "-- Processing $_ -> $2"
        Copy-Item -Path $_ -Destination $2 
    }
}

Task Analysis CleanDatabase, Import, {
    Write-Information "Analysing..."
    Get-ChildItem -Recurse $PSScriptRoot\Scripts\Analysis -Include *.cypher |
    Sort-Object -Property Name |
    ForEach-Object {
        Write-Information "Processing reload script $_..."
        (Get-Content -Raw $_) -split ';' | # TODO: potential bug if ; in comments, also multiline
        Where-Object { -not [String]::IsNullOrWhiteSpace(($_ -replace '//.*', '')) } |
        ForEach-Object {
            Write-Verbose "Processing reload command:`n$_"
            Invoke-Neo4j -Session $Session -Query $_ -Parameters $Config.AnalysisParameters
        }
    }

    Invoke-Neo4j -Session $Session -Query @"
        MATCH (m:Metric) 
        RETURN m.scope as scope, m.label as label, m.value as value
"@ | Sort-Object -Property scope, label
}

Task Export {
    Invoke-Neo4j -Session $Session -Query @'
        MATCH (a:Anomaly)<--(n) 
        WHERE a.code IN $codes
        WITH a, collect(DISTINCT n) as n
        RETURN a, n
'@ -Parameters @{ codes = @('llb_fqdn_without_dns', 'dummy')}
}

function Invoke-Neo4j {
    Param(
        [Parameter(Mandatory)]
        $Session,

        [Parameter(Mandatory)]
        [String]
        $Query,
        
        [Hashtable]
        $Parameters
    )
    if ($parameters) {
        $queryParams = [System.Collections.Generic.Dictionary[string,System.Object]]::new()
        $Parameters.GetEnumerator() | ForEach-Object {
            $queryParams.Add([String]($_.Name), $_.Value) 
        }

        $result = $Session.Run($Query, $queryParams).Values
    } else {
        $result = $Session.Run($Query).Values
    }
    foreach($record in $result) {
        $record.Keys | ForEach-Object { $res = [PSCustomObject]::new() } {
            Add-Member -MemberType NoteProperty -Name $_ -Value $record[$_] -InputObject $res
        } { $res }
    }
}