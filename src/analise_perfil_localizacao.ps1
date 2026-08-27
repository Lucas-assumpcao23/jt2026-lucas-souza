# Análise de Perfil e Localização — Airbnb
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$outputsDir = Join-Path $baseDir "outputs"
$analysisDir = Join-Path $baseDir "analysis"

Write-Host "=== ANALISE PERFIL E LOCALIZACAO ===" -ForegroundColor Cyan
$raw = Import-Csv (Join-Path $outputsDir "base_airbnb_consolidada.csv") -Encoding UTF8
Write-Host "  Total raw: $($raw.Count)"

# Converter campos numericos
function To-Double($v) { if ($v -and $v -match '^\d+[\.,]?\d*$') { [double]($v -replace ',','.') } else { $null } }
function Get-Pct($arr, $p) { $s = $arr | Sort-Object; $s[[math]::Floor($s.Count * $p)] }
function Get-Median($arr) { $s = $arr | Sort-Object; $s[[math]::Floor($s.Count / 2)] }

$all = @()
foreach ($r in $raw) {
    $dm = To-Double $r.diaria_mediana
    $ds = if ($r.datas_estadia -match '^\d+$') { [int]$r.datas_estadia } else { 0 }
    $br = if ($r.number_of_bedrooms -match '^\d+$') { [int]$r.number_of_bedrooms } else { $null }
    $bg = if ($r.number_of_guests -match '^\d+$') { [int]$r.number_of_guests } else { $null }
    $all += [PSCustomObject]@{
        id = $r.airbnb_listing_id; suburb = $r.suburb; lt = $r.listing_type
        br = $br; baths = $r.number_of_bathrooms; beds = $r.number_of_beds
        guests = $bg; reviews = $r.number_of_reviews; stars = $r.star_rating
        prof = $r.is_professional; ib = $r.can_instant_book; fav = $r.is_guest_favorite
        cf = $r.cleaning_fee; mn = $r.min_nights
        datas = $ds; dm = $dm; d25 = To-Double $r.diaria_p25; d75 = To-Double $r.diaria_p75
        pba = To-Double $r.potencial_bruto_anunciado
    }
}

# Amostra principal
$main = $all | Where-Object { $_.datas -ge 30 -and $_.dm -ge 150 -and $_.dm -le 2500 }
Write-Host "  Amostra principal: $($main.Count)"

# ============================================================
# 1. TABELA POR BAIRRO
# ============================================================
Write-Host "`n--- POR BAIRRO ---" -ForegroundColor Yellow
$grpB = $main | Group-Object suburb
$bairroTable = @()
foreach ($g in ($grpB | Sort-Object Count -Descending)) {
    $dms = $g.Group | ForEach-Object { $_.dm } | Where-Object { $_ -ne $null }
    $brs = $g.Group | ForEach-Object { $_.br } | Where-Object { $_ -ne $null }
    $gsts = $g.Group | ForEach-Object { $_.guests } | Where-Object { $_ -ne $null }
    $dts = $g.Group | ForEach-Object { $_.datas }
    $bairroTable += [PSCustomObject]@{
        suburb = $g.Name; qtd = $g.Count
        dm_mediana = Get-Median $dms; dm_media = [math]::Round(($dms | Measure-Object -Average).Average, 2)
        dm_p25 = Get-Pct $dms 0.25; dm_p75 = Get-Pct $dms 0.75
        br_mediana = Get-Median $brs; g_mediana = Get-Median $gsts; dts_mediana = Get-Median $dts
    }
}
$bairroTable | Export-Csv (Join-Path $outputsDir "airbnb_por_bairro.csv") -NoTypeInformation -Encoding UTF8
$bairroTable | Format-Table suburb, qtd, dm_mediana, dm_media, dm_p25, dm_p75, br_mediana, g_mediana, dts_mediana -AutoSize | Out-String | Write-Host

# ============================================================
# 3. TABELA POR QUARTOS
# ============================================================
Write-Host "`n--- POR QUARTOS ---" -ForegroundColor Yellow
$grpQ = $main | Where-Object { $_.br -ne $null } | Group-Object br
$qTable = @()
foreach ($g in ($grpQ | Sort-Object { [int]$_.Name })) {
    $dms = $g.Group | ForEach-Object { $_.dm } | Where-Object { $_ -ne $null }
    $gsts = $g.Group | ForEach-Object { $_.guests } | Where-Object { $_ -ne $null }
    $ltDist = $g.Group | Group-Object lt | Sort-Object Count -Descending | ForEach-Object { "$($_.Name)=$($_.Count)" }
    $qTable += [PSCustomObject]@{
        quartos = $g.Name; qtd = $g.Count
        dm_mediana = Get-Median $dms; dm_media = [math]::Round(($dms | Measure-Object -Average).Average, 2)
        dm_p25 = Get-Pct $dms 0.25; dm_p75 = Get-Pct $dms 0.75
        g_mediana = Get-Median $gsts; lt_dist = ($ltDist -join "; ")
    }
}
$qTable | Export-Csv (Join-Path $outputsDir "airbnb_por_quartos.csv") -NoTypeInformation -Encoding UTF8
$qTable | Format-Table quartos, qtd, dm_mediana, dm_media, dm_p25, dm_p75, g_mediana -AutoSize | Out-String | Write-Host
$qTable | ForEach-Object { Write-Host ("  {0} qtd: {1}" -f $_.quartos, $_.lt_dist) }

# ============================================================
# 4. TABELA POR LISTING_TYPE
# ============================================================
Write-Host "`n--- POR LISTING_TYPE ---" -ForegroundColor Yellow
$grpT = $main | Group-Object lt
$tTable = @()
foreach ($g in ($grpT | Sort-Object Count -Descending)) {
    $dms = $g.Group | ForEach-Object { $_.dm } | Where-Object { $_ -ne $null }
    $brs = $g.Group | ForEach-Object { $_.br } | Where-Object { $_ -ne $null }
    $gsts = $g.Group | ForEach-Object { $_.guests } | Where-Object { $_ -ne $null }
    $tTable += [PSCustomObject]@{
        listing_type = $g.Name; qtd = $g.Count
        dm_mediana = Get-Median $dms; dm_media = [math]::Round(($dms | Measure-Object -Average).Average, 2)
        dm_p25 = Get-Pct $dms 0.25; dm_p75 = Get-Pct $dms 0.75
        br_mediana = Get-Median $brs; g_mediana = Get-Median $gsts
    }
}
$tTable | Export-Csv (Join-Path $outputsDir "airbnb_por_tipo.csv") -NoTypeInformation -Encoding UTF8
$tTable | Format-Table listing_type, qtd, dm_mediana, dm_media, dm_p25, dm_p75, br_mediana, g_mediana -AutoSize | Out-String | Write-Host

# ============================================================
# 5. TABELA COMBINADA (suburb+tipo+quartos)
# ============================================================
Write-Host "`n--- GRUPOS COMBINADOS (>=10) ---" -ForegroundColor Yellow
$grpC = $main | Where-Object { $_.br -ne $null } | Group-Object suburb, lt, br
$combTable = @()
foreach ($g in ($grpC | Where-Object { $_.Count -ge 10 } | Sort-Object Count -Descending)) {
    $dms = $g.Group | ForEach-Object { $_.dm } | Where-Object { $_ -ne $null }
    $gsts = $g.Group | ForEach-Object { $_.guests } | Where-Object { $_ -ne $null }
    $parts = $g.Name -split ', '
    $combTable += [PSCustomObject]@{
        suburb = $parts[0]; listing_type = $parts[1]; quartos = $parts[2]
        qtd = $g.Count; dm_mediana = Get-Median $dms
        dm_media = [math]::Round(($dms | Measure-Object -Average).Average, 2)
        dm_p25 = Get-Pct $dms 0.25; dm_p75 = Get-Pct $dms 0.75
        g_mediana = Get-Median $gsts
    }
}
$combTable | Export-Csv (Join-Path $outputsDir "airbnb_grupos_comparaveis.csv") -NoTypeInformation -Encoding UTF8
$combTable | Format-Table suburb, listing_type, quartos, qtd, dm_mediana, dm_media, dm_p25, dm_p75, g_mediana -AutoSize | Out-String | Write-Host

# ============================================================
# 6. GRUPOS ESPECIFICOS
# ============================================================
Write-Host "`n--- GRUPOS ESPECIFICOS ---" -ForegroundColor Yellow
$specGroups = @(
    @{ label="Apt 0-1q Centro"; filt={$_.lt -eq "apartamento" -and $_.br -le 1 -and $_.br -ge 0 -and $_.suburb -eq "Centro"} }
    @{ label="Apt 0-1q Fora Centro"; filt={$_.lt -eq "apartamento" -and $_.br -le 1 -and $_.br -ge 0 -and $_.suburb -ne "Centro"} }
    @{ label="Apt 2q Centro"; filt={$_.lt -eq "apartamento" -and $_.br -eq 2 -and $_.suburb -eq "Centro"} }
    @{ label="Apt 2q Meia Praia"; filt={$_.lt -eq "apartamento" -and $_.br -eq 2 -and $_.suburb -eq "Meia Praia"} }
    @{ label="Apt 2q Morretes"; filt={$_.lt -eq "apartamento" -and $_.br -eq 2 -and $_.suburb -eq "Morretes"} }
    @{ label="Apt 3q Centro"; filt={$_.lt -eq "apartamento" -and $_.br -eq 3 -and $_.suburb -eq "Centro"} }
    @{ label="Apt 3q Meia Praia"; filt={$_.lt -eq "apartamento" -and $_.br -eq 3 -and $_.suburb -eq "Meia Praia"} }
    @{ label="Apt 3q Morretes"; filt={$_.lt -eq "apartamento" -and $_.br -eq 3 -and $_.suburb -eq "Morretes"} }
)
$specTable = @()
foreach ($sg in $specGroups) {
    $members = $main | Where-Object $sg.filt
    if ($members.Count -gt 0) {
        $dms = $members | ForEach-Object { $_.dm } | Where-Object { $_ -ne $null }
        $gsts = $members | ForEach-Object { $_.guests } | Where-Object { $_ -ne $null }
        $dts = $members | ForEach-Object { $_.datas }
        $specTable += [PSCustomObject]@{
            grupo = $sg.label; qtd = $members.Count
            dm_mediana = Get-Median $dms; dm_media = [math]::Round(($dms | Measure-Object -Average).Average, 2)
            dm_p25 = Get-Pct $dms 0.25; dm_p75 = Get-Pct $dms 0.75
            g_mediana = Get-Median $gsts; dts_mediana = Get-Median $dts
        }
    } else {
        $specTable += [PSCustomObject]@{
            grupo = $sg.label; qtd = 0; dm_mediana = "N/A"; dm_media = "N/A"
            dm_p25 = "N/A"; dm_p75 = "N/A"; g_mediana = "N/A"; dts_mediana = "N/A"
        }
    }
}
$specTable | Format-Table grupo, qtd, dm_mediana, dm_media, dm_p25, dm_p75, g_mediana, dts_mediana -AutoSize | Out-String | Write-Host

# ============================================================
# 7. DIARIA POR HOSPEDE
# ============================================================
Write-Host "`n--- DIARIA POR HOSPEDE ---" -ForegroundColor Yellow
$mainValidGuests = $main | Where-Object { $_.guests -and $_.guests -gt 0 }
$mainDpG = @()
foreach ($m in $mainValidGuests) {
    $ratio = [math]::Round($m.dm / $m.guests, 2)
    $mainDpG += [PSCustomObject]@{ id=$m.id; suburb=$m.suburb; lt=$m.lt; br=$m.br; guests=$m.guests; dm=$m.dm; dm_por_g=$ratio }
}

# Por grupo especifico
$dpgSpec = @()
foreach ($sg in $specGroups) {
    $members = $mainDpG | Where-Object { & $sg.filt }
    if ($members.Count -gt 0) {
        $ratios = $members | ForEach-Object { $_.dm_por_g } | Sort-Object
        $dpgSpec += [PSCustomObject]@{
            grupo = $sg.label; qtd = $members.Count
            dm_por_g_mediana = Get-Median $ratios
            dm_por_g_media = [math]::Round(($ratios | Measure-Object -Average).Average, 2)
        }
    }
}
Write-Host "  Amostra valida (guests>0): $($mainValidGuests.Count)"
$dpgSpec | Format-Table grupo, qtd, dm_por_g_mediana, dm_por_g_media -AutoSize | Out-String | Write-Host

# Por bairro
$grpBairoDpg = $mainDpG | Group-Object suburb
$bairDpg = @()
foreach ($g in ($grpBairoDpg | Sort-Object Count -Descending)) {
    $ratios = $g.Group | ForEach-Object { $_.dm_por_g } | Sort-Object
    $bairDpg += [PSCustomObject]@{
        suburb = $g.Name; qtd = $g.Count
        dm_por_g_mediana = Get-Median $ratios
        dm_por_g_media = [math]::Round(($ratios | Measure-Object -Average).Average, 2)
    }
}
$bairDpg | Format-Table suburb, qtd, dm_por_g_mediana, dm_por_g_media -AutoSize | Out-String | Write-Host

# ============================================================
# 8. SENSIBILIDADE
# ============================================================
Write-Host "`n--- SENSIBILIDADE ---" -ForegroundColor Yellow
# Todos os 999
$allValid = $all | Where-Object { $_.dm -ge 150 -and $_.dm -le 2500 -and $_.guests -gt 0 }
Write-Host "  Todos (150-2500, guests>0): $($allValid.Count)"

# ranking principal bairros (amostra main,>=30)
$rankMain = $bairroTable | Where-Object { $_.qtd -ge 30 } | Sort-Object dm_mediana -Descending | Select-Object -First 3
Write-Host "  Top 3 bairros (main,>=30):"
$rankMain | ForEach-Object { Write-Host ("    {0}: med={1} qtd={2}" -f $_.suburb, $_.dm_mediana, $_.qtd) }

# ranking todos
$grpBall = $all | Where-Object { $_.dm -ge 150 -and $_.dm -le 2500 } | Group-Object suburb
$ballTable = @()
foreach ($g in ($grpBall | Where-Object { $_.Count -ge 30 })) {
    $dms = $g.Group | ForEach-Object { $_.dm } | Where-Object { $_ -ne $null }
    $ballTable += [PSCustomObject]@{ suburb=$g.Name; qtd=$g.Count; dm_mediana=Get-Median $dms }
}
$rankAll = $ballTable | Sort-Object dm_mediana -Descending | Select-Object -First 3
Write-Host "  Top 3 bairros (all 999,>=30,150-2500):"
$rankAll | ForEach-Object { Write-Host ("    {0}: med={1} qtd={2}" -f $_.suburb, $_.dm_mediana, $_.qtd) }

# ranking grupos combinados main
$rankCombMain = $combTable | Sort-Object dm_mediana -Descending | Select-Object -First 5
Write-Host "  Top 5 grupos combinados (main):"
$rankCombMain | ForEach-Object { Write-Host ("    {0} {1}q {2}: med={3} qtd={4}" -f $_.suburb, $_.quartos, $_.listing_type, $_.dm_mediana, $_.qtd) }

# ranking grupos combinados all
$grpCall = $all | Where-Object { $_.dm -ge 150 -and $_.dm -le 2500 -and $_.br -ne $null } | Group-Object suburb, lt, br
$callTable = @()
foreach ($g in ($grpCall | Where-Object { $_.Count -ge 10 })) {
    $dms = $g.Group | ForEach-Object { $_.dm } | Where-Object { $_ -ne $null }
    $parts = $g.Name -split ', '
    $callTable += [PSCustomObject]@{ suburb=$parts[0]; lt=$parts[1]; br=$parts[2]; qtd=$g.Count; dm_mediana=Get-Median $dms }
}
$rankCombAll = $callTable | Sort-Object dm_mediana -Descending | Select-Object -First 5
Write-Host "  Top 5 grupos combinados (all 999):"
$rankCombAll | ForEach-Object { Write-Host ("    {0} {1}q {2}: med={3} qtd={4}" -f $_.suburb, $_.br, $_.lt, $_.dm_mediana, $_.qtd) }

Write-Host "`n=== FIM ===" -ForegroundColor Cyan
