# Representativeness + VivaReal quality analysis
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$dataDir = Join-Path $baseDir "data"
$outputsDir = Join-Path $baseDir "outputs"

Write-Host "Loading bases..." -ForegroundColor Yellow
$det = Import-Csv (Join-Path $dataDir "Details_Itapema.csv") -Encoding UTF8
$msh = Import-Csv (Join-Path $dataDir "Mesh_Ids_Data_Itapema.csv") -Encoding UTF8
$prc = Import-Csv (Join-Path $dataDir "Price_AV_Itapema.csv") -Encoding UTF8
$viv = Import-Csv (Join-Path $dataDir "VivaReal_Itapema.csv") -Encoding UTF8
Write-Host "  Details=$($det.Count) Mesh=$($msh.Count) Price=$($prc.Count) Viva=$($viv.Count)"

# ============================================================
# REPRESENTATIVIDADE (17-20)
# ============================================================
Write-Host "`n=== REPRESENTATIVIDADE ===" -ForegroundColor Cyan

# 17. Flag de preco
$priceIds = @{}
foreach ($row in $prc) { $priceIds[$row.airbnb_listing_id] = $true }
Write-Host ("  Listings with price in Price_AV: {0}" -f $priceIds.Count)

# Build suburb lookup from Mesh
$suburbLookup = @{}
foreach ($row in $msh) { $suburbLookup[$row.airbnb_listing_id] = $row.suburb }

# Classify each detail listing
$withPrice = @()
$noPrice = @()
foreach ($d in $det) {
    $hasP = $priceIds.ContainsKey($d.airbnb_listing_id)
    $sb = if ($suburbLookup.ContainsKey($d.airbnb_listing_id)) { $suburbLookup[$d.airbnb_listing_id] } else { "" }
    $obj = [PSCustomObject]@{
        airbnb_listing_id = $d.airbnb_listing_id
        has_price = if ($hasP) { "sim" } else { "nao" }
        suburb = $sb
        number_of_bedrooms = $d.number_of_bedrooms
        listing_type = $d.listing_type
        number_of_guests = $d.number_of_guests
        number_of_reviews = $d.number_of_reviews
        star_rating = $d.star_rating
        is_professional = $d.is_professional
    }
    if ($hasP) { $withPrice += $obj } else { $noPrice += $obj }
}
Write-Host ("  Com preco: {0}" -f $withPrice.Count)
Write-Host ("  Sem preco: {0}" -f $noPrice.Count)

$comp = @()

# --- suburb ---
$wpSub = $withPrice | Group-Object suburb | Sort-Object Count -Descending
$npSub = $noPrice | Group-Object suburb | Sort-Object Count -Descending
$comp += [PSCustomObject]@{ Variavel="suburb_top5"; Grupo="com_preco"; Valor=($wpSub | Select-Object -First 5 | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }
$comp += [PSCustomObject]@{ Variavel="suburb_top5"; Grupo="sem_preco"; Valor=($npSub | Select-Object -First 5 | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }

$wpCentro = ($withPrice | Where-Object { $_.suburb -eq "Centro" }).Count
$npCentro = ($noPrice | Where-Object { $_.suburb -eq "Centro" }).Count
$wpCentroPct = [math]::Round($wpCentro / $withPrice.Count * 100, 1)
$npCentroPct = [math]::Round($npCentro / $noPrice.Count * 100, 1)
$wpMeia = ($withPrice | Where-Object { $_.suburb -eq "Meia Praia" }).Count
$npMeia = ($noPrice | Where-Object { $_.suburb -eq "Meia Praia" }).Count
$wpMeiaPct = [math]::Round($wpMeia / $withPrice.Count * 100, 1)
$npMeiaPct = [math]::Round($npMeia / $noPrice.Count * 100, 1)
$comp += [PSCustomObject]@{ Variavel="pct_Centro"; Grupo="com_preco"; Valor="$wpCentro ($wpCentroPct%)" }
$comp += [PSCustomObject]@{ Variavel="pct_Centro"; Grupo="sem_preco"; Valor="$npCentro ($npCentroPct%)" }
$comp += [PSCustomObject]@{ Variavel="pct_Meia_Praia"; Grupo="com_preco"; Valor="$wpMeia ($wpMeiaPct%)" }
$comp += [PSCustomObject]@{ Variavel="pct_Meia_Praia"; Grupo="sem_preco"; Valor="$npMeia ($npMeiaPct%)" }

# --- number_of_bedrooms ---
function Get-MedianInt { param($arr)
    $valid = $arr | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ } | Sort-Object
    if ($valid.Count -eq 0) { return "N/A" }
    return $valid[[math]::Floor($valid.Count / 2)]
}
$wpBeds = $withPrice | ForEach-Object { $_.number_of_bedrooms }
$npBeds = $noPrice | ForEach-Object { $_.number_of_bedrooms }
$wpMedB = Get-MedianInt $wpBeds
$npMedB = Get-MedianInt $npBeds
$comp += [PSCustomObject]@{ Variavel="bedrooms_mediana"; Grupo="com_preco"; Valor=$wpMedB }
$comp += [PSCustomObject]@{ Variavel="bedrooms_mediana"; Grupo="sem_preco"; Valor=$npMedB }

# bedrooms distribution
$wpBDist = $withPrice | Group-Object number_of_bedrooms | Sort-Object { if ($_.Name -match '^\d+$') { [int]$_.Name } else { 999 } }
$npBDist = $noPrice | Group-Object number_of_bedrooms | Sort-Object { if ($_.Name -match '^\d+$') { [int]$_.Name } else { 999 } }
$comp += [PSCustomObject]@{ Variavel="bedrooms_dist"; Grupo="com_preco"; Valor=($wpBDist | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }
$comp += [PSCustomObject]@{ Variavel="bedrooms_dist"; Grupo="sem_preco"; Valor=($npBDist | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }

# --- listing_type ---
$wpLT = $withPrice | Group-Object listing_type | Sort-Object Count -Descending
$npLT = $noPrice | Group-Object listing_type | Sort-Object Count -Descending
$comp += [PSCustomObject]@{ Variavel="listing_type"; Grupo="com_preco"; Valor=($wpLT | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }
$comp += [PSCustomObject]@{ Variavel="listing_type"; Grupo="sem_preco"; Valor=($npLT | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }

# --- number_of_guests ---
function Get-MedianDouble { param($arr)
    $valid = $arr | Where-Object { $_ -match '^\d+\.?\d*$' } | ForEach-Object { [double]$_ } | Sort-Object
    if ($valid.Count -eq 0) { return "N/A" }
    return $valid[[math]::Floor($valid.Count / 2)]
}
$wpG = $withPrice | ForEach-Object { $_.number_of_guests }
$npG = $noPrice | ForEach-Object { $_.number_of_guests }
$wpMedG = Get-MedianDouble $wpG
$npMedG = Get-MedianDouble $npG
$comp += [PSCustomObject]@{ Variavel="guests_mediana"; Grupo="com_preco"; Valor=$wpMedG }
$comp += [PSCustomObject]@{ Variavel="guests_mediana"; Grupo="sem_preco"; Valor=$npMedG }

# --- number_of_reviews ---
$wpR = $withPrice | ForEach-Object { $_.number_of_reviews }
$npR = $noPrice | ForEach-Object { $_.number_of_reviews }
$wpMedR = Get-MedianDouble $wpR
$npMedR = Get-MedianDouble $npR
$wpAvgR = $wpR | Where-Object { $_ -match '^\d+\.?\d*$' } | ForEach-Object { [double]$_ }
$npAvgR = $npR | Where-Object { $_ -match '^\d+\.?\d*$' } | ForEach-Object { [double]$_ }
$wpAvgRVal = if ($wpAvgR.Count -gt 0) { [math]::Round(($wpAvgR | Measure-Object -Average).Average, 2) } else { "N/A" }
$npAvgRVal = if ($npAvgR.Count -gt 0) { [math]::Round(($npAvgR | Measure-Object -Average).Average, 2) } else { "N/A" }
$comp += [PSCustomObject]@{ Variavel="reviews_mediana"; Grupo="com_preco"; Valor=$wpMedR }
$comp += [PSCustomObject]@{ Variavel="reviews_mediana"; Grupo="sem_preco"; Valor=$npMedR }
$comp += [PSCustomObject]@{ Variavel="reviews_media"; Grupo="com_preco"; Valor=$wpAvgRVal }
$comp += [PSCustomObject]@{ Variavel="reviews_media"; Grupo="sem_preco"; Valor=$npAvgRVal }

# --- star_rating ---
$wpS = $withPrice | ForEach-Object { $_.star_rating }
$npS = $noPrice | ForEach-Object { $_.star_rating }
$wpMedS = Get-MedianDouble $wpS
$npMedS = Get-MedianDouble $npS
$comp += [PSCustomObject]@{ Variavel="star_rating_mediana"; Grupo="com_preco"; Valor=$wpMedS }
$comp += [PSCustomObject]@{ Variavel="star_rating_mediana"; Grupo="sem_preco"; Valor=$npMedS }

# --- is_professional ---
$wpP = $withPrice | Group-Object is_professional | Sort-Object Count -Descending
$npP = $noPrice | Group-Object is_professional | Sort-Object Count -Descending
$comp += [PSCustomObject]@{ Variavel="is_professional"; Grupo="com_preco"; Valor=($wpP | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }
$comp += [PSCustomObject]@{ Variavel="is_professional"; Grupo="sem_preco"; Valor=($npP | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join "; " }

$comp | Export-Csv (Join-Path $outputsDir "representatividade_price_av.csv") -NoTypeInformation -Encoding UTF8
Write-Host "  Saved outputs/representatividade_price_av.csv"
Write-Host ""
Write-Host "  Summary:" -ForegroundColor Yellow
Write-Host ("    Centro: com={0}% sem={1}%" -f $wpCentroPct, $npCentroPct)
Write-Host ("    Meia Praia: com={0}% sem={1}%" -f $wpMeiaPct, $npMeiaPct)
Write-Host ("    Mediana quartos: com={0} sem={1}" -f $wpMedB, $npMedB)
Write-Host ("    Mediana reviews: com={0} sem={1}" -f $wpMedR, $npMedR)
Write-Host ("    Mediana stars: com={0} sem={1}" -f $wpMedS, $npMedS)

# ============================================================
# VIVAREAL QUALIDADE (22-26)
# ============================================================
Write-Host "`n=== VIVAREAL QUALIDADE ===" -ForegroundColor Cyan

# 22. Ausentes exatos
$vivAus = @()
foreach ($p in $viv[0].PSObject.Properties) {
    $n = $p.Name
    $empty = ($viv | Where-Object { $_.$n -eq "" -or $_.$n -eq "<NA>" }).Count
    if ($empty -gt 0) {
        $pct = [math]::Round(($empty / $viv.Count)*100, 2)
        $vivAus += [PSCustomObject]@{ Coluna=$n; Ausentes=$empty; Pct=$pct }
    }
}
$vivAus | Sort-Object Ausentes -Descending | Export-Csv (Join-Path $outputsDir "vivareal_ausentes.csv") -NoTypeInformation -Encoding UTF8
Write-Host "  Ausentes:"
$vivAus | Sort-Object Ausentes -Descending | ForEach-Object { Write-Host ("    {0}: {1} ({2}%)" -f $_.Coluna, $_.Ausentes, $_.Pct) }

# 22b. Percentis sale_price
$spValid = @()
foreach ($v in $viv) {
    if ($v.sale_price -match '^\d+\.?\d*$') { $spValid += [double]$v.sale_price }
}
$spValid = $spValid | Sort-Object
if ($spValid.Count -gt 0) {
    $n = $spValid.Count
    $spMin = $spValid[0]
    $spP5 = $spValid[[math]::Floor($n * 0.05)]
    $spP25 = $spValid[[math]::Floor($n * 0.25)]
    $spP50 = $spValid[[math]::Floor($n * 0.50)]
    $spP75 = $spValid[[math]::Floor($n * 0.75)]
    $spP95 = $spValid[[math]::Floor($n * 0.95)]
    $spMax = $spValid[$n-1]
    $spAvg = [math]::Round(($spValid | Measure-Object -Average).Average, 2)
    Write-Host ("  sale_price: n={0} min={1} p5={2} p25={3} p50={4} p75={5} p95={6} max={7} avg={8}" -f $n,$spMin,$spP5,$spP25,$spP50,$spP75,$spP95,$spMax,$spAvg)
}

# usable_area
$uaValid = @()
foreach ($v in $viv) {
    if ($v.usable_area -match '^\d+\.?\d*$') { $uaValid += [double]$v.usable_area }
}
$uaValid = $uaValid | Sort-Object
if ($uaValid.Count -gt 0) {
    $n = $uaValid.Count
    Write-Host ("  usable_area: n={0} min={1} p5={2} p50={3} p95={4} max={5}" -f $n, $uaValid[0], $uaValid[[math]::Floor($n*0.05)], $uaValid[[math]::Floor($n*0.50)], $uaValid[[math]::Floor($n*0.95)], $uaValid[$n-1])
}

# monthly_condo_fee
$cfValid = @()
foreach ($v in $viv) {
    if ($v.monthly_condo_fee -match '^\d+\.?\d*$') { $cfValid += [double]$v.monthly_condo_fee }
}
Write-Host ("  monthly_condo_fee: validos={0} ausentes={1}" -f $cfValid.Count, ($viv.Count - $cfValid.Count))
if ($cfValid.Count -gt 0) {
    $cfSorted = $cfValid | Sort-Object
    $n = $cfSorted.Count
    Write-Host ("    min={0} p50={1} max={2}" -f $cfSorted[0], $cfSorted[[math]::Floor($n*0.50)], $cfSorted[$n-1])
}

# yearly_iptu
$ipValid = @()
foreach ($v in $viv) {
    if ($v.yearly_iptu -match '^\d+\.?\d*$') { $ipValid += [double]$v.yearly_iptu }
}
Write-Host ("  yearly_iptu: validos={0} ausentes={1}" -f $ipValid.Count, ($viv.Count - $ipValid.Count))
if ($ipValid.Count -gt 0) {
    $ipSorted = $ipValid | Sort-Object
    $n = $ipSorted.Count
    Write-Host ("    min={0} p50={1} max={2}" -f $ipSorted[0], $ipSorted[[math]::Floor($n*0.50)], $ipSorted[$n-1])
}

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
$ppsm | Export-Csv (Join-Path $outputsDir "vivareal_ppsm.csv") -NoTypeInformation -Encoding UTF8
if ($ppsmSorted.Count -gt 0) {
    $n = $ppsmSorted.Count
    Write-Host ("  price_per_m2: n={0} min={1} p5={2} p50={3} p95={4} max={5}" -f $n, $ppsmSorted[0].price_per_m2, $ppsmSorted[[math]::Floor($n*0.05)].price_per_m2, $ppsmSorted[[math]::Floor($n*0.50)].price_per_m2, $ppsmSorted[[math]::Floor($n*0.95)].price_per_m2, $ppsmSorted[$n-1].price_per_m2)
}

# 25. listing_id duplicados
$vIds = $viv | ForEach-Object { $_.listing_id }
$vIdGroups = @{}
foreach ($v in $viv) {
    $id = $v.listing_id
    if (-not $vIdGroups.ContainsKey($id)) { $vIdGroups[$id] = @() }
    $vIdGroups[$id] += $v
}
$vDups = $vIdGroups.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
$dupCount = ($vDups | Measure-Object).Count
Write-Host ("  listing_id: total={0} unique={1} duplicados={2}" -f $vIds.Count, $vIdGroups.Count, $dupCount)

$vivDupDetails = @()
foreach ($d in $vDups) {
    $rows = $d.Value
    $prices = @()
    foreach ($r in $rows) {
        if ($r.sale_price -match '^\d+\.?\d*$') { $prices += [double]$r.sale_price }
    }
    $pricesU = $prices | Sort-Object -Unique
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
        listing_id = $d.Key
        qtd = $rows.Count
        identical = $identical
        precos_distintos = ($pricesU -join "; ")
        areas_distintas = ($areas -join "; ")
    }
}
$vivDupDetails | Export-Csv (Join-Path $outputsDir "vivareal_duplicidades.csv") -NoTypeInformation -Encoding UTF8
$identicalCount = ($vivDupDetails | Where-Object { $_.identical -eq $true }).Count
$priceChangeCount = ($vivDupDetails | Where-Object { $_.identical -eq $false }).Count
Write-Host ("  Duplicados identicos: {0}" -f $identicalCount)
Write-Host ("  Duplicados diferentes (mudanca de preco/atributos): {0}" -f $priceChangeCount)

Write-Host "`nDone." -ForegroundColor Green
