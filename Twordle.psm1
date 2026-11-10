function Twordle ([string[]]$TestWords, [string[]]$Find, [string]$Exclude, [string]$Import, [switch]$Force, [switch]$Play) {# Twordle/Wordle word helper and game.

function TestTwordleWords {param([string[]]$guess)
if ($guess.Count -gt 3) {Write-Host -f yellow "Ignoring extra words beyond the first three.`n"
$guess = $guess | Select-Object -First 3}
$usedletters = @{}
$positionscore = 0
$presencescore = 0

$showproceedingwarning = $false
foreach ($word in $guess) {if ($word.Length -ne 5) {Write-Host -f red "Warning: '$word' is not a 5-letter word."}
if ($word.ToLower() -notin $script:words) {Write-Host -f red "Warning: '$word' was not found in the Twordle word list."
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

function ImportTwordleList {param([string]$path = (Join-Path $PSScriptRoot 'twordle.txt'))

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

$results = foreach ($word in $script:words) {$score = TestTwordleWords $word
[pscustomobject]@{Word = $word
PresenceScore = $score.PresenceScore
PositionScore = $score.PositionScore
TotalScore = $score.TotalScore}}

$bestfirst = $results | Sort-Object TotalScore -Descending | Select-Object -First 1
$used = $bestfirst.Word.ToCharArray()

$bestsecond = $results | Where-Object {($_.Word.ToCharArray() | Where-Object {$_ -in $used}).Count -eq 0} | Sort-Object TotalScore -Descending | Select-Object -First 1
$used += $bestsecond.Word.ToCharArray()

$bestthird = $results | Where-Object {($_.Word.ToCharArray() | Where-Object {$_ -in $used}).Count -eq 0} | Sort-Object TotalScore -Descending | Select-Object -First 1

$firstposition = foreach ($i in 0..4) {($positionfreq[$i].GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1).Key}

$secondposition = foreach ($i in 0..4) {($positionfreq[$i].GetEnumerator() | Sort-Object Value -Descending | Select-Object -Skip 1 -First 1).Key}

$thirdposition = foreach ($i in 0..4) {($positionfreq[$i].GetEnumerator() | Sort-Object Value -Descending | Select-Object -Skip 2 -First 1).Key}

if ($Import -or $TestWords) {[pscustomobject]@{DictionaryFile = Split-Path $path -Leaf
WordCount = $script:words.Count
BestFirstGuess = $bestfirst.Word
FirstScore = $bestfirst.TotalScore
BestSecondGuess = $bestsecond.Word
SecondScore = $bestsecond.TotalScore
BestThirdGuess = $bestthird.Word
ThirdScore = $bestthird.TotalScore
TotalScore = $bestfirst.TotalScore + $bestsecond.TotalScore + $bestthird.TotalScore
MostCommonFirstPosition = ($firstposition -join ',')
SecondPosition = ($secondposition -join ',')
ThirdPosition = ($thirdposition -join ',')}
Write-Host -f yellow ("-" * 100)}}

function FindWord {param([string[]]$Find, [string]$Exclude)
$patterns = $Find
$correctpositions = @{}
$misplacedletters = @{}
$requiredletters = @{}
foreach ($i in 0..4) {$misplacedletters[$i] = @()}
foreach ($pattern in $patterns) {if ($pattern.Length -ne 5) {Write-Host -f red "`nInvalid pattern: $pattern`n"
return}
for ($i = 0; $i -lt 5; $i++) {$char = $pattern[$i]
if ($char -eq '_') {continue}
if ([char]::IsUpper($char)) {$letter = $char.ToString().ToLower()
$correctpositions[$i] = $letter
$requiredletters[$letter] = $true
continue}
if ([char]::IsLower($char)) {$letter = $char.ToString()
$requiredletters[$letter] = $true
if ($i -notin $correctpositions.Keys -or $correctpositions[$i] -ne $letter) {$misplacedletters[$i] += $letter}}}}
$results = foreach ($word in $script:words) {$match = $true
if ($Exclude) {foreach ($letter in $Exclude.ToLower().ToCharArray()) {if ($word.Contains($letter)) {$match = $false
break}}}
if (!$match) {continue}
foreach ($letter in $requiredletters.Keys) {if (!$word.Contains($letter)) {$match = $false
break}}
if (!$match) {continue}
foreach ($pos in $correctpositions.Keys) {if ($word[$pos] -ne $correctpositions[$pos]) {$match = $false
break}}
if (!$match) {continue}
for ($i = 0; $i -lt 5; $i++) {foreach ($letter in $misplacedletters[$i]) {if ($correctpositions.ContainsKey($i) -and $correctpositions[$i] -eq $letter) {
continue}
if ($word[$i] -eq $letter) {$match = $false
break}}
if (!$match) {break}}
if ($match) {$word}}

if ($results.Count -gt 250 -and -not $Force) {Write-Host -f white "`nThere are too many matches (" -n; Write-Host -f red "$($results.Count)" -n; Write-Host -f white "). Add more letters to the " -n; Write-Host -f cyan "Find" -n; Write-Host -f white ", or " -n; Write-Host -f cyan "Exclude" -n; Write-Host -f white " letter patterns or use the " -n; Write-Host -f cyan "Force" -n; Write-Host -f white " parameter.`n"
return}

if (-not $Import) {[pscustomobject]@{DictionaryFile = 'twordle.txt'
WordCount = $script:words.Count}
Write-Host -f yellow ("-" * 100)
Write-Host ""}

[pscustomobject]@{Pattern = $Find
Exclude = $Exclude
Matches = $results.Count
Words   = $results -join ', '}}

function ShowBoard {Clear-Host
Write-Host -f yellow "`n`t TWORDLE"
Write-Host -f yellow ("-" * 25)

foreach ($row in $board) {Write-Host "`t" -n
for ($i = 0; $i -lt 5; $i++) {Write-Host "$($row.Word[$i]) " -f $row.Colors[$i] -n}
Write-Host}

for ($i = $board.Count; $i -lt 6; $i++) {Write-Host "`t_ _ _ _ _"}
Write-Host ""

foreach ($row in @('ABCDEFGHIJKLM','NOPQRSTUVWXYZ')) {foreach ($letter in $row.ToCharArray()) {$color = $keyboard[$letter.ToString().ToLower()]
if (!$color) {$color = 'White'}
Write-Host "$letter " -f $color -n}
Write-Host ""}
Write-Host ""}

function UpdateKeyboard {param($guess,$colors)
for ($i = 0; $i -lt 5; $i++) {$letter = $guess[$i].ToString().ToLower()
$color  = $colors[$i]
switch ($color) {'Green' {$keyboard[$letter] = 'Green'}
'Yellow' {if ($keyboard[$letter] -ne 'Green') {$keyboard[$letter] = 'Yellow'}}
'DarkGray' {if ($keyboard[$letter] -notin 'Green','Yellow') {$keyboard[$letter] = 'DarkGray'}}}}}

if ($Play) {do {$board = @()
$keyboard = @{}

if ($Import) {ImportTwordleList $Import}
else {ImportTwordleList}

$answer = Get-Random $script:words

foreach ($letter in 'abcdefghijklmnopqrstuvwxyz'.ToCharArray()) {$keyboard["$letter"] = 'White'}
$won = $false
$usedwords = @()

for ($turn = 1; $turn -le 6; $turn++) {ShowBoard
Write-Host -f White "Turn $turn`n"
do {$guess = (Read-Host "Guess").ToLower()}
until ($guess -match '^[a-z]{5}$' -and $script:words -contains $guess -and $guess -notin $usedwords)

$usedwords += $guess
$colors = @('DarkGray','DarkGray','DarkGray','DarkGray','DarkGray')
$remaining = $answer.ToCharArray()

for ($i = 0; $i -lt 5; $i++) {if ($guess[$i] -eq $answer[$i]) {$colors[$i] = 'Green'
$remaining[$i] = $null}}

for ($i = 0; $i -lt 5; $i++) {if ($colors[$i] -eq 'Green') {continue}
$idx = [array]::IndexOf($remaining,$guess[$i])

if ($idx -ge 0) {$colors[$i] = 'Yellow'
$remaining[$idx] = $null}}

$board += [pscustomobject]@{Word = $guess.ToUpper()
Colors = $colors}
UpdateKeyboard $guess $colors

if ($guess -eq $answer) {$won = $true
ShowBoard
Write-Host -f green "Solved in $turn guesses!`n"
break}}

if (!$won) {ShowBoard
Write-Host -f White "Answer: " -n
Write-Host -f Green "$($answer.ToUpper())`n"}
Write-Host -f White "Play again? (Y/N) " -n; $playagain = Read-Host} until ($playagain -notmatch '^(?i)y(es)?$')
Write-Host ""
return}

Write-Host -f yellow "`n`t`t`t`tTWIRDLE/WORDLE Solver"
Write-Host -f yellow ("-" * 100)

if ($Import) {ImportTwordleList $Import}
else {ImportTwordleList}
if (-not $Find -and -not $Exclude -and $Import){Write-Host -f yellow ("-" * 100)}

if ($args.Count -gt 0 -and $args[0] -match '(?i)^[a-z]{5},[a-z]{5}$') {$TestWords = $args[0]}
if ($TestWords){TestTwordleWords $TestWords}
if ($Find) {Findword $Find $Exclude | Format-List}
if (-not $TestWords -and -not $Find) {Write-Host -f cyan "Usage: Twordle -Import <importfile> -TestWords <word1,word2,word3> -Find <_r_wS,W_RDS,...> -Exclude <abcdefg...> -Force -Play"
Write-Host -f cyan "`nTestWords" -n; Write-Host -f red " cannot" -n; Write-Host -f white " be used with the " -n; Write-Host -f cyan "Find/Exclude/Force" -n; Write-Host -f white " parameters."
Write-Host -f cyan "Exclude" -n; Write-Host -f white " and " -n; Write-Host -f cyan "Force" -n; Write-Host -f green " must" -n; Write-Host -f white " be used with the " -n; Write-Host -f cyan "Find" -n; Write-Host -f white " parameter."
Write-Host -f cyan "Import" -n; Write-Host -f white " can be used with all parameters, even " -n; Write-Host -f cyan "Play" -n; Write-Host -f white ".`n"
Write-Host -f yellow "For the " -n; Write-Host -f cyan "Find" -n; Write-Host -f yellow " parameter:`n"
Write-Host -f white "Uppercase letters" -n; Write-Host -f yellow "`trepresent the correct letters, in the correct position."
Write-Host -f white "Underscores" -n; Write-Host -f yellow "`t`trepresent unknowns."
Write-Host -f white "Lowercase letters" -n; Write-Host -f yellow "`trepresent the correct letters, but incorrect location."
Write-Host -f white "Commas" -n; Write-Host -f yellow "`t`t`tseparates multiple, sequential guesses."
Write-Host -f cyan "Exclude" -n; Write-Host -f yellow "`t`t`tlists letters that cannot be included in the results."
Write-Host -f cyan "Force" -n; Write-Host -f yellow "`t`t`tforces the display of all results, even if they exceed 250.`n"
Write-Host -f white "Examples:`n"
Write-Host -f gray "Twordle -TestWords slate,round`nTwordle -Find t_R_s,__RST`nTwordle -Find t_R_s,__RST -Exclude eaud`nTwordle -Find ___ED -Force`n"
Write-Host -f yellow ("-" * 100)
Write-Host ""
return}}
