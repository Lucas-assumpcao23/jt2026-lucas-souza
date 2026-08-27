# ============================================================
# AUDITORIA CORRETIVA — Dados Itapema
# Segunda passagem com valores exatos e correções documentadas
# ============================================================
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$dataDir = Join-Path $baseDir "data"
$outputsDir = Join-Path $baseDir "outputs"
$analysisDir = Join-Path $baseDir "analysis"
if (-not (Test-Path $outputsDir)) { New-Item -ItemType Directory -Path $outputsDir -Force | Out-Null }
if (-not (Test-Path $analysisDir)) { New-Item -ItemType Directory -Path $analysisDir -Force | Out-Null }

$R = [ordered]@{}
function Set-R([string]$k,$v){ $script:R[$k]=$v }

Write-Host "=== AUDITORIA CORRETIVA ===" -ForegroundColor Cyan

# ============================================================
# CARREGAR BASES
# ============================================================
Write-Host "Carregando bases..." -ForegroundColor Yellow
$det = Import-Csv (Join-Path $dataDir "Details_Itapema.csv") -Encoding UTF8
$hst = Import-Csv (Join-Path $dataDir "Hosts_ids_Itapema.csv") -Encoding UTF8
$msh = Import-Csv (Join-Path $dataDir "Mesh_Ids_Data_Itapema.csv") -Encoding UTF8
$prc = Import-Csv (Join-Path $dataDir "Price_AV_Itapema.csv") -Encoding UTF8
$viv = Import-Csv (Join-Path $dataDir "VivaReal_Itapema.csv") -Encoding UTF8
Write-Host "  Details: $($det.Count) linhas"
Write-Host "  Hosts:   $($hst.Count) linhas"
Write-Host "  Mesh:    $($msh.Count) linhas"
Write-Host "  Price:   $($prc.Count) linhas"
Write-Host "  Viva:    $($viv.Count) linhas"

# ============================================================
# 1. DETAILS — contagens exatas
# ============================================================
Write-Host "`n--- DETAILS ---" -ForegroundColor Yellow
Set-R "det_linhas" $det.Count
Set-R "det_colunas" $det[0].PSObject.Properties.Name.Count
Set-R "det_colunas_nomes" ($det[0].PSObject.Properties.Name -join "|")

$detIds = $det | ForEach-Object { $_.airbnb_listing_id }
$detUniq = $detIds | Sort-Object -Unique
Set-R "det_ids_total" $detIds.Count
Set-R "det_ids_unicos" $detUniq.Count
$detDups = $detIds | Group-Object | Where-Object { $_.Count -gt 1 }
Set-R "det_ids_duplicados" $(if($detDups){$detDups.Count}else{0})

# listing_type exato
$detLT = $det | Group-Object listing_type | Sort-Object Count -Descending
$detLTStr = ($detLT | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join ", "
Set-R "det_listing_type" $detLTStr

# Ausentes exatos
$detAusentes = @()
foreach ($p in $det[0].PSObject.Properties) {
    $n = $p.Name
    $empty = ($det | Where-Object { $_.$n -eq "" -or $_.$n -eq "<NA>" }).Count
    if ($empty -gt 0) {
        $pct = [math]::Round(($empty / $det.Count)*100, 2)
        $detAusentes += [PSCustomObject]@{ Coluna=$n; Ausentes=$empty; Pct=$pct }
    }
}
$detAusentes | Sort-Object Ausentes -Descending | Export-Csv (Join-Path $outputsDir "details_ausentes.csv") -NoTypeInformation -Encoding UTF8
Set-R "det_ausentes_arquivo" "outputs/details_ausentes.csv"

Write-Host "  IDs: $($detIds.Count) total, $($detUniq.Count) unicos, duplicados=$(if($detDups){$detDups.Count}else{0})"
Write-Host "  listing_type: $detLTStr"

# ============================================================
# 2-5. HOSTS — ausentes exatos + duplicidades
# ============================================================
Write-Host "`n--- HOSTS ---" -ForegroundColor Yellow
Set-R "hst_linhas" $hst.Count
Set-R "hst_colunas" $hst[0].PSObject.Properties.Name.Count
Set-R "hst_colunas_nomes" ($hst[0].PSObject.Properties.Name -join "|")

# Ausentes exatos
$hstAusentes = @()
foreach ($p in $hst[0].PSObject.Properties) {
    $n = $p.Name
    $empty = ($hst | Where-Object { $_.$n -eq "" -or $_.$n -eq "<NA>" }).Count
    if ($empty -gt 0) {
        $pct = [math]::Round(($empty / $hst.Count)*100, 2)
        $hstAusentes += [PSCustomObject]@{ Coluna=$n; Ausentes=$empty; Pct=$pct }
    }
}
$hstAusentes | Sort-Object Ausentes -Descending | Export-Csv (Join-Path $outputsDir "hosts_ausentes.csv") -NoTypeInformation -Encoding UTF8
Write-Host "  Ausentes:"
$hstAusentes | Sort-Object Ausentes -Descending | ForEach-Object { Write-Host ("    {0}: {1} ({2}%)" -f $_.Coluna, $_.Ausentes, $_.Pct) }

#owner_id
$hIds = $hst | ForEach-Object { $_.owner_id }
$hUniq = $hIds | Sort-Object -Unique
Set-R "hst_owner_total" $hIds.Count
Set-R "hst_owner_unicos" $hUniq.Count
$hDups = $hIds | Group-Object | Where-Object { $_.Count -gt 1 }
Set-R "hst_owner_duplicados" $(if($hDups){$hDups.Count}else{0})
Write-Host "  owner_id: $($hIds.Count) total, $($hUniq.Count) unicos, duplicados=$(if($hDups){$hDups.Count}else{0})"

# 6-8. Analise de duplicidades de owner_id
Write-Host "`n--- HOSTS: Analise de duplicidades ---" -ForegroundColor Yellow
$dupOwners = @()
if ($hDups) {
    foreach ($d in $hDups) {
        $rows = $hst | Where-Object { $_.owner_id -eq $d.Name }
        $allSame = $true
        $first = $rows[0]
        for ($i = 1; $i -lt $rows.Count; $i++) {
            foreach ($p in $first.PSObject.Properties) {
                if ($rows[$i].($p.Name) -ne $first.($p.Name)) { $allSame = $false; break }
            }
            if (-not $allSame) { break }
        }
        $snapDates = $rows | ForEach-Object { $_.host_snapshot_date } | Sort-Object -Unique
        $dupOwners += [PSCustomObject]@{
            owner_id = $d.Name
            qtd_linhas = $d.Count
            linhas_identical = $allSame
            snapshot_dates = ($snapDates -join "; ")
        }
    }
}
$dupOwners | Export-Csv (Join-Path $outputsDir "hosts_duplicidades.csv") -NoTypeInformation -Encoding UTF8
$identicalCount = ($dupOwners | Where-Object { $_.linhas_identical -eq $true }).Count
$diffCount = ($dupOwners | Where-Object { $_.linhas_identical -eq $false }).Count
Write-Host "  Owners duplicados: $($dupOwners.Count)"
Write-Host "  Linhas identicas: $identicalCount"
Write-Host "  Linhas diferentes: $diffCount"
Set-R "hst_dups_identical" $identicalCount
Set-R "hst_dups_different" $diffCount

# Regra para deduplicacao
$rule = "Se linhas identicas: manter 1. Se diferentes: manter a mais recente (host_snapshot_date max)"
Set-R "hst_regra_dedup" $rule
Write-Host "  Regra proposta: $rule"

# ============================================================
# 11-16. PRICE_AV — duplicidades e consolidacao
# ============================================================
Write-Host "`n--- PRICE_AV ---" -ForegroundColor Yellow
Set-R "prc_linhas" $prc.Count
Set-R "prc_colunas" $prc[0].PSObject.Properties.Name.Count

# Extrair dia de aquisition_date
$prcEnriched = $prc | ForEach-Object {
    $aq = $_.aquisition_date
    $day = if ($aq -and $aq.Length -ge 10) { $aq.Substring(0,10) } else { "" }
    [PSCustomObject]@{
        airbnb_listing_id = $_.airbnb_listing_id
        date = $_.date
        price = $_.price
        aquisition_date = $aq
        aquisition_day = $day
    }
}

# 11a. Duplicidades por listing_id + date
$keys_ld = $prcEnriched | ForEach-Object { "$($_.airbnb_listing_id)|$($_.date)" }
$uniq_ld = $keys_ld | Sort-Object -Unique
$dup_ld = $keys_ld | Group-Object | Where-Object { $_.Count -gt 1 }
Set-R "prc_keys_linha_date_total" $keys_ld.Count
Set-R "prc_keys_linha_date_unicos" $uniq_ld.Count
Set-R "prc_keys_linha_date_dups" $(if($dup_ld){$dup_ld.Count}else{0})
Write-Host "  listing_id+date: $($keys_ld.Count) total, $($uniq_ld.Count) unicos, dups=$(if($dup_ld){$dup_ld.Count}else{0})"

# 11b. Duplicidades por listing_id + date + aquisition_day
$keys_lda = $prcEnriched | ForEach-Object { "$($_.airbnb_listing_id)|$($_.date)|$($_.aquisition_day)" }
$uniq_lda = $keys_lda | Sort-Object -Unique
$dup_lda = $keys_lda | Group-Object | Where-Object { $_.Count -gt 1 }
Set-R "prc_keys_lda_total" $keys_lda.Count
Set-R "prc_keys_lda_unicos" $uniq_lda.Count
Set-R "prc_keys_lda_dups" $(if($dup_lda){$dup_lda.Count}else{0})
Write-Host "  listing_id+date+dia_captura: $($keys_lda.Count) total, $($uniq_lda.Count) unicos, dups=$(if($dup_lda){$dup_lda.Count}else{0})"

# 12. Rodadas reais de captura (dias unicos)
$capDays = $prcEnriched | ForEach-Object { $_.aquisition_day } | Sort-Object -Unique
$capDays = $capDays | Where-Object { $_ -ne "" }
Set-R "prc_captura_dias_unicos" $capDays.Count
Set-R "prc_captura_periodo" "$($capDays[0]) a $($capDays[$capDays.Count-1])"
Write-Host "  Rodadas de captura (dias): $($capDays.Count) — $($capDays[0]) a $($capDays[$capDays.Count-1])"

# 13. Precos distintos por listing_id + date
$priceVariation = @()
$grouped = $prcEnriched | Group-Object airbnb_listing_id, date
$withVariation = 0
$noVariation = 0
foreach ($g in $grouped) {
    $prices = $g.Group | ForEach-Object {
        $p = $_.price
        if ($p -match '^\d+\.?\d*$') { [double]$p } else { $null }
    } | Where-Object { $_ -ne $null }
    $distinct = $prices | Sort-Object -Unique
    if ($distinct.Count -gt 1) { $withVariation++ } else { $noVariation++ }
}
Set-R "prc_variacao_sim" $withVariation
Set-R "prc_variacao_nao" $noVariation
$varPct = [math]::Round(($withVariation / $uniq_ld.Count)*100, 2)
$noVarPct = [math]::Round(($noVariation / $uniq_ld.Count)*100, 2)
Set-R "prc_variacao_pct" $varPct
$pctLabel = [char]37
$s1 = "  Com variacao de preco entre capturas: " + $withVariation + " (" + $varPct + $pctLabel + ")"
$s2 = "  Sem variacao: " + $noVariation + " (" + $noVarPct + $pctLabel + ")"
Write-Host $s1
Write-Host $s2

# 14. Frequencia de mudanca — por listing, quantas vezes o preco mudou
$changeFreq = @()
foreach ($g in $grouped) {
    $parts = $g.Group[0]
    $lid = $parts.airbnb_listing_id
    $dt = $parts.date
    $captures = $g.Group | Sort-Object aquisition_day
    $priceSeq = @()
    foreach ($c in $captures) {
        $p = $c.price
        if ($p -match '^\d+\.?\d*$') { $priceSeq += [double]$p }
    }
    if ($priceSeq.Count -gt 1) {
        $changes = 0
        for ($i = 1; $i -lt $priceSeq.Count; $i++) {
            if ($priceSeq[$i] -ne $priceSeq[$i-1]) { $changes++ }
        }
        $changeFreq += [PSCustomObject]@{
            airbnb_listing_id = $lid
            date = $dt
            capturas = $priceSeq.Count
            mudancas = $changes
        }
    }
}
$changeFreq | Export-Csv (Join-Path $outputsDir "price_freq_mudancas.csv") -NoTypeInformation -Encoding UTF8
$avgChanges = if ($changeFreq.Count -gt 0) { [math]::Round(($changeFreq | Measure-Object mudancas -Average).Average, 3) } else { 0 }
$maxChanges = if ($changeFreq.Count -gt 0) { ($changeFreq | Measure-Object mudancas -Maximum).Maximum } else { 0 }
Set-R "prc_freq_media_mudancas" $avgChanges
Set-R "prc_freq_max_mudancas" $maxChanges
Write-Host "  Media de mudancas por listing+data: $avgChanges"
Write-Host "  Maximo de mudancas: $maxChanges"

# 15. Regra de consolidacao
$consolidationRule = "Para cada (listing_id, date): selecionar a captura mais recente (aquisition_day max)"
Set-R "prc_regra_consolidacao" $consolidationRule
Write-Host "  Regra proposta: $consolidationRule"

# ============================================================
# 17-20. REPRESENTATIVIDADE
# ============================================================
Write-Host "`n--- REPRESENTATIVIDADE ---" -ForegroundColor Yellow

# 17. Flag de preco
$detPriceIds = $prcEnriched | ForEach-Object { $_.airbnb_listing_id } | Sort-Object -Unique
$detEnriched = $det | ForEach-Object {
    $hasPrice = if ($_.airbnb_listing_id -in $detPriceIds) { "sim" } else { "nao" }
    [PSCustomObject]@{
        airbnb_listing_id = $_.airbnb_listing_id
        has_price = $hasPrice
        suburb = ""
        number_of_bedrooms = $_.number_of_bedrooms
        listing_type = $_.listing_type
        number_of_guests = $_.number_of_guests
        number_of_reviews = $_.number_of_reviews
        star_rating = $_.star_rating
        is_professional = $_.is_professional
    }
}

# Preencher suburb via Mesh
foreach ($d in $detEnriched) {
    $m = $msh | Where-Object { $_.airbnb_listing_id -eq $d.airbnb_listing_id } | Select-Object -First 1
    if ($m) { $d.suburb = $m.suburb }
}

# 18. Comparacao dos grupos
$withPrice = $detEnriched | Where-Object { $_.has_price -eq "sim" }
$noPrice = $detEnriched | Where-Object { $_.has_price -eq "nao" }
Write-Host "  Com preco: $($withPrice.Count)"
Write-Host "  Sem preco: $($noPrice.Count)"

$compResults = @()

# suburb
$wpSuburb = $withPrice | Group-Object suburb | Sort-Object Count -Descending | Select-Object -First 5
$npSuburb = $noPrice | Group-Object suburb | Sort-Object Count -Descending | Select-Object -First 5
$compResults += [PSCustomObject]@{
    Variavel = "suburb"
    Grupo = "com_preco_top5"
    Valor = ($wpSuburb | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; "
}
$compResults += [PSCustomObject]@{
    Variavel = "suburb"
    Grupo = "sem_preco_top5"
    Valor = ($npSuburb | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; "
}

# number_of_bedrooms
$wpBeds = $withPrice | ForEach-Object { if ($_.number_of_bedrooms -match '^\d+$') { [int]$_.number_of_bedrooms } } | Where-Object { $_ -ne $null }
$npBeds = $noPrice | ForEach-Object { if ($_.number_of_bedrooms -match '^\d+$') { [int]$_.number_of_bedrooms } } | Where-Object { $_ -ne $null }
$wpBedsSorted = $wpBeds | Sort-Object
$npBedsSorted = $npBeds | Sort-Object
$wpMedBeds = if ($wpBedsSorted.Count -gt 0) { $wpBedsSorted[[math]::Floor($wpBedsSorted.Count/2)] } else { "N/A" }
$npMedBeds = if ($npBedsSorted.Count -gt 0) { $npBedsSorted[[math]::Floor($npBedsSorted.Count/2)] } else { "N/A" }
$compResults += [PSCustomObject]@{ Variavel="number_of_bedrooms"; Grupo="com_preco"; Valor="mediana=$wpMedBeds n=$($wpBeds.Count)" }
$compResults += [PSCustomObject]@{ Variavel="number_of_bedrooms"; Grupo="sem_preco"; Valor="mediana=$npMedBeds n=$($npBeds.Count)" }

# listing_type
$wpLT = $withPrice | Group-Object listing_type | Sort-Object Count -Descending
$npLT = $noPrice | Group-Object listing_type | Sort-Object Count -Descending
$compResults += [PSCustomObject]@{ Variavel="listing_type"; Grupo="com_preco"; Valor=($wpLT | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }
$compResults += [PSCustomObject]@{ Variavel="listing_type"; Grupo="sem_preco"; Valor=($npLT | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }

# number_of_guests
$wpG = $withPrice | ForEach-Object { if ($_.number_of_guests -match '^\d+$') { [int]$_.number_of_guests } } | Where-Object { $_ -ne $null }
$npG = $noPrice | ForEach-Object { if ($_.number_of_guests -match '^\d+$') { [int]$_.number_of_guests } } | Where-Object { $_ -ne $null }
$wpGS = $wpG | Sort-Object; $npGS = $npG | Sort-Object
$wpMedG = if ($wpGS.Count -gt 0) { $wpGS[[math]::Floor($wpGS.Count/2)] } else { "N/A" }
$npMedG = if ($npGS.Count -gt 0) { $npGS[[math]::Floor($npGS.Count/2)] } else { "N/A" }
$compResults += [PSCustomObject]@{ Variavel="number_of_guests"; Grupo="com_preco"; Valor="mediana=$wpMedG n=$($wpG.Count)" }
$compResults += [PSCustomObject]@{ Variavel="number_of_guests"; Grupo="sem_preco"; Valor="mediana=$npMedG n=$($npG.Count)" }

# number_of_reviews
$wpR = $withPrice | ForEach-Object { if ($_.number_of_reviews -match '^\d+$') { [int]$_.number_of_reviews } } | Where-Object { $_ -ne $null }
$npR = $noPrice | ForEach-Object { if ($_.number_of_reviews -match '^\d+$') { [int]$_.number_of_reviews } } | Where-Object { $_ -ne $null }
$wpRS = $wpR | Sort-Object; $npRS = $npR | Sort-Object
$wpMedR = if ($wpRS.Count -gt 0) { $wpRS[[math]::Floor($wpRS.Count/2)] } else { "N/A" }
$npMedR = if ($npRS.Count -gt 0) { $npRS[[math]::Floor($npRS.Count/2)] } else { "N/A" }
$compResults += [PSCustomObject]@{ Variavel="number_of_reviews"; Grupo="com_preco"; Valor="mediana=$wpMedR media=$([math]::Round(($wpR | Measure-Object -Average).Average,2))" }
$compResults += [PSCustomObject]@{ Variavel="number_of_reviews"; Grupo="sem_preco"; Valor="mediana=$npMedR media=$([math]::Round(($npR | Measure-Object -Average).Average,2))" }

# star_rating
$wpS = $withPrice | ForEach-Object { if ($_.star_rating -match '^\d+\.?\d*$') { [double]$_.star_rating } } | Where-Object { $_ -ne $null }
$npS = $noPrice | ForEach-Object { if ($_.star_rating -match '^\d+\.?\d*$') { [double]$_.star_rating } } | Where-Object { $_ -ne $null }
$wpSS = $wpS | Sort-Object; $npSS = $npS | Sort-Object
$wpMedS = if ($wpSS.Count -gt 0) { $wpSS[[math]::Floor($wpSS.Count/2)] } else { "N/A" }
$npMedS = if ($npSS.Count -gt 0) { $npSS[[math]::Floor($npSS.Count/2)] } else { "N/A" }
$compResults += [PSCustomObject]@{ Variavel="star_rating"; Grupo="com_preco"; Valor="mediana=$wpMedS media=$([math]::Round(($wpS | Measure-Object -Average).Average,2)) n=$($wpS.Count)" }
$compResults += [PSCustomObject]@{ Variavel="star_rating"; Grupo="sem_preco"; Valor="mediana=$npMedS media=$([math]::Round(($npS | Measure-Object -Average).Average,2)) n=$($npS.Count)" }

# is_professional
$wpP = $withPrice | Group-Object is_professional
$npP = $noPrice | Group-Object is_professional
$compResults += [PSCustomObject]@{ Variavel="is_professional"; Grupo="com_preco"; Valor=($wpP | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }
$compResults += [PSCustomObject]@{ Variavel="is_professional"; Grupo="sem_preco"; Valor=($npP | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }

$compResults | Export-Csv (Join-Path $outputsDir "representatividade_price_av.csv") -NoTypeInformation -Encoding UTF8
Write-Host "  Comparacoes salvas em outputs/representatividade_price_av.csv"

# ============================================================
# 21. Conclusao sobre viés
# ============================================================
$wpPctAp = if ($withPrice.Count -gt 0) { [math]::Round(($withPrice | Where-Object { $_.listing_type -eq "apartamento" }).Count / $withPrice.Count * 100, 1) } else { 0 }
$npPctAp = if ($noPrice.Count -gt 0) { [math]::Round(($noPrice | Where-Object { $_.listing_type -eq "apartamento" }).Count / $noPrice.Count * 100, 1) } else { 0 }
$wpPctCentro = if ($withPrice.Count -gt 0) { [math]::Round(($withPrice | Where-Object { $_.suburb -eq "Centro" }).Count / $withPrice.Count * 100, 1) } else { 0 }
$npPctCentro = if ($noPrice.Count -gt 0) { [math]::Round(($noPrice | Where-Object { $_.suburb -eq "Centro" }).Count / $noPrice.Count * 100, 1) } else { 0 }

Set-R "repr_wp_count" $withPrice.Count
Set-R "repr_np_count" $noPrice.Count
Set-R "repr_wp_pct_apartamento" $wpPctAp
Set-R "repr_np_pct_apartamento" $npPctAp
Set-R "repr_wp_pct_centro" $wpPctCentro
Set-R "repr_np_pct_centro" $npPctCentro
Set-R "repr_wp_mediana_bedrooms" $wpMedBeds
Set-R "repr_np_mediana_bedrooms" $npMedBeds
Set-R "repr_wp_mediana_reviews" $wpMedR
Set-R "repr_np_mediana_reviews" $npMedR
Set-R "repr_wp_mediana_stars" $wpMedS
Set-R "repr_np_mediana_stars" $npMedS

Write-Host "  Apartamento: com_preco=$wpPctAp% sem_preco=$npPctAp%"
Write-Host "  Centro: com_preco=$wpPctCentro% sem_preco=$npPctCentro%"
Write-Host "  Mediana quartos: com_preco=$wpMedBeds sem_preco=$npMedBeds"
Write-Host "  Mediana reviews: com_preco=$wpMedR sem_preco=$npMedR"
Write-Host "  Mediana stars: com_preco=$wpMedS sem_preco=$npMedS"

# ============================================================
# 22-26. VIVAREAL — qualidade e limpeza
# ============================================================
Write-Host "`n--- VIVAREAL ---" -ForegroundColor Yellow
Set-R "viv_linhas" $viv.Count
Set-R "viv_colunas" $viv[0].PSObject.Properties.Name.Count
Set-R "viv_colunas_nomes" ($viv[0].PSObject.Properties.Name -join "|")

# 22. Ausentes exatos
$vivAusentes = @()
foreach ($p in $viv[0].PSObject.Properties) {
    $n = $p.Name
    $empty = ($viv | Where-Object { $_.$n -eq "" -or $_.$n -eq "<NA>" }).Count
    if ($empty -gt 0) {
        $pct = [math]::Round(($empty / $viv.Count)*100, 2)
        $vivAusentes += [PSCustomObject]@{ Coluna=$n; Ausentes=$empty; Pct=$pct }
    }
}
$vivAusentes | Sort-Object Ausentes -Descending | Export-Csv (Join-Path $outputsDir "vivareal_ausentes.csv") -NoTypeInformation -Encoding UTF8
Write-Host "  Ausentes:"
$vivAusentes | Sort-Object Ausentes -Descending | ForEach-Object { Write-Host ("    {0}: {1} ({2}%)" -f $_.Coluna, $_.Ausentes, $_.Pct) }

# 22b. Valores invalidos/extremos em sale_price
$spValid = $viv | Where-Object { $_.sale_price -match '^\d+\.?\d*$' } | ForEach-Object { [double]$_.sale_price } | Sort-Object
$spPct5 = $spValid[[math]::Floor($spValid.Count * 0.05)]
$spPct25 = $spValid[[math]::Floor($spValid.Count * 0.25)]
$spPct50 = $spValid[[math]::Floor($spValid.Count * 0.50)]
$spPct75 = $spValid[[math]::Floor($spValid.Count * 0.75)]
$spPct95 = $spValid[[math]::Floor($spValid.Count * 0.95)]
Set-R "viv_sp_min" $spValid[0]
Set-R "viv_sp_max" $spValid[$spValid.Count-1]
Set-R "viv_sp_p5" $spPct5
Set-R "viv_sp_p25" $spPct25
Set-R "viv_sp_p50" $spPct50
Set-R "viv_sp_p75" $spPct75
Set-R "viv_sp_p95" $spPct95
Set-R "viv_sp_media" ([math]::Round(($spValid | Measure-Object -Average).Average, 2))
Write-Host "  sale_price: min=$($spValid[0]) p5=$spPct5 p25=$spPct25 p50=$spPct50 p75=$spPct75 p95=$spPct95 max=$($spValid[$spValid.Count-1]) media=$(($spValid | Measure-Object -Average).Average)"

# usable_area
$uaValid = $viv | Where-Object { $_.usable_area -match '^\d+\.?\d*$' } | ForEach-Object { [double]$_.usable_area } | Sort-Object
$uaPct5 = $uaValid[[math]::Floor($uaValid.Count * 0.05)]
$uaPct95 = $uaValid[[math]::Floor($uaValid.Count * 0.95)]
Set-R "viv_ua_min" $uaValid[0]
Set-R "viv_ua_max" $uaValid[$uaValid.Count-1]
Set-R "viv_ua_p5" $uaPct5
Set-R "viv_ua_p95" $uaPct95
Write-Host "  usable_area: min=$($uaValid[0]) p5=$uaPct5 p95=$uaPct95 max=$($uaValid[$uaValid.Count-1])"

# 23. Preco por m2
$ppsm = @()
foreach ($v in $viv) {
    $sp = if ($v.sale_price -match '^\d+\.?\d*$') { [double]$v.sale_price } else { $null }
    $ua = if ($v.usable_area -match '^\d+\.?\d*$') { [double]$v.usable_area } else { $null }
    if ($sp -and $ua -and $ua -gt 0) {
        $ppsm += [PSCustomObject]@{
            listing_id = $v.listing_id
            sale_price = $sp
            usable_area = $ua
            price_per_m2 = [math]::Round($sp / $ua, 2)
            suburb = $v.suburb
        }
    }
}
$ppsmSorted = $ppsm | Sort-Object price_per_m2
$ppsmP5 = $ppsmSorted[[math]::Floor($ppsmSorted.Count * 0.05)]
$ppsmP50 = $ppsmSorted[[math]::Floor($ppsmSorted.Count * 0.50)]
$ppsmP95 = $ppsmSorted[[math]::Floor($ppsmSorted.Count * 0.95)]
$ppsm | Export-Csv (Join-Path $outputsDir "vivareal_ppsm.csv") -NoTypeInformation -Encoding UTF8
Set-R "viv_ppsm_count" $ppsm.Count
Set-R "viv_ppsm_p5" $ppsmP5.price_per_m2
Set-R "viv_ppsm_p50" $ppsmP50.price_per_m2
Set-R "viv_ppsm_p95" $ppsmP95.price_per_m2
Set-R "viv_ppsm_min" $ppsmSorted[0].price_per_m2
Set-R "viv_ppsm_max" $ppsmSorted[$ppsmSorted.Count-1].price_per_m2
Write-Host "  Preco/m2: $($ppsm.Count) validos, min=$($ppsmSorted[0].price_per_m2) p5=$($ppsmP5.price_per_m2) p50=$($ppsmP50.price_per_m2) p95=$($ppsmP95.price_per_m2) max=$($ppsmSorted[$ppsmSorted.Count-1].price_per_m2)"

# 25. listing_id duplicados
$vIds = $viv | ForEach-Object { $_.listing_id }
$vDups = $vIds | Group-Object | Where-Object { $_.Count -gt 1 }
Set-R "viv_ids_total" $vIds.Count
Set-R "viv_ids_unicos" ($vIds | Sort-Object -Unique).Count
Set-R "viv_ids_dups" $(if($vDups){$vDups.Count}else{0})
Write-Host "  listing_id: $($vIds.Count) total, $(($vIds | Sort-Object -Unique).Count) unicos, dups=$(if($vDups){$vDups.Count}else{0})"

$vivDupDetails = @()
if ($vDups) {
    foreach ($d in $vDups) {
        $rows = $viv | Where-Object { $_.listing_id -eq $d.Name }
        $prices = $rows | ForEach-Object { if ($_.sale_price -match '^\d+\.?\d*$') { [double]$_.sale_price } } | Sort-Object -Unique
        $areas = $rows | ForEach-Object { $_.usable_area } | Sort-Object -Unique
        $identical = $true
        $first = $rows[0]
        for ($i = 1; $i -lt $rows.Count; $i++) {
            foreach ($p in $first.PSObject.Properties) {
                if ($rows[$i].($p.Name) -ne $first.($p.Name)) { $identical = $false; break }
            }
            if (-not $identical) { break }
        }
        $vivDupDetails += [PSCustomObject]@{
            listing_id = $d.Name
            qtd = $d.Count
            identical = $identical
            precos_distintos = ($prices -join "; ")
            areas_distintas = ($areas -join "; ")
        }
    }
}
$vivDupDetails | Export-Csv (Join-Path $outputsDir "vivareal_duplicidades.csv") -NoTypeInformation -Encoding UTF8
$vivIdentical = ($vivDupDetails | Where-Object { $_.identical -eq $true }).Count
$vivPriceChange = ($vivDupDetails | Where-Object { $_.identical -eq $false -and $_.precos_distintos -match ";" }).Count
Write-Host "  Duplicados identicos: $vivIdentical"
Write-Host "  Duplicados com mudanca: $vivPriceChange"

# 26. Regra de deduplicacao
$vivDedupRule = "Manter a linha com sale_price mais recente (aquisition_date max). Se identicas, manter 1."
Set-R "viv_regra_dedup" $vivDedupRule
Write-Host "  Regra proposta: $vivDedupRule"

# ============================================================
# SALVAR RESUMO GERAL
# ============================================================
$R.GetEnumerator() | ForEach-Object { [PSCustomObject]@{ Metrica=$_.Key; Valor=$_.Value } } |
    Export-Csv (Join-Path $outputsDir "auditoria_corretiva_resumo.csv") -NoTypeInformation -Encoding UTF8

Write-Host "`n=== FIM AUDITORIA CORRETIVA ===" -ForegroundColor Cyan
Write-Host "Arquivos gerados:"
Write-Host "  outputs/auditoria_corretiva_resumo.csv"
Write-Host "  outputs/details_ausentes.csv"
Write-Host "  outputs/hosts_ausentes.csv"
Write-Host "  outputs/hosts_duplicidades.csv"
Write-Host "  outputs/price_freq_mudancas.csv"
Write-Host "  outputs/representatividade_price_av.csv"
Write-Host "  outputs/vivareal_ausentes.csv"
Write-Host "  outputs/vivareal_ppsm.csv"
Write-Host "  outputs/vivareal_duplicidades.csv"
