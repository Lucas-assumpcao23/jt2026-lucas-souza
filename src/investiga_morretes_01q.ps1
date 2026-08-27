# Investigação Morretes 0-1q — VivaReal
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$outputsDir = Join-Path $baseDir "outputs"
$analysisDir = Join-Path $baseDir "analysis"

Write-Host "=== INVESTIGACAO MORRETES 0-1Q ===" -ForegroundColor Cyan

# Usar base tratada
$base = Import-Csv (Join-Path $outputsDir "vivareal_base_tratada.csv") -Encoding UTF8

function To-Double($v) { if ($v -and $v -match '^\d+[\.,]?\d*$') { [double]($v -replace ',','.') } else { $null } }
function Get-Pct($arr, $p) { $s = $arr | Sort-Object; $s[[math]::Floor($s.Count * $p)] }
function Get-Median($arr) { $s = $arr | Sort-Object; if ($s.Count -eq 0) { return $null }; $s[[math]::Floor($s.Count / 2)] }

# Filtrar Morretes 0-1q
$morretes = $base | Where-Object { $_.suburb -eq "Morretes" }
$m0 = @(); $m1 = @()
foreach ($r in $morretes) {
    $br = if ($r.bedrooms -match '^\d+$') { [int]$r.bedrooms } else { $null }
    if ($br -eq 0) { $m0 += $r }
    elseif ($br -eq 1) { $m1 += $r }
}

Write-Host "  Morretes total: $($morretes.Count)"
Write-Host "  0 quartos: $($m0.Count)"
Write-Host "  1 quarto: $($m1.Count)"

# Funcao para metricas
function Show-Metrics($label, $arr) {
    Write-Host "`n--- $label ($($arr.Count) registros) ---" -ForegroundColor Yellow
    if ($arr.Count -eq 0) { Write-Host "  Nenhum registro"; return }

    $sps = $arr | ForEach-Object { To-Double $_.sale_price } | Where-Object { $_ -ne $null } | Sort-Object
    $uas = $arr | ForEach-Object { To-Double $_.usable_area } | Where-Object { $_ -ne $null } | Sort-Object
    $ppm2s = @()
    foreach ($r in $arr) {
        $sp = To-Double $r.sale_price; $ua = To-Double $r.usable_area
        if ($sp -and $ua -and $ua -gt 0) { $ppm2s += [math]::Round($sp / $ua, 2) }
    }
    $ppm2s = $ppm2s | Sort-Object

    Write-Host ("  SP mediana: {0:N0}" -f (Get-Median $sps))
    Write-Host ("  Area mediana: {0} m2" -f (Get-Median $uas))
    if ($uas.Count -ge 4) {
        $a25 = Get-Pct $uas 0.25; $a75 = Get-Pct $uas 0.75
        Write-Host ("  Area P25: {0} m2 | P75: {1} m2" -f $a25, $a75)
    }
    Write-Host ("  Pm2 mediana: {0:N0}" -f (Get-Median $ppm2s))

    # Top 5 areas
    $sorted = $arr | Sort-Object { To-Double $_.usable_area } -Descending | Select-Object -First 5
    Write-Host "  Top 5 maiores areas:"
    foreach ($r in $sorted) {
        $ua = To-Double $r.usable_area; $sp = To-Double $r.sale_price
        $br = $r.bedrooms; $lt = $r.listing_type
        $title = if ($r.listing_title.Length -gt 80) { $r.listing_title.Substring(0, 80) + "..." } else { $r.listing_title }
        Write-Host ("    {0}m2 | R${1:N0} | {2}q | {3} | {4}" -f $ua, $sp, $br, $lt, $title)
    }

    # Listing titles dos top 5
    Write-Host "  Listing titles (top 5 area):"
    foreach ($r in $sorted) {
        Write-Host ("    [{0}] {1}" -f $r.listing_id, $r.listing_title)
    }
}

Show-Metrics "0 QUARTOS - MORRETES" $m0
Show-Metrics "1 QUARTO - MORRETES" $m1

# Analise qualitativa 0 quartos
Write-Host "`n--- CLASSIFICACAO 0 QUARTOS ---" -ForegroundColor Yellow
$titulos0 = $m0 | ForEach-Object {
    $t = $_.listing_title.ToLower()
    $ua = To-Double $_.usable_area
    $sp = To-Double $_.sale_price
    [PSCustomObject]@{ title=$t; ua=$ua; sp=$sp; lt=$_.listing_type; br=$_.bedrooms }
}
Write-Host "  Titles 0 quartos:"
$titulos0 | ForEach-Object { Write-Host ("    [{0}m2] {1}" -f $_.ua, $_.title) }

# Analise 1 quarto com filtros
Write-Host "`n--- 1 QUARTO FILTRADO ---" -ForegroundColor Yellow
$m1f = $m1 | Where-Object {
    $ua = To-Double $_.usable_area
    $sp = To-Double $_.sale_price
    ($ua -and $ua -gt 0 -and $ua -ge 20 -and $ua -le 100)
}
Write-Host ("  1q com area 20-100m2: $($m1f.Count) de $($m1.Count)")

# Filtrar pm2 P1-P99
$ppm2s_all = @()
foreach ($r in $m1f) {
    $sp = To-Double $r.sale_price; $ua = To-Double $r.usable_area
    if ($sp -and $ua -and $ua -gt 0) { $ppm2s_all += [math]::Round($sp / $ua, 2) }
}
if ($ppm2s_all.Count -ge 4) {
    $p1 = Get-Pct $ppm2s_all 0.01; $p99 = Get-Pct $ppm2s_all 0.99
    $sp_all = $m1f | ForEach-Object { To-Double $_.sale_price } | Where-Object { $_ -ne $null } | Sort-Object
    $sp_p1 = Get-Pct $sp_all 0.01; $sp_p99 = Get-Pct $sp_all 0.99
    Write-Host ("  Pm2 P1={0:N0} P99={1:N0}" -f $p1, $p99)
    Write-Host ("  SP P1={0:N0} P99={1:N0}" -f $sp_p1, $sp_p99)

    $m1ff = $m1f | Where-Object {
        $sp = To-Double $_.sale_price; $ua = To-Double $_.usable_area
        $p = if ($sp -and $ua -and $ua -gt 0) { $sp / $ua } else { $null }
        $sp -ge $sp_p1 -and $sp -le $sp_p99 -and $p -ge $p1 -and $p -le $p99
    }
    Write-Host ("  Apos filtro P1-P99: $($m1ff.Count)")

    Show-Metrics "1 QUARTO FILTRADO (area 20-100, pm2 P1-P99)" $m1ff
} else {
    Write-Host "  Dados insuficientes para filtro P1-P99"
}

Write-Host "`n=== FIM ===" -ForegroundColor Cyan
