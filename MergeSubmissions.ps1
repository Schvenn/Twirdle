param([Parameter(Mandatory)][string]$jsonfile)

Write-Host ""
if(!(Test-Path $jsonfile)){Write-Host -f cyan "File not found: $jsonfile`n"}
if(!(Test-Path ".\Definitions.json")){Write-Host -f cyan "Definitions.json not found in current directory.`n"}

$existingjson = Get-Content ".\Definitions.json" -Raw
$existing = ConvertFrom-Json $existingjson -AsHashtable
$newjson = Get-Content $jsonfile -Raw
$newdefs = ConvertFrom-Json $newjson -AsHashtable
$merged = [ordered]@{}

foreach($word in $existing.Keys){if($newdefs.ContainsKey($word)){$merged[$word] = $newdefs[$word]}
else {$merged[$word] = $existing[$word]}}

foreach($word in $newdefs.Keys){if(!$merged.Contains($word)){$merged[$word] = $newdefs[$word]}}
$merged | ConvertTo-Json -Depth 100 | Set-Content ".\Definitions.json" -Encoding UTF8
$replaced = ($newdefs.Keys | Where-Object {$existing.ContainsKey($_)}).Count
$added = ($newdefs.Keys | Where-Object {!$existing.ContainsKey($_)}).Count

$sorted = [ordered]@{}
foreach($word in ($merged.Keys | Sort-Object)){$sorted[$word] = $merged[$word]}
$sorted | ConvertTo-Json -Depth 100 | Set-Content ".\Definitions.json" -Encoding UTF8

foreach($wordlist in @(".\SOWPODS5.txt",".\Twordle.txt")){if(Test-Path $wordlist){$words = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

Get-Content $wordlist | ForEach-Object {$w = $_.Trim().ToLower()
if($w){$null = $words.Add($w)}}

foreach($word in $newdefs.Keys){$null = $words.Add($word.ToLower())}
$words | Sort-Object | Set-Content $wordlist -Encoding UTF8}}

Write-Host -f cyan "Definitions merged successfully.`n`nUpdated:`t$replaced`nAdded:`t`t$added"
Write-Host ""

flattenjson .\Definitions.json; recycle .\Definitions.json; rename .\Definitions-output.json .\Definitions.json; recycle $jsonfile