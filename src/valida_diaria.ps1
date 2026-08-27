# Validação da métrica diaria_mediana
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$base = Import-Csv (Join-Path $baseDir "outputs\base_airbnb_consolidada.csv") -Encoding UTF8

function Get-Percentile { param($arr, $pct)
    $sorted = $arr | Sort-Object
    $idx = [math]::Floor($sorted.Count * $pct)
    return $sorted[$idx]
}

# Todas as métricas de diaria_mediana
$all = $base | ForEach-Object { [double]$_.diaria_mediana } | Sort-Object
Write-Host "=== TODOS OS 999 LISTINGS ==="
Write-Host ("  Minimo: {0}" -f $all[0])
Write-Host ("  P1: {0}" -f (Get-Percentile $all 0.01))
Write-Host ("  P5: {0}" -f (Get-Percentile $all 0.05))
Write-Host ("  P25: {0}" -f (Get-Percentile $all 0.25))
Write-Host ("  Mediana: {0}" -f (Get-Percentile $all 0.50))
Write-Host ("  P75: {0}" -f (Get-Percentile $all 0.75))
Write-Host ("  P95: {0}" -f (Get-Percentile $all 0.95))
Write-Host ("  P99: {0}" -f (Get-Percentile $all 0.99))
Write-Host ("  Maximo: {0}" -f $all[$all.Count-1])

# Top 15 maiores e menores
$baseSorted = $base | Sort-Object { [double]$_.diaria_mediana }
Write-Host "`n=== 15 MENORES ==="
$baseSorted | Select-Object -First 15 | ForEach-Object {
    Write-Host ("  {0} | {1} | {2} | br={3} g={4} d={5} | med={6} p25={7} p75={8}" -f `
        $_.airbnb_listing_id, $_.suburb, $_.listing_type, $_.number_of_bedrooms, $_.number_of_guests, $_.datas_estadia, $_.diaria_mediana, $_.diaria_p25, $_.diaria_p75)
}
Write-Host "`n=== 15 MAIORES ==="
$baseSorted | Select-Object -Last 15 | Sort-Object { [double]$_.diaria_mediana } -Descending | ForEach-Object {
    Write-Host ("  {0} | {1} | {2} | br={3} g={4} d={5} | med={6} p25={7} p75={8}" -f `
        $_.airbnb_listing_id, $_.suburb, $_.listing_type, $_.number_of_bedrooms, $_.number_of_guests, $_.datas_estadia, $_.diaria_mediana, $_.diaria_p25, $_.diaria_p75)
}

# IQR para detecção de extremos
$q1 = Get-Percentile $all 0.25
$q3 = Get-Percentile $all 0.75
$iqr = $q3 - $q1
$lowerFence = $q1 - 1.5 * $iqr
$upperFence = $q3 + 1.5 * $iqr
Write-Host ("`n=== IQR ===")
Write-Host ("  Q1={0} Q3={1} IQR={2}" -f $q1, $q3, $iqr)
Write-Host ("  Lower fence (Q1-1.5*IQR): {0}" -f $lowerFence)
Write-Host ("  Upper fence (Q3+1.5*IQR): {0}" -f $upperFence)
$belowFence = ($all | Where-Object { $_ -lt $lowerFence }).Count
$aboveFence = ($all | Where-Object { $_ -gt $upperFence }).Count
Write-Host ("  Abaixo do fence: {0}" -f $belowFence)
Write-Host ("  Acima do fence: {0}" -f $aboveFence)

# Comparação de 3 amostras
# A) Todos
Write-Host "`n=== AMOSTRA A: Todos (999) ==="
Write-Host ("  Qtd: {0}" -f $all.Count)

# B) Pelo menos 30 datas
$baseB = $base | Where-Object { [int]$_.datas_estadia -ge 30 }
$allB = $baseB | ForEach-Object { [double]$_.diaria_mediana } | Sort-Object
Write-Host "`n=== AMOSTRA B: Pelo menos 30 datas ==="
Write-Host ("  Qtd: {0}" -f $baseB.Count)
if ($allB.Count -gt 0) {
    Write-Host ("  Minimo: {0}" -f $allB[0])
    Write-Host ("  P1: {0}" -f (Get-Percentile $allB 0.01))
    Write-Host ("  P5: {0}" -f (Get-Percentile $allB 0.05))
    Write-Host ("  P25: {0}" -f (Get-Percentile $allB 0.25))
    Write-Host ("  Mediana: {0}" -f (Get-Percentile $allB 0.50))
    Write-Host ("  P75: {0}" -f (Get-Percentile $allB 0.75))
    Write-Host ("  P95: {0}" -f (Get-Percentile $allB 0.95))
    Write-Host ("  P99: {0}" -f (Get-Percentile $allB 0.99))
    Write-Host ("  Maximo: {0}" -f $allB[$allB.Count-1])
}

# C) Pelo menos 30 datas e diaria_mediana entre P1 e P99
$p1All = Get-Percentile $all 0.01
$p99All = Get-Percentile $all 0.99
$baseC = $base | Where-Object { [int]$_.datas_estadia -ge 30 -and [double]$_.diaria_mediana -ge $p1All -and [double]$_.diaria_mediana -le $p99All }
$allC = $baseC | ForEach-Object { [double]$_.diaria_mediana } | Sort-Object
Write-Host "`n=== AMOSTRA C: >=30 datas E diaria entre P1 e P99 ==="
Write-Host ("  Qtd: {0}" -f $baseC.Count)
Write-Host ("  Filtro P1={0} P99={1}" -f $p1All, $p99All)
if ($allC.Count -gt 0) {
    Write-Host ("  Minimo: {0}" -f $allC[0])
    Write-Host ("  P5: {0}" -f (Get-Percentile $allC 0.05))
    Write-Host ("  P25: {0}" -f (Get-Percentile $allC 0.25))
    Write-Host ("  Mediana: {0}" -f (Get-Percentile $allC 0.50))
    Write-Host ("  P75: {0}" -f (Get-Percentile $allC 0.75))
    Write-Host ("  P95: {0}" -f (Get-Percentile $allC 0.95))
    Write-Host ("  Maximo: {0}" -f $allC[$allC.Count-1])
}

Write-Host "`n=== FIM ==="
