# Análise de Mercado de Compra — VivaReal
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$dataDir = Join-Path $baseDir "data"
$outputsDir = Join-Path $baseDir "outputs"
$analysisDir = Join-Path $baseDir "analysis"

Write-Host "=== MERCADO DE COMPRA VIVAREAL ===" -ForegroundColor Cyan
$raw = Import-Csv (Join-Path $dataDir "VivaReal_Itapema.csv") -Encoding UTF8
Write-Host "  Linhas originais: $($raw.Count)"

# ============================================================
# 1. FUNCOES AUXILIARES
# ============================================================
function To-Double($v) { if ($v -and $v -match '^\d+[\.,]?\d*$') { [double]($v -replace ',','.') } else { $null } }
function Get-Pct($arr, $p) { $s = $arr | Sort-Object; $s[[math]::Floor($s.Count * $p)] }
function Get-Median($arr) { $s = $arr | Sort-Object; if ($s.Count -eq 0) { return $null }; $s[[math]::Floor($s.Count / 2)] }

# ============================================================
# 2. PADRONIZACAO DE BAIRROS
# ============================================================
Write-Host "`n--- PADRONIZACAO DE BAIRROS ---" -ForegroundColor Yellow
$bairroMap = @{
    "Tabuleiro" = "Tabuleiro dos Oliveiras"
    "Taboleiro" = "Tabuleiro dos Oliveiras"
    "Tabuleiro dos Oliveiras" = "Tabuleiro dos Oliveiras"
    "Sertaozinho" = "Sertaozinho"
    "Sertãozinho" = "Sertaozinho"
    "Sertao do Trombudo" = "Sertao do Trombudo"
    "Sertão do Trombudo" = "Sertao do Trombudo"
    "Alto Sao Bento" = "Alto Sao Bento"
    "Alto São Bento" = "Alto Sao Bento"
    "Meia Praia - Frente Mar" = "Meia Praia"
    "Meia Praia" = "Meia Praia"
    "Centro" = "Centro"
    "Morretes" = "Morretes"
    "Canto da Praia" = "Canto da Praia"
    "Casa Branca" = "Casa Branca"
    "Ilhota" = "Ilhota"
    "Varzea" = "Varzea"
    "Andorinha" = "Andorinha"
    "Castelo Branco" = "Castelo Branco"
    "Jardim Praia Mar" = "Jardim Praia Mar"
    "Ocean Tower" = "Ocean Tower"
    "Itapema" = "Itapema"
    "Estreito" = "Estreito"
}

$bairrosAntes = @{}
$bairrosDepois = @{}
foreach ($r in $raw) {
    $orig = $r.suburb
    if ($bairroMap.ContainsKey($orig)) {
        $novo = $bairroMap[$orig]
        if ($orig -ne $novo) {
            if (-not $bairrosAntes.ContainsKey($orig)) { $bairrosAntes[$orig] = 0 }
            $bairrosAntes[$orig]++
        }
        $r.suburb = $novo
    }
}
Write-Host "  Substituicoes de bairro:"
$bairrosAntes.GetEnumerator() | ForEach-Object { Write-Host ("    '{0}' -> '{1}': {2} registros" -f $_.Key, $bairroMap[$_.Key], $_.Value) }

# ============================================================
# 3. DEDUPLICACAO
# ============================================================
Write-Host "`n--- DEDUPLICACAO ---" -ForegroundColor Yellow
$antes = $raw.Count

# Detectar duplicatas
$groups = @{}
foreach ($r in $raw) {
    $id = $r.listing_id
    if (-not $groups.ContainsKey($id)) { $groups[$id] = @() }
    $groups[$id] += $r
}

$dupsExatas = 0
$dupsDiferentes = 0
$deduped = @()
foreach ($entry in $groups.GetEnumerator()) {
    $rows = $entry.Value
    if ($rows.Count -eq 1) {
        $deduped += $rows[0]
    } else {
        # Verificar se sao identicas
        $identical = $true
        $first = $rows[0]
        for ($i = 1; $i -lt $rows.Count; $i++) {
            foreach ($p in $first.PSObject.Properties) {
                if ($rows[$i].($p.Name) -ne $first.($p.Name)) { $identical = $false; break }
            }
            if (-not $identical) { break }
        }
        if ($identical) {
            $dupsExatas++
            $deduped += $rows[0]
        } else {
            $dupsDiferentes++
            # Manter aquisition_date mais recente
            $sorted = $rows | Sort-Object { $_.aquisition_date } -Descending
            $deduped += $sorted[0]
        }
    }
}
Write-Host "  Antes: $antes | Depois: $($deduped.Count)"
Write-Host "  Duplicatas exatas removidas: $dupsExatas"
Write-Host "  Duplicatas diferentes (mantida mais recente): $dupsDiferentes"

# Salvar base tratada
$deduped | Export-Csv (Join-Path $outputsDir "vivareal_base_tratada.csv") -NoTypeInformation -Encoding UTF8

# ============================================================
# 4-5. METRICAS POR BAIRRO x QUARTOS
# ============================================================
Write-Host "`n--- METRICAS POR BAIRRO x QUARTOS ---" -ForegroundColor Yellow

# Converter campos
$base = @()
foreach ($r in $deduped) {
    $sp = To-Double $r.sale_price
    $ua = To-Double $r.usable_area
    $cf = To-Double $r.monthly_condo_fee
    $ip = To-Double $r.yearly_iptu
    $br = if ($r.bedrooms -match '^\d+$') { [int]$r.bedrooms } else { $null }
    $ppm2 = if ($sp -and $ua -and $ua -gt 0) { [math]::Round($sp / $ua, 2) } else { $null }
    $base += [PSCustomObject]@{
        id = $r.listing_id; suburb = $r.suburb; br = $br
        sp = $sp; ua = $ua; cf = $cf; ip = $ip; ppm2 = $ppm2
        ba = $r.bathrooms; ps = $r.parking_spaces
        hasCf = if ($r.monthly_condo_fee -and $r.monthly_condo_fee -ne "" -and $r.monthly_condo_fee -ne "<NA>") { 1 } else { 0 }
        hasIp = if ($r.yearly_iptu -and $r.yearly_iptu -ne "" -and $r.yearly_iptu -ne "<NA>") { 1 } else { 0 }
        hasUa = if ($ua -and $ua -gt 0) { 1 } else { 0 }
        hasPpm2 = if ($ppm2) { 1 } else { 0 }
    }
}

# Bairros alvo
$bairrosAlvo = @("Centro", "Meia Praia", "Morretes", "Tabuleiro dos Oliveiras", "Canto da Praia")

# Grupo bairro x quartos
$grpResults = @()
foreach ($sb in $bairrosAlvo) {
    foreach ($brVal in @(0, 1, 2, 3, 4)) {
        $members = $base | Where-Object { $_.suburb -eq $sb -and $_.br -eq $brVal }
        if ($members.Count -gt 0) {
            $sps = $members | ForEach-Object { $_.sp } | Where-Object { $_ -ne $null } | Sort-Object
            $uas = $members | ForEach-Object { $_.ua } | Where-Object { $_ -ne $null -and $_ -gt 0 } | Sort-Object
            $ppm2s = $members | ForEach-Object { $_.ppm2 } | Where-Object { $_ -ne $null } | Sort-Object
            $cfs = $members | ForEach-Object { $_.cf } | Where-Object { $_ -ne $null -and $_ -ge 0 } | Sort-Object
            $ips = $members | ForEach-Object { $_.ip } | Where-Object { $_ -ne $null -and $_ -ge 0 } | Sort-Object
            $grpResults += [PSCustomObject]@{
                suburb = $sb; quartos = $brVal; qtd = $members.Count
                sp_mediana = Get-Median $sps; sp_media = if ($sps.Count -gt 0) { [math]::Round(($sps | Measure-Object -Average).Average, 2) } else { $null }
                sp_p25 = Get-Pct $sps 0.25; sp_p75 = Get-Pct $sps 0.75
                ua_mediana = Get-Median $uas
                ppm2_mediana = Get-Median $ppm2s
                cf_mediana = Get-Median $cfs; cf_pct = if ($members.Count -gt 0) { [math]::Round(($members | Where-Object { $_.hasCf -eq 1 }).Count / $members.Count * 100, 1) } else { 0 }
                ip_mediana = Get-Median $ips; ip_pct = if ($members.Count -gt 0) { [math]::Round(($members | Where-Object { $_.hasIp -eq 1 }).Count / $members.Count * 100, 1) } else { 0 }
                ua_zero = ($members | Where-Object { $_.ua -eq $null -or $_.ua -le 0 }).Count
                ppm2_invalido = ($members | Where-Object { $_.ppm2 -eq $null }).Count
            }
        }
    }
}

# Grupo 0-1q agregado
foreach ($sb in $bairrosAlvo) {
    $members = $base | Where-Object { $_.suburb -eq $sb -and $_.br -ge 0 -and $_.br -le 1 }
    if ($members.Count -gt 0) {
        $sps = $members | ForEach-Object { $_.sp } | Where-Object { $_ -ne $null } | Sort-Object
        $uas = $members | ForEach-Object { $_.ua } | Where-Object { $_ -ne $null -and $_ -gt 0 } | Sort-Object
        $ppm2s = $members | ForEach-Object { $_.ppm2 } | Where-Object { $_ -ne $null } | Sort-Object
        $cfs = $members | ForEach-Object { $_.cf } | Where-Object { $_ -ne $null -and $_ -ge 0 } | Sort-Object
        $ips = $members | ForEach-Object { $_.ip } | Where-Object { $_ -ne $null -and $_ -ge 0 } | Sort-Object
        $grpResults += [PSCustomObject]@{
            suburb = $sb; quartos = "0-1"; qtd = $members.Count
            sp_mediana = Get-Median $sps; sp_media = if ($sps.Count -gt 0) { [math]::Round(($sps | Measure-Object -Average).Average, 2) } else { $null }
            sp_p25 = Get-Pct $sps 0.25; sp_p75 = Get-Pct $sps 0.75
            ua_mediana = Get-Median $uas
            ppm2_mediana = Get-Median $ppm2s
            cf_mediana = Get-Median $cfs; cf_pct = [math]::Round(($members | Where-Object { $_.hasCf -eq 1 }).Count / $members.Count * 100, 1)
            ip_mediana = Get-Median $ips; ip_pct = [math]::Round(($members | Where-Object { $_.hasIp -eq 1 }).Count / $members.Count * 100, 1)
            ua_zero = ($members | Where-Object { $_.ua -eq $null -or $_.ua -le 0 }).Count
            ppm2_invalido = ($members | Where-Object { $_.ppm2 -eq $null }).Count
        }
    }
}

# Salvar
$grpResults | Export-Csv (Join-Path $outputsDir "vivareal_grupos_compra.csv") -NoTypeInformation -Encoding UTF8
Write-Host "  Salvo: outputs/vivareal_grupos_compra.csv"

# ============================================================
# 7. GRUPOS ESPECIFICOS
# ============================================================
Write-Host "`n--- GRUPOS ESPECIFICOS ---" -ForegroundColor Yellow
$specLabels = @(
    "Compactos 0-1q Centro", "Compactos 0-1q Meia Praia", "Compactos 0-1q Morretes"
    "2q Centro", "2q Meia Praia", "2q Morretes"
    "3q Centro", "3q Meia Praia", "3q Morretes"
    "4q Meia Praia"
)
$specDefs = @(
    @{sb="Centro"; brL=0; brH=1}, @{sb="Meia Praia"; brL=0; brH=1}, @{sb="Morretes"; brL=0; brH=1}
    @{sb="Centro"; brL=2; brH=2}, @{sb="Meia Praia"; brL=2; brH=2}, @{sb="Morretes"; brL=2; brH=2}
    @{sb="Centro"; brL=3; brH=3}, @{sb="Meia Praia"; brL=3; brH=3}, @{sb="Morretes"; brL=3; brH=3}
    @{sb="Meia Praia"; brL=4; brH=4}
)
$specTable = @()
for ($i = 0; $i -lt $specLabels.Count; $i++) {
    $def = $specDefs[$i]
    $members = $base | Where-Object { $_.suburb -eq $def.sb -and $_.br -ge $def.brL -and $_.br -le $def.brH }
    $sps = $members | ForEach-Object { $_.sp } | Where-Object { $_ -ne $null } | Sort-Object
    $uas = $members | ForEach-Object { $_.ua } | Where-Object { $_ -ne $null -and $_ -gt 0 } | Sort-Object
    $ppm2s = $members | ForEach-Object { $_.ppm2 } | Where-Object { $_ -ne $null } | Sort-Object
    $cfs = $members | ForEach-Object { $_.cf } | Where-Object { $_ -ne $null -and $_ -ge 0 } | Sort-Object
    $ips = $members | ForEach-Object { $_.ip } | Where-Object { $_ -ne $null -and $_ -ge 0 } | Sort-Object
    $specTable += [PSCustomObject]@{
        grupo = $specLabels[$i]; qtd = $members.Count
        sp_mediana = Get-Median $sps; sp_media = if ($sps.Count -gt 0) { [math]::Round(($sps | Measure-Object -Average).Average, 2) } else { $null }
        sp_p25 = Get-Pct $sps 0.25; sp_p75 = Get-Pct $sps 0.75
        ua_mediana = Get-Median $uas; ppm2_mediana = Get-Median $ppm2s
        cf_mediana = Get-Median $cfs; cf_pct = if ($members.Count -gt 0) { [math]::Round(($members | Where-Object { $_.hasCf -eq 1 }).Count / $members.Count * 100, 1) } else { 0 }
        ip_mediana = Get-Median $ips; ip_pct = if ($members.Count -gt 0) { [math]::Round(($members | Where-Object { $_.hasIp -eq 1 }).Count / $members.Count * 100, 1) } else { 0 }
        ua_zero = ($members | Where-Object { $_.ua -eq $null -or $_.ua -le 0 }).Count
        ppm2_invalido = ($members | Where-Object { $_.ppm2 -eq $null }).Count
    }
}
$specTable | Format-Table grupo, qtd, sp_mediana, ua_mediana, ppm2_mediana, cf_mediana, cf_pct, ip_mediana, ip_pct -AutoSize | Out-String | Write-Host

# ============================================================
# 8. EXTREMOS
# ============================================================
Write-Host "`n--- ANALISE DE EXTREMOS ---" -ForegroundColor Yellow
$allSP = $base | ForEach-Object { $_.sp } | Where-Object { $_ -ne $null } | Sort-Object
$allPPM2 = $base | ForEach-Object { $_.ppm2 } | Where-Object { $_ -ne $null } | Sort-Object
$spP1 = Get-Pct $allSP 0.01; $spP99 = Get-Pct $allSP 0.99
$pp2P1 = Get-Pct $allPPM2 0.01; $pp2P99 = Get-Pct $allPPM2 0.99
Write-Host ("  sale_price: P1={0} P99={1}" -f $spP1, $spP99)
Write-Host ("  price_per_m2: P1={0} P99={1}" -f $pp2P1, $pp2P99)

# Restringir
$filtered = $base | Where-Object { $_.sp -ge $spP1 -and $_.sp -le $spP99 -and $_.ppm2 -ge $pp2P1 -and $_.ppm2 -le $pp2P99 }
Write-Host ("  Registros validos (P1-P99): {0} de {1}" -f $filtered.Count, $base.Count)

# Recalcular para grupos especificos
$specTableF = @()
for ($i = 0; $i -lt $specLabels.Count; $i++) {
    $def = $specDefs[$i]
    $members = $filtered | Where-Object { $_.suburb -eq $def.sb -and $_.br -ge $def.brL -and $_.br -le $def.brH }
    $sps = $members | ForEach-Object { $_.sp } | Where-Object { $_ -ne $null } | Sort-Object
    $ppm2s = $members | ForEach-Object { $_.ppm2 } | Where-Object { $_ -ne $null } | Sort-Object
    $specTableF += [PSCustomObject]@{
        grupo = $specLabels[$i]; qtd = $members.Count
        sp_mediana = Get-Median $sps; ppm2_mediana = Get-Median $ppm2s
    }
}
Write-Host "`n  Comparacao (todos vs P1-P99):"
Write-Host ("  {0,-30} {1,10} {2,12} {3,10} {4,12}" -f "Grupo", "Qtd_orig", "SP_med_orig", "Qtd_flt", "SP_med_flt")
for ($i = 0; $i -lt $specLabels.Count; $i++) {
    Write-Host ("  {0,-30} {1,10} {2,12} {3,10} {4,12}" -f $specLabels[$i], $specTable[$i].qtd, $specTable[$i].sp_mediana, $specTableF[$i].qtd, $specTableF[$i].sp_mediana)
}

Write-Host "`n=== FIM ===" -ForegroundColor Cyan
