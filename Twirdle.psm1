function Twirdle ([string[]]$TestWords, [string]$Find, [string]$Exclude, [string]$Import) {# Twirdle word helper.

function TestTwirdleWords {param([string[]]$guess)
if ($guess.Count -gt 2) {Write-Host -f yellow "Ignoring extra words beyond the first two.`n"
$guess = $guess | Select-Object -First 2}
$usedletters = @{}
$positionscore = 0
$presencescore = 0

$showproceedingwarning = $false
foreach ($word in $guess) {if ($word.Length -ne 5) {Write-Host -f red "Warning: '$word' is not a 5-letter word."}
if ($word.ToLower() -notin $script:words) {Write-Host -f red "Warning: '$word' was not found in the Twirdle word list."
$showproceedingwarning = $true}}
if ($showproceedingwarning) {Write-Host "Exiting.`n"; return}

foreach ($word in $guess) {for ($i = 0; $i -lt 5; $i++) {$letter = $word[$i]
if (!$usedletters.ContainsKey($letter)) {$usedletters[$letter] = $true
if ($script:stats.LetterFreq.ContainsKey($letter)) {$presencescore += $script:stats.LetterFreq[$letter]}}
if ($script:stats.PositionFreq[$i].ContainsKey($letter)) {$positionscore += $script:stats.PositionFreq[$i][$letter]}}}

[pscustomobject]@{Guess = ($guess -join ', ')
UniqueLetters = $usedletters.Count
CoveragePct = [math]::Round(($usedletters.Count / 26) * 100,2)
PresenceScore = $presencescore
PositionScore = $positionscore
TotalScore = $presencescore + $positionscore}}

function ImportTwirdleList {param([string]$path = (Join-Path $PSScriptRoot 'twirdle.txt'))

$script:words = Get-Content $path | ForEach-Object {$_.Trim().ToLower()} | Where-Object {$_ -match '^[a-z]{5}$'} | Sort-Object -Unique
$letterfreq = @{}
$positionfreq = @{}

foreach ($i in 0..4) {$positionfreq[$i] = @{}}

foreach ($word in $script:words) {foreach ($letter in ($word.ToCharArray() | Select-Object -Unique)) {if (!$letterfreq.ContainsKey($letter)) {$letterfreq[$letter] = 0}
$letterfreq[$letter]++}

for ($i = 0; $i -lt 5; $i++) {$letter = $word[$i]
if (!$positionfreq[$i].ContainsKey($letter)) {$positionfreq[$i][$letter] = 0}
$positionfreq[$i][$letter]++}}

$script:stats = [pscustomobject]@{Words = $script:words
LetterFreq = $letterfreq
PositionFreq = $positionfreq}

$results = foreach ($word in $script:words) {$score = TestTwirdleWords $word
[pscustomobject]@{Word = $word
PresenceScore = $score.PresenceScore
PositionScore = $score.PositionScore
TotalScore = $score.TotalScore}}

$bestfirst = $results | Sort-Object TotalScore -Descending | Select-Object -First 1
$used = $bestfirst.Word.ToCharArray()
$bestsecond = $results | Where-Object {($_.Word.ToCharArray() | Where-Object {$_ -in $used}).Count -eq 0} | Sort-Object TotalScore -Descending | Select-Object -First 1

$firstposition = foreach ($i in 0..4) {($positionfreq[$i].GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1).Key}

$secondposition = foreach ($i in 0..4) {($positionfreq[$i].GetEnumerator() | Sort-Object Value -Descending | Select-Object -Skip 1 -First 1).Key}

$thirdposition = foreach ($i in 0..4) {($positionfreq[$i].GetEnumerator() | Sort-Object Value -Descending | Select-Object -Skip 2 -First 1).Key}

[pscustomobject]@{DictionaryFile = Split-Path $path -Leaf
WordCount = $script:words.Count
BestFirstGuess = $bestfirst.Word
FirstScore = $bestfirst.TotalScore
BestSecondGuess = $bestsecond.Word
SecondScore = $bestsecond.TotalScore
TotalScore = $bestsecond.TotalScore + $bestfirst.TotalScore
MostCommonFirstPosition = ($firstposition -join ',')
SecondPosition = ($secondposition -join ',')
ThirdPosition = ($thirdposition -join ',')}}

function FindWord {param([string]$Find, [string]$Exclude)
$results = foreach ($word in $script:words) {$match = $true
if ($Exclude) {foreach ($letter in $Exclude.ToLower().ToCharArray()) {if ($word.Contains($letter)) {$match = $false
break}}}
if (!$match) {continue}
for ($i = 0; $i -lt 5; $i++) {$patternchar = $Find[$i]
$wordchar = $word[$i]
if ($patternchar -eq '_') {continue}
if ($patternchar -cmatch '[A-Z]') {if ($wordchar -ne $patternchar.ToString().ToLower()) {$match = $false
break}
continue}
if ($patternchar -cmatch '[a-z]') {if ($word -notmatch [regex]::Escape($patternchar)) {$match = $false
break}
if ($wordchar -eq $patternchar) {$match = $false
break}}}
if ($match) {$word}}

[pscustomobject]@{Pattern = $Find
Exclude = $Exclude
Matches = $results.Count
Words = $results -join ', '}}

Write-Host -f yellow "`n`t`t`t`tTWIRDLE Word Solver"
Write-Host -f yellow ("-" * 100)

if ($Import) {ImportTwirdleList $Import}
else {ImportTwirdleList}

Write-Host -f yellow ("-" * 100)

if ($args.Count -gt 0 -and $args[0] -match '(?i)^[a-z]{5},[a-z]{5}$') {$TestWords = $args[0]}
if ($TestWords){TestTwirdleWords $TestWords}
if ($Find) {Findword $Find $Exclude}
if (-not $TestWords -and -not $Find) {Write-Host -f cyan "Usage: Twirdle -TestWords <word1,word2> -Find <L_ttERs> -Exclude <letters> -Import <importfile>"
Write-Host -f white "`nTestWords and Find/Exclude are mutually exclusive.`n"
Write-Host -f yellow "For the Find function:"
Write-Host -f white "Uppercase letters" -n; Write-Host -f yellow "`trepresent the correct letters, in the correct position."
Write-Host -f white "Underscores" -n; Write-Host -f yellow "`t`trepresent unknowns."
Write-Host -f white "Lowercase letters" -n; Write-Host -f yellow "`trepresent the correct letters, but incorrect location.`n"
Write-Host -f yellow ("-" * 100)
Write-Host ""
return}}