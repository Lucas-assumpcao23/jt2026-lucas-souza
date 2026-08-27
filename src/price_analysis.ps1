# Price_AV analysis — efficient hashtable approach
$ErrorActionPreference = "SilentlyContinue"
$baseDir = Split-Path -Parent $PSScriptRoot
$dataDir = Join-Path $baseDir "data"
$outputsDir = Join-Path $baseDir "outputs"

Write-Host "Loading Price_AV..." -ForegroundColor Yellow
$prc = Import-Csv (Join-Path $dataDir "Price_AV_Itapema.csv") -Encoding UTF8
Write-Host "  Loaded $($prc.Count) rows"

# Build hashtable: key = "listing_id|date"
$groups = @{}
$captureDays = @{}
foreach ($row in $prc) {
    $lid = $row.airbnb_listing_id
    $dt = $row.date
    $aq = $row.aquisition_date
    $day = if ($aq.Length -ge 10) { $aq.Substring(0,10) } else { "" }
    $p = $row.price
    $key = "${lid}|${dt}"
    if (-not $groups.ContainsKey($key)) { $groups[$key] = @() }
    $groups[$key] += [PSCustomObject]@{ price=$p; aquisition_day=$day }
    if ($day -ne "") { $captureDays[$day] = $true }
}
Write-Host "  Unique listing_id|date keys: $($groups.Count)"
Write-Host "  Capture days: $($captureDays.Count)"

# 11a. Keys listing_id + date
$uniqKeys = $groups.Count
$dupKeys = ($groups.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }).Count
Write-Host ("  11a) listing_id+date: total={0}, unique={1}, dups={2}" -f $prc.Count, $uniqKeys, $dupKeys)

# 11b. Keys listing_id + date + aquisition_day
$keysLDA = @{}
foreach ($row in $prc) {
    $aq = $row.aquisition_date
    $day = if ($aq.Length -ge 10) { $aq.Substring(0,10) } else { "" }
    $k = "$($row.airbnb_listing_id)|$($row.date)|$day"
    $keysLDA[$k] = $true
}
$dupLDA = 0
foreach ($entry in $groups.GetEnumerator()) {
    $dayCounts = @{}
    foreach ($item in $entry.Value) {
        $d = $item.aquisition_day
        if ($dayCounts.ContainsKey($d)) { $dayCounts[$d]++ } else { $dayCounts[$d] = 1 }
    }
    foreach ($dc in $dayCounts.GetEnumerator()) {
        if ($dc.Value -gt 1) { $dupLDA++ }
    }
}
Write-Host ("  11b) listing_id+date+day: unique_keys={0}, dups_within_day={1}" -f $keysLDA.Count, $dupLDA)

# 12. Capture days sorted
$sortedDays = $captureDays.Keys | Sort-Object
Write-Host ("  12) Capture rounds: {0} days, from {1} to {2}" -f $sortedDays.Count, $sortedDays[0], $sortedDays[$sortedDays.Count-1])

# 13. Price variation between captures
$withVar = 0; $noVar = 0
foreach ($entry in $groups.GetEnumerator()) {
    $prices = @{}
    foreach ($item in $entry.Value) {
        $pv = $item.price
        if ($pv -match '^\d+\.?\d*$') { $prices[[double]$pv] = $true }
    }
    if ($prices.Count -gt 1) { $withVar++ } else { $noVar++ }
}
$varPct = [math]::Round(($withVar / $uniqKeys)*100, 2)
$noVarPct = [math]::Round(($noVar / $uniqKeys)*100, 2)
Write-Host ("  13) With price variation: {0} ({1}%)" -f $withVar, $varPct)
Write-Host ("  13) Without variation: {0} ({1}%)" -f $noVar, $noVarPct)

# 14. Change frequency per listing+date
$changeData = @()
foreach ($entry in $groups.GetEnumerator()) {
    $sorted = $entry.Value | Sort-Object aquisition_day
    if ($sorted.Count -gt 1) {
        $seq = @()
        foreach ($s in $sorted) {
            $pv = $s.price
            if ($pv -match '^\d+\.?\d*$') { $seq += [double]$pv }
        }
        if ($seq.Count -gt 1) {
            $changes = 0
            for ($i = 1; $i -lt $seq.Count; $i++) {
                if ($seq[$i] -ne $seq[$i-1]) { $changes++ }
            }
            $parts = $entry.Key -split '\|'
            $changeData += [PSCustomObject]@{
                airbnb_listing_id = $parts[0]
                date = $parts[1]
                capturas = $seq.Count
                mudancas = $changes
            }
        }
    }
}
$changeData | Export-Csv (Join-Path $outputsDir "price_freq_mudancas.csv") -NoTypeInformation -Encoding UTF8
$avgC = if ($changeData.Count -gt 0) { [math]::Round(($changeData | Measure-Object mudancas -Average).Average, 3) } else { 0 }
$maxC = if ($changeData.Count -gt 0) { ($changeData | Measure-Object mudancas -Maximum).Maximum } else { 0 }
$pctZero = if ($changeData.Count -gt 0) { [math]::Round(($changeData | Where-Object { $_.mudancas -eq 0 }).Count / $changeData.Count * 100, 2) } else { 0 }
Write-Host ("  14) Avg changes per listing+date: {0}" -f $avgC)
Write-Host ("  14) Max changes: {0}" -f $maxC)
Write-Host ("  14) Listings with 0 changes: {0}%" -f $pctZero)
Write-Host ("  14) Total listing+date combos with captures>1: {0}" -f $changeData.Count)

# 15. Consolidation rule
Write-Host "  15) Rule: For each (listing_id, date), take the most recent capture (max aquisition_day)"
Write-Host "  15) Justification: Latest capture reflects the most current pricing decision by the host"

Write-Host "`nDone." -ForegroundColor Green
