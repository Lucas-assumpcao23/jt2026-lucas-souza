# Base Analítica Consolidada — Airbnb
# Regras: Price_AV com captura mais recente, join com Details + Mesh
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$dataDir = Join-Path $baseDir "data"
$outputsDir = Join-Path $baseDir "outputs"
$analysisDir = Join-Path $baseDir "analysis"

Write-Host "=== BASE ANALITICA CONSOLIDADA ===" -ForegroundColor Cyan

# 1. Carregar bases
Write-Host "Carregando bases..." -ForegroundColor Yellow
$det = Import-Csv (Join-Path $dataDir "Details_Itapema.csv") -Encoding UTF8
$msh = Import-Csv (Join-Path $dataDir "Mesh_Ids_Data_Itapema.csv") -Encoding UTF8
$prc = Import-Csv (Join-Path $dataDir "Price_AV_Itapema.csv") -Encoding UTF8
Write-Host "  Details=$($det.Count) Mesh=$($msh.Count) Price=$($prc.Count)"

# 2. Mesh lookup
$mshLookup = @{}
foreach ($row in $msh) { $mshLookup[$row.airbnb_listing_id] = $row }

# 3. Price_AV: agrupar por listing_id, manter captura mais recente por listing+date
Write-Host "Processando Price_AV..." -ForegroundColor Yellow
$priceGroups = @{}
foreach ($row in $prc) {
    $lid = $row.airbnb_listing_id
    $dt = $row.date
    $aq = $row.aquisition_date
    $day = if ($aq.Length -ge 10) { $aq.Substring(0,10) } else { "" }
    $key = "${lid}|${dt}"
    if (-not $priceGroups.ContainsKey($key)) { $priceGroups[$key] = @() }
    $priceGroups[$key] += [PSCustomObject]@{ price=$row.price; aquisition_day=$day }
}

# Para cada chave, selecionar a captura mais recente
$latestPrices = @{}
foreach ($entry in $priceGroups.GetEnumerator()) {
    $sorted = $entry.Value | Sort-Object aquisition_day -Descending
    $best = $sorted[0]
    $pv = $best.price
    if ($pv -match '^\d+\.?\d*$') {
        $parts = $entry.Key -split '\|'
        $lid = $parts[0]
        if (-not $latestPrices.ContainsKey($lid)) { $latestPrices[$lid] = @() }
        $latestPrices[$lid] += [double]$pv
    }
}
Write-Host "  Listings com preco consolidado: $($latestPrices.Count)"

# 4. Filtrar apenas IDs com correspondencia em Details
$detIds = @{}
foreach ($d in $det) { $detIds[$d.airbnb_listing_id] = $d }

$validLids = @()
foreach ($lid in $latestPrices.Keys) {
    if ($detIds.ContainsKey($lid)) { $validLids += $lid }
}
Write-Host "  Listings validos (Price+Details): $($validLids.Count)"

# 5. Calcular metricas por listing
Write-Host "Calculando metricas..." -ForegroundColor Yellow
$base = @()
foreach ($lid in $validLids) {
    $prices = $latestPrices[$lid] | Sort-Object
    $n = $prices.Count
    $sorted = $prices
    $mediana = $sorted[[math]::Floor($n / 2)]
    $media = [math]::Round(($sorted | Measure-Object -Average).Average, 2)
    $p25 = $sorted[[math]::Floor($n * 0.25)]
    $p75 = $sorted[[math]::Floor($n * 0.75)]
    $soma = [math]::Round(($sorted | Measure-Object -Sum).Sum, 2)

    $d = $detIds[$lid]
    $m = $mshLookup[$lid]

    $obj = [PSCustomObject]@{
        airbnb_listing_id = $lid
        datas_estadia = $n
        diaria_mediana = $mediana
        diaria_media = $media
        diaria_p25 = $p25
        diaria_p75 = $p75
        potencial_bruto_anunciado = $soma
        suburb = if ($m) { $m.suburb } else { "" }
        listing_type = $d.listing_type
        number_of_bedrooms = $d.number_of_bedrooms
        number_of_bathrooms = $d.number_of_bathrooms
        number_of_beds = $d.number_of_beds
        number_of_guests = $d.number_of_guests
        number_of_reviews = $d.number_of_reviews
        star_rating = $d.star_rating
        is_professional = $d.is_professional
        can_instant_book = $d.can_instant_book
        is_guest_favorite = $d.is_guest_favorite
        cleaning_fee = $d.cleaning_fee
        min_nights = $d.min_nights
    }
    $base += $obj
}

# 6. Salvar
$base | Export-Csv (Join-Path $outputsDir "base_airbnb_consolidada.csv") -NoTypeInformation -Encoding UTF8
Write-Host "  Salvo: outputs/base_airbnb_consolidada.csv ($($base.Count) linhas)"

# 7. Validacao
Write-Host "`n=== VALIDACAO ===" -ForegroundColor Yellow
Write-Host ("  Total listings: {0}" -f $base.Count)

# Distribuicao de datas por listing
$distDatas = $base | Group-Object datas_estadia | Sort-Object { [int]$_.Name }
Write-Host "  Distribuicao de datas por listing:"
foreach ($g in $distDatas) {
    $pct = [math]::Round($g.Count / $base.Count * 100, 1)
    Write-Host ("    {0} datas: {1} listings ({2}%)" -f $g.Name, $g.Count, $pct)
}

# Ausentes
$ausentes = @()
foreach ($p in $base[0].PSObject.Properties) {
    $n = $p.Name
    $empty = ($base | Where-Object { $_.$n -eq "" -or $_.$n -eq "0" -or $_.$n -eq "0.0" }).Count
    if ($empty -gt 0) {
        $pct = [math]::Round($empty / $base.Count * 100, 1)
        $ausentes += [PSCustomObject]@{ Coluna=$n; Ausentes=$empty; Pct=$pct }
    }
}
Write-Host "  Ausentes:"
$ausentes | Sort-Object Ausentes -Descending | ForEach-Object {
    Write-Host ("    {0}: {1} ({2}%)" -f $_.Coluna, $_.Ausentes, $_.Pct)
}

# Exemplos
Write-Host "  5 linhas de exemplo:"
$base | Select-Object -First 5 | ForEach-Object {
    Write-Host ("    ID={0} datas={1} mediana={2} suburb={3} type={4} bed={5} reviews={6}" -f `
        $_.airbnb_listing_id, $_.datas_estadia, $_.diaria_mediana, $_.suburb, $_.listing_type, $_.number_of_bedrooms, $_.number_of_reviews)
}

# Unicidade
$unicos = $base | Select-Object -ExpandProperty airbnb_listing_id | Sort-Object -Unique
Write-Host ("  IDs unicos: {0} (confirmado: uma linha por listing)" -f $unicos.Count)

Write-Host "`n=== FIM ===" -ForegroundColor Cyan
