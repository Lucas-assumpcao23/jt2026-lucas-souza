# Auditoria Tecnica - Dados Itapema (v2 - eficiente com Import-Csv)
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$dataDir = Join-Path $baseDir "data"
$outputsDir = Join-Path $baseDir "outputs"
$analysisDir = Join-Path $baseDir "analysis"
if (-not (Test-Path $outputsDir)) { New-Item -ItemType Directory -Path $outputsDir -Force | Out-Null }
if (-not (Test-Path $analysisDir)) { New-Item -ItemType Directory -Path $analysisDir -Force | Out-Null }
$results = @()

function Add-Result { param([string]$Section, [string]$Metric, [string]$Value)
    $script:results += [PSCustomObject]@{ Section=$Section; Metric=$Metric; Value=$Value }
}

# ============================================================
# 1. DETAILS
# ============================================================
Write-Host "Lendo Details..." -ForegroundColor Yellow
$det = Import-Csv (Join-Path $dataDir "Details_Itapema.csv") -Encoding UTF8
Add-Result "DETAILS" "Linhas" $det.Count
Add-Result "DETAILS" "Colunas" $det[0].PSObject.Properties.Name.Count
$colNames = ($det[0].PSObject.Properties.Name -join ", ")
Write-Host "  Colunas: $colNames"

# Ausentes por coluna
foreach ($prop in $det[0].PSObject.Properties) {
    $name = $prop.Name
    $empty = ($det | Where-Object { $_.$name -eq "" -or $_.$name -eq "<NA>" -or $_.$name -eq "null" }).Count
    $pct = [math]::Round(($empty / $det.Count) * 100, 1)
    if ($empty -gt 0) { Add-Result "DETAILS_AUSENTES" "$name" "$empty ($pct%)" }
}

# Chave primaria
$ids = $det | Select-Object -ExpandProperty airbnb_listing_id
$uniqueIds = $ids | Sort-Object -Unique
Write-Host "  IDs: $($ids.Count) total, $($uniqueIds.Count) unicos"
Add-Result "DETAILS_CHAVE" "airbnb_listing_id total" "$($ids.Count)"
Add-Result "DETAILS_CHAVE" "airbnb_listing_id unicos" "$($uniqueIds.Count)"
$dups = $ids | Group-Object | Where-Object { $_.Count -gt 1 }
if ($dups) {
    Add-Result "DETAILS_CHAVE" "Duplicados" "$($dups.Count) listings"
    $dups | Select-Object -First 5 | ForEach-Object { Add-Result "DETAILS_CHAVE" "  Exemplo" "$($_.Name): $($_.Count)x" }
}

# listing_type
$types = $det | Group-Object listing_type | Sort-Object Count -Descending
Write-Host "  listing_type:"
foreach ($t in $types) { Write-Host "    '$($t.Name)': $($t.Count)"; Add-Result "DETAILS_TIPOS" "'$($t.Name)'" "$($t.Count)" }

# Exemplos
$sample = $det | Select-Object -First 3
foreach ($s in $sample) {
    Add-Result "DETAILS_EXEMPLO" "ID" $s.airbnb_listing_id
    Add-Result "DETAILS_EXEMPLO" "Nome" $s.ad_name
    Add-Result "DETAILS_EXEMPLO" "Quartos" $s.number_of_bedrooms
    Add-Result "DETAILS_EXEMPLO" "Reviews" $s.number_of_reviews
    Add-Result "DETAILS_EXEMPLO" "Tipo" $s.listing_type
}

# ============================================================
# 2. HOSTS
# ============================================================
Write-Host "Lendo Hosts..." -ForegroundColor Yellow
$hosts = Import-Csv (Join-Path $dataDir "Hosts_ids_Itapema.csv") -Encoding UTF8
Add-Result "HOSTS" "Linhas" $hosts.Count
Add-Result "HOSTS" "Colunas" $hosts[0].PSObject.Properties.Name.Count

foreach ($prop in $hosts[0].PSObject.Properties) {
    $name = $prop.Name
    $empty = ($hosts | Where-Object { $_.$name -eq "" -or $_.$name -eq "<NA>" }).Count
    $pct = [math]::Round(($empty / $hosts.Count) * 100, 1)
    if ($empty -gt 0) { Add-Result "HOSTS_AUSENTES" "$name" "$empty ($pct%)" }
}

$hIds = $hosts | Select-Object -ExpandProperty owner_id
$hUnique = $hIds | Sort-Object -Unique
Write-Host "  owner_id: $($hIds.Count) total, $($hUnique.Count) unicos"
Add-Result "HOSTS_CHAVE" "owner_id total" "$($hIds.Count)"
Add-Result "HOSTS_CHAVE" "owner_id unicos" "$($hUnique.Count)"
$hDups = $hIds | Group-Object | Where-Object { $_.Count -gt 1 }
if ($hDups) { Add-Result "HOSTS_CHAVE" "Duplicados" "$($hDups.Count) hosts" }

# superhost
$sh = $hosts | Group-Object is_superhost
foreach ($s in $sh) { Add-Result "HOSTS_SUPERHOST" "'$($s.Name)'" "$($s.Count)" }

# ============================================================
# 3. MESH
# ============================================================
Write-Host "Lendo Mesh..." -ForegroundColor Yellow
$mesh = Import-Csv (Join-Path $dataDir "Mesh_Ids_Data_Itapema.csv") -Encoding UTF8
Add-Result "MESH" "Linhas" $mesh.Count
Add-Result "MESH" "Colunas" $mesh[0].PSObject.Properties.Name.Count

foreach ($prop in $mesh[0].PSObject.Properties) {
    $name = $prop.Name
    $empty = ($mesh | Where-Object { $_.$name -eq "" -or $_.$name -eq "<NA>" }).Count
    $pct = [math]::Round(($empty / $mesh.Count) * 100, 1)
    if ($empty -gt 0) { Add-Result "MESH_AUSENTES" "$name" "$empty ($pct%)" }
}

$mIds = $mesh | Select-Object -ExpandProperty airbnb_listing_id
$mUnique = $mIds | Sort-Object -Unique
Write-Host "  IDs: $($mIds.Count) total, $($mUnique.Count) unicos"
Add-Result "MESH_CHAVE" "airbnb_listing_id total" "$($mIds.Count)"
Add-Result "MESH_CHAVE" "airbnb_listing_id unicos" "$($mUnique.Count)"

# Bairros
$bairros = $mesh | Group-Object suburb | Sort-Object Count -Descending
Write-Host "  Bairros:"
foreach ($b in $bairros) { Write-Host "    $($b.Name): $($b.Count)"; Add-Result "MESH_BAIRROS" $b.Name "$($b.Count)" }

# ============================================================
# 4. PRICE_AV
# ============================================================
Write-Host "Lendo Price_AV..." -ForegroundColor Yellow
$price = Import-Csv (Join-Path $dataDir "Price_AV_Itapema.csv") -Encoding UTF8
Add-Result "PRICE" "Linhas" $price.Count
Add-Result "PRICE" "Colunas" $price[0].PSObject.Properties.Name.Count

foreach ($prop in $price[0].PSObject.Properties) {
    $name = $prop.Name
    $empty = ($price | Where-Object { $_.$name -eq "" -or $_.$name -eq "<NA>" }).Count
    $pct = [math]::Round(($empty / $price.Count) * 100, 1)
    if ($empty -gt 0) { Add-Result "PRICE_AUSENTES" "$name" "$empty ($pct%)" }
}

$pIds = $price | Select-Object -ExpandProperty airbnb_listing_id
$pUnique = $pIds | Sort-Object -Unique
Write-Host "  IDs: $($pIds.Count) registros, $($pUnique.Count) unicos"
Add-Result "PRICE_CHAVE" "airbnb_listing_id registros" "$($pIds.Count)"
Add-Result "PRICE_CHAVE" "airbnb_listing_id unicos" "$($pUnique.Count)"

# Listings com multiplos registros
$pMulti = $pIds | Group-Object | Where-Object { $_.Count -gt 1 }
Write-Host "  Listings com multiplos registros: $($pMulti.Count)"
Add-Result "PRICE_CHAVE" "Listings multiplos" "$($pMulti.Count)"

# Datas de estadia
$dates = $price | Select-Object -ExpandProperty date | Sort-Object -Unique
Write-Host "  Datas estadia: $($dates.Count) unicas, de $($dates[0]) a $($dates[$dates.Count-1])"
Add-Result "PRICE_DATAS" "Datas estadia unicas" "$($dates.Count)"
Add-Result "PRICE_DATAS" "Periodo" "$($dates[0]) a $($dates[$dates.Count-1])"

# Datas de captura
$aqDates = $price | Select-Object -ExpandProperty aquisition_date
$aqUnique = $aqDates | Sort-Object -Unique
Write-Host "  Datas captura: $($aqUnique.Count)"
foreach ($ad in $aqUnique) { Add-Result "PRICE_DATAS" "Captura" $ad }

# Preco stats
$prices = $price | ForEach-Object { [double]$_.price } | Where-Object { $_ -gt 0 }
$minP = ($prices | Measure-Object -Minimum).Minimum
$maxP = ($prices | Measure-Object -Maximum).Maximum
$avgP = [math]::Round(($prices | Measure-Object -Average).Average, 2)
$medP = ($prices | Sort-Object)[[math]::Floor($prices.Count / 2)]
Write-Host "  Precos: min=$minP, max=$maxP, media=$avgP, mediana=$medP"
Add-Result "PRICE_PRECOS" "Minimo" $minP
Add-Result "PRICE_PRECOS" "Maximo" $maxP
Add-Result "PRICE_PRECOS" "Media" $avgP
Add-Result "PRICE_PRECOS" "Mediana" $medP
Add-Result "PRICE_PRECOS" "Qtd precos validos" $prices.Count

# ============================================================
# 5. VIVAREAL
# ============================================================
Write-Host "Lendo VivaReal..." -ForegroundColor Yellow
$viva = Import-Csv (Join-Path $dataDir "VivaReal_Itapema.csv") -Encoding UTF8
Add-Result "VIVAREAL" "Linhas" $viva.Count
Add-Result "VIVAREAL" "Colunas" $viva[0].PSObject.Properties.Name.Count
$vivaColNames = ($viva[0].PSObject.Properties.Name -join ", ")
Write-Host "  Colunas: $vivaColNames"

foreach ($prop in $viva[0].PSObject.Properties) {
    $name = $prop.Name
    $empty = ($viva | Where-Object { $_.$name -eq "" -or $_.$name -eq "<NA>" }).Count
    $pct = [math]::Round(($empty / $viva.Count) * 100, 1)
    if ($empty -gt 0) { Add-Result "VIVAREAL_AUSENTES" "$name" "$empty ($pct%)" }
}

# sale_price stats
$salePrices = $viva | Where-Object { $_.sale_price -ne "" } | ForEach-Object { [double]$_.sale_price } | Where-Object { $_ -gt 0 }
if ($salePrices.Count -gt 0) {
    $vpMin = ($salePrices | Measure-Object -Minimum).Minimum
    $vpMax = ($salePrices | Measure-Object -Maximum).Maximum
    $vpAvg = [math]::Round(($salePrices | Measure-Object -Average).Average, 2)
    Write-Host "  sale_price: min=$vpMin, max=$vpMax, media=$vpAvg, qtd=$($salePrices.Count)"
    Add-Result "VIVAREAL_PRECO" "Minimo" $vpMin
    Add-Result "VIVAREAL_PRECO" "Maximo" $vpMax
    Add-Result "VIVAREAL_PRECO" "Media" $vpAvg
    Add-Result "VIVAREAL_PRECO" "Qtd validos" $salePrices.Count
}

# quartos
$vBeds = $viva | Group-Object bedrooms | Sort-Object Count -Descending
Write-Host "  Quartos:"
foreach ($b in $vBeds) { if ($b.Name) { Write-Host "    $($b.Name): $($b.Count)"; Add-Result "VIVAREAL_QUARTOS" $b.Name "$($b.Count)" } }

# Bairro
$vBairros = $viva | Group-Object suburb | Sort-Object Count -Descending
Write-Host "  Bairros:"
foreach ($b in $vBairros) { if ($b.Name) { Write-Host "    $($b.Name): $($b.Count)"; Add-Result "VIVAREAL_BAIRROS" $b.Name "$($b.Count)" } }

# property_type
$vTypes = $viva | Group-Object property_type | Sort-Object Count -Descending
Write-Host "  property_type:"
foreach ($t in $vTypes) { if ($t.Name) { Write-Host "    $($t.Name): $($t.Count)"; Add-Result "VIVAREAL_TIPOS" $t.Name "$($t.Count)" } }

# listing_id check
$vIds = $viva | Select-Object -ExpandProperty listing_id
$vUnique = $vIds | Sort-Object -Unique
Write-Host "  listing_id: $($vIds.Count) total, $($vUnique.Count) unicos"
Add-Result "VIVAREAL_CHAVE" "listing_id total" "$($vIds.Count)"
Add-Result "VIVAREAL_CHAVE" "listing_id unicos" "$($vUnique.Count)"
$vDups = $vIds | Group-Object | Where-Object { $_.Count -gt 1 }
if ($vDups) { Add-Result "VIVAREAL_CHAVE" "Duplicados" "$($vDups.Count) listings" }

# ============================================================
# RELACIONAMENTOS
# ============================================================
Write-Host ""
Write-Host "=== RELACIONAMENTOS ===" -ForegroundColor Cyan

# Details x Mesh
$detInMesh = ($uniqueIds | Where-Object { $_ -in $mUnique }).Count
$meshInDet = ($mUnique | Where-Object { $_ -in $uniqueIds }).Count
Write-Host "Details->Mesh: $detInMesh / $($uniqueIds.Count) ($([math]::Round(($detInMesh/$uniqueIds.Count)*100,1))%)"
Add-Result "RELACIONAMENTO" "Details em Mesh" "$detInMesh / $($uniqueIds.Count) ($([math]::Round(($detInMesh/$uniqueIds.Count)*100,1))%)"
Add-Result "RELACIONAMENTO" "Mesh em Details" "$meshInDet / $($mUnique.Count) ($([math]::Round(($meshInDet/$mUnique.Count)*100,1))%)"

# Details x Price_AV
$detInPrice = ($uniqueIds | Where-Object { $_ -in $pUnique }).Count
$priceInDet = ($pUnique | Where-Object { $_ -in $uniqueIds }).Count
Write-Host "Details->Price: $detInPrice / $($uniqueIds.Count) ($([math]::Round(($detInPrice/$uniqueIds.Count)*100,1))%)"
Add-Result "RELACIONAMENTO" "Details em Price_AV" "$detInPrice / $($uniqueIds.Count) ($([math]::Round(($detInPrice/$uniqueIds.Count)*100,1))%)"
Add-Result "RELACIONAMENTO" "Price_AV em Details" "$priceInDet / $($pUnique.Count) ($([math]::Round(($priceInDet/$pUnique.Count)*100,1))%)"

# Details x Hosts (owner_id)
$detOwners = $det | Select-Object -ExpandProperty owner_id | Sort-Object -Unique
$hostOwners = $hosts | Select-Object -ExpandProperty owner_id | Sort-Object -Unique
$detInHosts = ($detOwners | Where-Object { $_ -in $hostOwners }).Count
$hostsInDet = ($hostOwners | Where-Object { $_ -in $detOwners }).Count
Write-Host "Details->Hosts: $detInHosts / $($detOwners.Count) ($([math]::Round(($detInHosts/$detOwners.Count)*100,1))%)"
Add-Result "RELACIONAMENTO" "Owners Details em Hosts" "$detInHosts / $($detOwners.Count) ($([math]::Round(($detInHosts/$detOwners.Count)*100,1))%)"
Add-Result "RELACIONAMENTO" "Hosts em Details" "$hostsInDet / $($hostOwners.Count) ($([math]::Round(($hostsInDet/$hostOwners.Count)*100,1))%)"

# Relacao many-to-many
Add-Result "RELACAO" "Details->Mesh" "1:1 (listing->listing)"
Add-Result "RELACAO" "Details->Price_AV" "1:N (listing->datas)"
Add-Result "RELACAO" "Details->Hosts" "N:1 (listings->host)"

# ============================================================
# Salvar tabelas auxiliares
# ============================================================
$results | Export-Csv (Join-Path $outputsDir "auditoria_tabelas.csv") -NoTypeInformation -Encoding UTF8
Write-Host ""
Write-Host "Tabelas salvas em outputs/auditoria_tabelas.csv" -ForegroundColor Green
Write-Host "=== FIM ===" -ForegroundColor Cyan
