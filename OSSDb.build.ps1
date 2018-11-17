Param(
    [String]
    $SourcesPath = "$PSScriptRoot\Sources",

    [String]
    $OutputPath = "$PSScriptRoot\Output"
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

Task CleanImportPath {
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
        ORDER by scope, label
"@ | Format-Table

    Invoke-Neo4j -Session $Session -Query @"
        MATCH (a:Anomaly) 
        RETURN a.code AS code, count(DISTINCT a) AS value
        ORDER BY code
"@ | Format-Table
}

Task ExportAnomalies {
    "lb_backend_ip_without_ips_entry", "lb_backend_ip_without_backend", "lb_backend_ip_without_node_info" | ForEach-Object {
        Invoke-Neo4j -Session $Session -Query @"
            MATCH (a:Anomaly {code: '$_' })<-[:HAS_ANOMALY]-(lb:LoadBalancer) 
            MATCH (a)<-[:HAS_ANOMALY]-(ip:IPv4Address) 
            WITH a, lb, collect(DISTINCT ip) as ips
            ORDER by a.description
            RETURN a.description AS description, lb.name as lbName, 
                reduce(s = head(ips).address, n IN tail(ips) | s + ', ' + n.address) as IPs
"@ | Export-Csv "$OutputPath/$_.csv" -Encoding utf8
    }

    Invoke-Neo4j -Session $Session -Query @"
        MATCH (a:Anomaly {code: 'llb_fqdn_without_dns' })<-[:HAS_ANOMALY]-(llb:LinkLoadBalancerNat) 
        MATCH (a)<-[:HAS_ANOMALY]-(fqdn:LinkLoadBalancerFQDN)
        WITH a, llb, fqdn
        ORDER by a.description
        RETURN a.description AS description, llb.node as llbNode, fqdn.fqdn as FQDN
"@ | Export-Csv "$OutputPath/llb_fqdn_without_dns.csv" -Encoding utf8

    Invoke-Neo4j -Session $Session -Query @"
        MATCH (a:Anomaly {code: 'llb_internal_ip_without_ips_entry' })<-[:HAS_ANOMALY]-(llb:LinkLoadBalancerNat) 
        MATCH (a)<-[:HAS_ANOMALY]-(ip:IPv4Address)
        WITH a, llb, collect(DISTINCT ip) as ips
        ORDER by a.description
        RETURN a.description AS description, llb.node as llbNode, 
            reduce(s = head(ips).address, n IN tail(ips) | s + ', ' + n.address) as IPs
"@ | Export-Csv "$OutputPath/llb_internal_ip_without_ips_entry.csv" -Encoding utf8

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