(Get-Content -Raw $PSScriptRoot/reload.cypher) -split ';' | ForEach-Object {
    $Session.Run($_)
}

$Session.Dispose()