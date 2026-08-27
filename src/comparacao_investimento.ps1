# Comparação de Investimento — Airbnb vs VivaReal
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$outputsDir = Join-Path $baseDir "outputs"
$analysisDir = Join-Path $baseDir "analysis"

Write-Host "=== COMPARACAO INVESTIMENTO ===" -ForegroundColor Cyan

function To-Double($v) { if ($v -and $v -match '^\d+[\.,]?\d*$') { [double]($v -replace ',','.') } else { $null } }
function Get-Pct($arr, $p) { $s = $arr | Sort-Object; $s[[math]::Floor($s.Count * $p)] }
function Get-Median($arr) { $s = $arr | Sort-Object; if ($s.Count -eq 0) { return $null }; $s[[math]::Floor($s.Count / 2)] }

# ============================================================
# CARREGAR DADOS
# ============================================================
Write-Host "`n--- CARREGANDO DADOS ---" -ForegroundColor Yellow

# Airbnb
$airbnbRaw = Import-Csv (Join-Path $outputsDir "base_airbnb_consolidada.csv") -Encoding UTF8
$airbnb = @()
foreach ($r in $airbnbRaw) {
    $dm = To-Double $r.diaria_mediana
    $ds = if ($r.datas_estadia -match '^\d+$') { [int]$r.datas_estadia } else { 0 }
    $br = if ($r.number_of_bedrooms -match '^\d+$') { [int]$r.number_of_bedrooms } else { $null }
    $bg = if ($r.number_of_guests -match '^\d+$') { [int]$r.number_of_guests } else { $null }
    $d25 = To-Double $r.diaria_p25
    $d75 = To-Double $r.diaria_p75
    if ($ds -ge 30 -and $dm -ge 150 -and $dm -le 2500 -and $r.listing_type -eq "apartamento") {
        $airbnb += [PSCustomObject]@{
            id=$r.airbnb_listing_id; suburb=$r.suburb; br=$br; dm=$dm; d25=$d25; d75=$d75; guests=$bg
        }
    }
}
Write-Host "  Airbnb filtrado: $($airbnb.Count)"

# VivaReal
$vivarealRaw = Import-Csv (Join-Path $outputsDir "vivareal_base_tratada.csv") -Encoding UTF8
$viva = @()
foreach ($r in $vivarealRaw) {
    $sp = To-Double $r.sale_price
    $ua = To-Double $r.usable_area
    $br = if ($r.bedrooms -match '^\d+$') { [int]$r.bedrooms } else { $null }
    $ppm2 = if ($sp -and $ua -and $ua -gt 0) { [math]::Round($sp / $ua, 2) } else { $null }
    $viva += [PSCustomObject]@{
        id=$r.listing_id; suburb=$r.suburb; br=$br; sp=$sp; ua=$ua; ppm2=$ppm2
    }
}
Write-Host "  VivaReal total: $($viva.Count)"

# ============================================================
# MORRETES 1Q VALIDADO
# ============================================================
Write-Host "`n--- MORRETES 1Q VALIDADO ---" -ForegroundColor Yellow
$mr1qAll = $viva | Where-Object { $_.suburb -eq "Morretes" -and $_.br -eq 1 }
$mr1qValid = $mr1qAll | Where-Object { $_.ua -and $_.ua -ge 20 -and $_.ua -le 100 }
# P1-P99 para sp e ppm2
$mr1qSPs = $mr1qValid | ForEach-Object { $_.sp } | Where-Object { $_ -ne $null } | Sort-Object
$mr1qPPs = $mr1qValid | ForEach-Object { $_.ppm2 } | Where-Object { $_ -ne $null } | Sort-Object
$spP1 = Get-Pct $mr1qSPs 0.01; $spP99 = Get-Pct $mr1qSPs 0.99
$ppP1 = Get-Pct $mr1qPPs 0.01; $ppP99 = Get-Pct $mr1qPPs 0.99
$mr1qFinal = $mr1qValid | Where-Object {
    $_.sp -ge $spP1 -and $_.sp -le $spP99 -and $_.ppm2 -ge $ppP1 -and $_.ppm2 -le $ppP99
}
$mr1qSP = $mr1qFinal | ForEach-Object { $_.sp } | Where-Object { $_ -ne $null }
$mr1qUA = $mr1qFinal | ForEach-Object { $_.ua } | Where-Object { $_ -ne $null -and $_ -gt 0 }
$mr1qPP = $mr1qFinal | ForEach-Object { $_.ppm2 } | Where-Object { $_ -ne $null }
Write-Host ("  Morretes 1q validado: {0} registros (de {1})" -f $mr1qFinal.Count, $mr1qAll.Count)
Write-Host ("  SP mediana: {0:N0}" -f (Get-Median $mr1qSP))
Write-Host ("  Area mediana: {0}" -f (Get-Median $mr1qUA))
Write-Host ("  Pm2 mediana: {0:N0}" -f (Get-Median $mr1qPP))

# ============================================================
# DEFINICAO DOS 10 SEGMENTOS
# ============================================================
Write-Host "`n--- DEFINICAO DOS SEGMENTOS ---" -ForegroundColor Yellow
$segments = @(
    @{ label="Centro 1q"; aSuburb="Centro"; aBr=1; vSuburb="Centro"; vBr=1; useValidated=$false }
    @{ label="Centro 2q"; aSuburb="Centro"; aBr=2; vSuburb="Centro"; vBr=2; useValidated=$false }
    @{ label="Centro 3q"; aSuburb="Centro"; aBr=3; vSuburb="Centro"; vBr=3; useValidated=$false }
    @{ label="Meia Praia 1q"; aSuburb="Meia Praia"; aBr=1; vSuburb="Meia Praia"; vBr=1; useValidated=$false }
    @{ label="Meia Praia 2q"; aSuburb="Meia Praia"; aBr=2; vSuburb="Meia Praia"; vBr=2; useValidated=$false }
    @{ label="Meia Praia 3q"; aSuburb="Meia Praia"; aBr=3; vSuburb="Meia Praia"; vBr=3; useValidated=$false }
    @{ label="Meia Praia 4q"; aSuburb="Meia Praia"; aBr=4; vSuburb="Meia Praia"; vBr=4; useValidated=$false }
    @{ label="Morretes 1q"; aSuburb="Morretes"; aBr=1; vSuburb="Morretes"; vBr=1; useValidated=$true }
    @{ label="Morretes 2q"; aSuburb="Morretes"; aBr=2; vSuburb="Morretes"; vBr=2; useValidated=$false }
    @{ label="Morretes 3q"; aSuburb="Morretes"; aBr=3; vSuburb="Morretes"; vBr=3; useValidated=$false }
)

# ============================================================
# CALCULO POR SEGMENTO
# ============================================================
$results = @()
foreach ($seg in $segments) {
    # Airbnb
    $aMembers = $airbnb | Where-Object { $_.suburb -eq $seg.aSuburb -and $_.br -eq $seg.aBr }
    $aQtd = $aMembers.Count
    $aDMs = $aMembers | ForEach-Object { $_.dm } | Where-Object { $_ -ne $null }
    $aD25s = $aMembers | ForEach-Object { $_.d25 } | Where-Object { $_ -ne $null }
    $aD75s = $aMembers | ForEach-Object { $_.d75 } | Where-Object { $_ -ne $null }
    $aGsts = $aMembers | ForEach-Object { $_.guests } | Where-Object { $_ -ne $null }

    # VivaReal
    if ($seg.useValidated) {
        $vMembers = $mr1qFinal
    } else {
        $vMembers = $viva | Where-Object { $_.suburb -eq $seg.vSuburb -and $_.br -eq $seg.vBr }
    }
    $vQtd = $vMembers.Count
    $vSPs = $vMembers | ForEach-Object { $_.sp } | Where-Object { $_ -ne $null }
    $vUAs = $vMembers | ForEach-Object { $_.ua } | Where-Object { $_ -ne $null -and $_ -gt 0 }
    $vPPs = $vMembers | ForEach-Object { $_.ppm2 } | Where-Object { $_ -ne $null }

    $dm = Get-Median $aDMs; $d25 = Get-Median $aD25s; $d75 = Get-Median $aD75s; $gst = Get-Median $aGsts
    $sp = Get-Median $vSPs; $ua = Get-Median $vUAs; $pp = Get-Median $vPPs

    # Retorno bruto simplificado em 3 cenarios
    $ret40 = if ($dm -and $sp -and $sp -gt 0) { [math]::Round($dm * 365 * 0.40 / $sp * 100, 2) } else { $null }
    $ret55 = if ($dm -and $sp -and $sp -gt 0) { [math]::Round($dm * 365 * 0.55 / $sp * 100, 2) } else { $null }
    $ret70 = if ($dm -and $sp -and $sp -gt 0) { [math]::Round($dm * 365 * 0.70 / $sp * 100, 2) } else { $null }

    # Ocupacao necessaria para 7%
    $oc7 = if ($dm -and $dm -gt 0 -and $sp -and $sp -gt 0) { [math]::Round(0.07 * $sp / ($dm * 365) * 100, 1) } else { $null }

    # Retorno com P25
    $ret55_p25 = if ($d25 -and $sp -and $sp -gt 0) { [math]::Round($d25 * 365 * 0.55 / $sp * 100, 2) } else { $null }

    $results += [PSCustomObject]@{
        segmento = $seg.label
        a_qtd = $aQtd; a_dm = $dm; a_d25 = $d25; a_d75 = $d75; a_gst = $gst
        v_qtd = $vQtd; v_sp = $sp; v_ua = $ua; v_pp = $pp
        ret_40 = $ret40; ret_55 = $ret55; ret_70 = $ret70
        oc_7 = $oc7; ret55_p25 = $ret55_p25
    }
}

# ============================================================
# TABELA PRINCIPAL
# ============================================================
Write-Host "`n--- TABELA PRINCIPAL ---" -ForegroundColor Yellow
$results | Export-Csv (Join-Path $outputsDir "comparacao_investimento.csv") -NoTypeInformation -Encoding UTF8

Write-Host ("  {0,-18} {1,5} {2,8} {3,5} {4,12} {5,8} {6,10} {7,8} {8,7} {9,7} {10,7} {11,7}" -f
    "Segmento", "QtdA", "DM", "Hos", "QtdV", "SP", "Pm2", "Ret55%", "Ret40%", "Ret70%", "Oc7%", "Ret55_P25")
foreach ($r in $results) {
    $dmStr = if ($r.a_dm) { "{0:N0}" -f $r.a_dm } else { "N/A" }
    $spStr = if ($r.v_sp) { "{0:N0}" -f $r.v_sp } else { "N/A" }
    $ppStr = if ($r.v_pp) { "{0:N0}" -f $r.v_pp } else { "N/A" }
    $r55Str = if ($r.ret_55) { "{0:N1}%" -f $r.ret_55 } else { "N/A" }
    $r40Str = if ($r.ret_40) { "{0:N1}%" -f $r.ret_40 } else { "N/A" }
    $r70Str = if ($r.ret_70) { "{0:N1}%" -f $r.ret_70 } else { "N/A" }
    $oc7Str = if ($r.oc_7) { "{0:N1}%" -f $r.oc_7 } else { "N/A" }
    $r55p25Str = if ($r.ret55_p25) { "{0:N1}%" -f $r.ret55_p25 } else { "N/A" }
    Write-Host ("  {0,-18} {1,5} {2,8} {3,5} {4,12} {5,8} {6,10} {7,8} {8,7} {9,7} {10,7} {11,7}" -f
        $r.segmento, $r.a_qtd, $dmStr, $r.a_gst, $r.v_qtd, $spStr, $ppStr, $r55Str, $r40Str, $r70Str, $oc7Str, $r55p25Str)
}

# ============================================================
# RANKING POR RETORNO 55%
# ============================================================
Write-Host "`n--- RANKING RETORNO 55% ---" -ForegroundColor Yellow
$ranked = $results | Where-Object { $_.ret_55 -ne $null } | Sort-Object ret_55 -Descending
$i = 1
foreach ($r in $ranked) {
    Write-Host ("  {0}. {1}: {2:N1}% (DM={3:N0}, SP={4:N0}, oc7={5:N1}%)" -f $i, $r.segmento, $r.ret_55, $r.a_dm, $r.v_sp, $r.oc_7)
    $i++
}

Write-Host "`n=== FIM ===" -ForegroundColor Cyan
