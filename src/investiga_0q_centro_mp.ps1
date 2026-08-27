# Investigação 0 Quartos — Centro e Meia Praia
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$outputsDir = Join-Path $baseDir "outputs"

Write-Host "=== INVESTIGACAO 0 QUARTOS - CENTRO E MEIA PRAIA ===" -ForegroundColor Cyan

$base = Import-Csv (Join-Path $outputsDir "vivareal_base_tratada.csv") -Encoding UTF8

function To-Double($v) { if ($v -and $v -match '^\d+[\.,]?\d*$') { [double]($v -replace ',','.') } else { $null } }

# Filtrar 0 quartos Centro e Meia Praia
$zqCentro = @(); $zqMP = @()
foreach ($r in $base) {
    $br = if ($r.bedrooms -match '^\d+$') { [int]$r.bedrooms } else { $null }
    if ($br -eq 0 -and $r.suburb -eq "Centro") { $zqCentro += $r }
    elseif ($br -eq 0 -and $r.suburb -eq "Meia Praia") { $zqMP += $r }
}

Write-Host "  0q Centro: $($zqCentro.Count)"
Write-Host "  0q Meia Praia: $($zqMP.Count)"

# Funcao para classificar
function Classify-Record($r) {
    $title = if ($r.listing_title) { $r.listing_title.ToLower() } else { "" }
    $lt = if ($r.listing_type) { $r.listing_type.ToLower() } else { "" }
    $pt = if ($r.property_type) { $r.property_type.ToLower() } else { "" }
    $bt = if ($r.business_types) { $r.business_types.ToLower() } else { "" }
    $ua = To-Double $r.usable_area

    # Terrenos
    if ($title -match 'terreno|lote|terrain|lot ' -or $lt -match 'terreno' -or $pt -match 'terreno|lote') {
        return "TERRENO"
    }
    # Salas/comerciais
    if ($title -match 'sala comercial|salas comerciais|loja|comercial|escritorio|store|office|galpao' -or
        $lt -match 'comercial' -or $pt -match 'comercial' -or $bt -match 'commercial') {
        return "COMERCIAL"
    }
    # Empreendimentos (nomes proprios sem tipologia clara)
    if ($title -match 'dreams village|augustus|residence|hotel|pousada|resort|hostel') {
        return "EMPREENDIMENTO"
    }
    # Studios residenciais (hipotese: area residencial, sem indicacao comercial)
    if (($ua -and $ua -gt 0 -and $ua -lt 120) -and
        ($lt -match 'apartamento|residencial|flat|studio|kitnet' -or $pt -match 'apartamento|residencial') -and
        ($title -notmatch 'terreno|lote|sala|loja|comercial|escritorio')) {
        return "STUDIO_RESIDENCIAL"
    }
    # Sem quartos informados
    if ($title -match 'quartos?|dormitorios?|suites?' -and $title -notmatch '0 quartos|nenhum quarto') {
        return "SEM_QUARTOS"
    }
    return "AMBIGUO"
}

# Classificar
Write-Host "`n--- CLASSIFICACAO 0Q CENTRO ---" -ForegroundColor Yellow
$clsC = @()
foreach ($r in $zqCentro) {
    $cls = Classify-Record $r
    $ua = To-Double $r.usable_area
    $sp = To-Double $r.sale_price
    $clsC += [PSCustomObject]@{
        id=$r.listing_id; title=$r.listing_title; lt=$r.listing_type; pt=$r.property_type
        bt=$r.business_types; ua=$ua; sp=$sp; class=$cls
    }
}
$grpC = $clsC | Group-Object class | Sort-Object Count -Descending
$grpC | ForEach-Object { Write-Host ("  {0,-25} {1,4}" -f $_.Name, $_.Count) }

Write-Host "`n--- CLASSIFICACAO 0Q MEIA PRAIA ---" -ForegroundColor Yellow
$clsM = @()
foreach ($r in $zqMP) {
    $cls = Classify-Record $r
    $ua = To-Double $r.usable_area
    $sp = To-Double $r.sale_price
    $clsM += [PSCustomObject]@{
        id=$r.listing_id; title=$r.listing_title; lt=$r.listing_type; pt=$r.property_type
        bt=$r.business_types; ua=$ua; sp=$sp; class=$cls
    }
}
$grpM = $clsM | Group-Object class | Sort-Object Count -Descending
$grpM | ForEach-Object { Write-Host ("  {0,-25} {1,4}" -f $_.Name, $_.Count) }

# Detalhes dos studios residenciais
Write-Host "`n--- STUDIOS RESIDENCIAIS 0Q CENTRO ---" -ForegroundColor Yellow
$studiosC = $clsC | Where-Object { $_.class -eq "STUDIO_RESIDENCIAL" }
$studiosC | ForEach-Object {
    $uaStr = if ($_.ua) { "{0:N0}m2" -f $_.ua } else { "?" }
    $spStr = if ($_.sp) { "R${0:N0}" -f $_.sp } else { "?" }
    Write-Host ("  [{0}] {1} | {2} | {3} | {4} | {5}" -f $_.id, $uaStr, $spStr, $_.lt, $_.pt, $_.title.Substring(0, [math]::Min(70, $_.title.Length)))
}

Write-Host "`n--- STUDIOS RESIDENCIAIS 0Q MEIA PRAIA ---" -ForegroundColor Yellow
$studiosM = $clsM | Where-Object { $_.class -eq "STUDIO_RESIDENCIAL" }
$studiosM | ForEach-Object {
    $uaStr = if ($_.ua) { "{0:N0}m2" -f $_.ua } else { "?" }
    $spStr = if ($_.sp) { "R${0:N0}" -f $_.sp } else { "?" }
    Write-Host ("  [{0}] {1} | {2} | {3} | {4} | {5}" -f $_.id, $uaStr, $spStr, $_.lt, $_.pt, $_.title.Substring(0, [math]::Min(70, $_.title.Length)))
}

# Detalhes dos ambiguos
Write-Host "`n--- AMBIGUOS 0Q CENTRO ---" -ForegroundColor Yellow
$ambC = $clsC | Where-Object { $_.class -eq "AMBIGUO" }
$ambC | ForEach-Object {
    $uaStr = if ($_.ua) { "{0:N0}m2" -f $_.ua } else { "?" }
    $spStr = if ($_.sp) { "R${0:N0}" -f $_.sp } else { "?" }
    Write-Host ("  [{0}] {1} | {2} | {3} | {4} | {5} | bt:{6}" -f $_.id, $uaStr, $spStr, $_.lt, $_.pt, $_.title.Substring(0, [math]::Min(60, $_.title.Length)), $_.bt)
}

Write-Host "`n--- AMBIGUOS 0Q MEIA PRAIA ---" -ForegroundColor Yellow
$ambM = $clsM | Where-Object { $_.class -eq "AMBIGUO" }
$ambM | ForEach-Object {
    $uaStr = if ($_.ua) { "{0:N0}m2" -f $_.ua } else { "?" }
    $spStr = if ($_.sp) { "R${0:N0}" -f $_.sp } else { "?" }
    Write-Host ("  [{0}] {1} | {2} | {3} | {4} | {5} | bt:{6}" -f $_.id, $uaStr, $spStr, $_.lt, $_.pt, $_.title.Substring(0, [math]::Min(60, $_.title.Length)), $_.bt)
}

Write-Host "`n=== FIM ===" -ForegroundColor Cyan
