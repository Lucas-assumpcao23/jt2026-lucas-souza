# Validação de Retorno — Comparação Investimento
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$outputsDir = Join-Path $baseDir "outputs"

Write-Host "=== VALIDACAO RETORNO ===" -ForegroundColor Cyan

function To-Double($v) { if ($v -and $v -match '^\d+[\.,]?\d*$') { [double]($v -replace ',','.') } else { $null } }
function Get-Median($arr) { $s = $arr | Sort-Object; if ($s.Count -eq 0) { return $null }; $s[[math]::Floor($s.Count / 2)] }
function Get-Pct($arr, $p) { $s = $arr | Sort-Object; $s[[math]::Floor($s.Count * $p)] }

# Carregar dados
$airbnbRaw = Import-Csv (Join-Path $outputsDir "base_airbnb_consolidada.csv") -Encoding UTF8
$vivaRaw = Import-Csv (Join-Path $outputsDir "vivareal_base_tratada.csv") -Encoding UTF8

# Morretes 1q validado
$mr1qAll = @()
foreach ($r in $vivaRaw) {
    $br = if ($r.bedrooms -match '^\d+$') { [int]$r.bedrooms } else { $null }
    $ua = To-Double $r.usable_area
    if ($r.suburb -eq "Morretes" -and $br -eq 1 -and $ua -and $ua -ge 20 -and $ua -le 100) {
        $sp = To-Double $r.sale_price
        $ppm2 = if ($sp -and $ua -and $ua -gt 0) { [math]::Round($sp / $ua, 2) } else { $null }
        $mr1qAll += [PSCustomObject]@{ sp=$sp; ua=$ua; ppm2=$ppm2 }
    }
}
$mrSPs = $mr1qAll | ForEach-Object { $_.sp } | Where-Object { $_ -ne $null } | Sort-Object
$mrPPs = $mr1qAll | ForEach-Object { $_.ppm2 } | Where-Object { $_ -ne $null } | Sort-Object
$spP1 = Get-Pct $mrSPs 0.01; $spP99 = Get-Pct $mrSPs 0.99
$ppP1 = Get-Pct $mrPPs 0.01; $ppP99 = Get-Pct $mrPPs 0.99
$mr1qFinal = $mr1qAll | Where-Object { $_.sp -ge $spP1 -and $_.sp -le $spP99 -and $_.ppm2 -ge $ppP1 -and $_.ppm2 -le $ppP99 }

# Segmentos
$segments = @(
    @{ label="Centro 1q"; aSuburb="Centro"; aBr=1; vSuburb="Centro"; vBr=1; useMR=$false }
    @{ label="Centro 2q"; aSuburb="Centro"; aBr=2; vSuburb="Centro"; vBr=2; useMR=$false }
    @{ label="Centro 3q"; aSuburb="Centro"; aBr=3; vSuburb="Centro"; vBr=3; useMR=$false }
    @{ label="Meia Praia 1q"; aSuburb="Meia Praia"; aBr=1; vSuburb="Meia Praia"; vBr=1; useMR=$false }
    @{ label="Meia Praia 2q"; aSuburb="Meia Praia"; aBr=2; vSuburb="Meia Praia"; vBr=2; useMR=$false }
    @{ label="Meia Praia 3q"; aSuburb="Meia Praia"; aBr=3; vSuburb="Meia Praia"; vBr=3; useMR=$false }
    @{ label="Meia Praia 4q"; aSuburb="Meia Praia"; aBr=4; vSuburb="Meia Praia"; vBr=4; useMR=$false }
    @{ label="Morretes 1q"; aSuburb="Morretes"; aBr=1; vSuburb="Morretes"; vBr=1; useMR=$true }
    @{ label="Morretes 2q"; aSuburb="Morretes"; aBr=2; vSuburb="Morretes"; vBr=2; useMR=$false }
    @{ label="Morretes 3q"; aSuburb="Morretes"; aBr=3; vSuburb="Morretes"; vBr=3; useMR=$false }
)

$results = @()
foreach ($seg in $segments) {
    # Airbnb
    $aMembers = @()
    foreach ($r in $airbnbRaw) {
        $dm = To-Double $r.diaria_mediana
        $ds = if ($r.datas_estadia -match '^\d+$') { [int]$r.datas_estadia } else { 0 }
        $br = if ($r.number_of_bedrooms -match '^\d+$') { [int]$r.number_of_bedrooms } else { $null }
        if ($ds -ge 30 -and $dm -ge 150 -and $dm -le 2500 -and $r.listing_type -eq "apartamento" -and
            $r.suburb -eq $seg.aSuburb -and $br -eq $seg.aBr) {
            $aMembers += [PSCustomObject]@{
                dm=$dm; d25=To-Double $r.diaria_p25; d75=To-Double $r.diaria_p75
            }
        }
    }
    $aQtd = $aMembers.Count
    $aDMs = $aMembers | ForEach-Object { $_.dm } | Where-Object { $_ -ne $null }
    $aD25s = $aMembers | ForEach-Object { $_.d25 } | Where-Object { $_ -ne $null }

    # VivaReal
    if ($seg.useMR) {
        $vMembers = $mr1qFinal
    } else {
        $vMembers = @()
        foreach ($r in $vivaRaw) {
            $br = if ($r.bedrooms -match '^\d+$') { [int]$r.bedrooms } else { $null }
            if ($r.suburb -eq $seg.vSuburb -and $br -eq $seg.vBr) {
                $sp = To-Double $r.sale_price
                $vMembers += [PSCustomObject]@{ sp=$sp }
            }
        }
    }
    $vQtd = $vMembers.Count
    $vSPs = $vMembers | ForEach-Object { $_.sp } | Where-Object { $_ -ne $null }

    $dm = Get-Median $aDMs; $d25 = Get-Median $aD25s; $sp = Get-Median $vSPs

    # Robustez
    $robustez = if ($aQtd -ge 30) { "adequada" } elseif ($aQtd -ge 10) { "pequena" } else { "insuficiente" }

    # Retornos recalculados
    $ret55 = if ($dm -and $sp -and $sp -gt 0) { [math]::Round($dm * 365 * 0.55 / $sp * 100, 2) } else { $null }
    $retP25 = if ($d25 -and $sp -and $sp -gt 0) { [math]::Round($d25 * 365 * 0.55 / $sp * 100, 2) } else { $null }
    $oc7 = if ($dm -and $dm -gt 0 -and $sp -and $sp -gt 0) { [math]::Round(0.07 * $sp / ($dm * 365) * 100, 1) } else { $null }

    $results += [PSCustomObject]@{
        segmento=$seg.label; bairro=$seg.aSuburb; quartos=$seg.aBr
        a_qtd=$aQtd; a_dm=$dm; a_d25=$d25; robustez=$robustez
        v_qtd=$vQtd; v_sp=$sp; ret55=$ret55; retP25=$retP25; oc7=$oc7
    }
}

# Ordenar por retorno 55%
$ranked = $results | Sort-Object ret55 -Descending

Write-Host "`n--- TABELA VALIDADA ---" -ForegroundColor Yellow
Write-Host ("  {0,-18} {1,8} {2,8} {3,8} {4,8} {5,10} {6,8} {7,8} {8,8} {9,8}" -f
    "Segmento", "QtdAirbnb", "DM", "P25", "Robustez", "QtdVR", "SP", "Ret55%", "RetP25%", "Oc7%")
foreach ($r in $ranked) {
    $dmStr = if ($r.a_dm) { "{0:N0}" -f $r.a_dm } else { "N/A" }
    $d25Str = if ($r.a_d25) { "{0:N0}" -f $r.a_d25 } else { "N/A" }
    $spStr = if ($r.v_sp) { "{0:N0}" -f $r.v_sp } else { "N/A" }
    $r55Str = if ($r.ret55 -ne $null) { "{0:N2}%" -f $r.ret55 } else { "N/A" }
    $r25Str = if ($r.retP25 -ne $null) { "{0:N2}%" -f $r.retP25 } else { "N/A" }
    $oc7Str = if ($r.oc7) { "{0:N1}%" -f $r.oc7 } else { "N/A" }
    Write-Host ("  {0,-18} {1,8} {2,8} {3,8} {4,8} {5,10} {6,8} {7,8} {8,8} {9,8}" -f
        $r.segmento, $r.a_qtd, $dmStr, $d25Str, $r.robustez, $r.v_qtd, $spStr, $r55Str, $r25Str, $oc7Str)
}

# Top por robustez
Write-Host "`n--- TOP POR ROBUSTEZ ---" -ForegroundColor Yellow
$adequados = $ranked | Where-Object { $_.robustez -eq "adequada" }
Write-Host "  Adequada (>=30):"
$adequados | ForEach-Object { Write-Host ("    {0}: Ret55={1:N2}% RetP25={2:N2}%" -f $_.segmento, $_.ret55, $_.retP25) }

$pequenos = $ranked | Where-Object { $_.robustez -eq "pequena" }
Write-Host "  Pequena (10-29):"
$pequenos | ForEach-Object { Write-Host ("    {0}: Ret55={1:N2}% RetP25={2:N2}%" -f $_.segmento, $_.ret55, $_.retP25) }

Write-Host "`n=== FIM ===" -ForegroundColor Cyan
