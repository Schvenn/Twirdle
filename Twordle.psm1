function Twordle ([string[]]$TestWords, [string[]]$Find, [string]$Exclude, [string]$Import, [switch]$Force, [switch]$Play, [switch]$Cheat, [string]$First, [switch]$Help) {# Twordle/Wordle word helper and game.

# ----------------- HELP --------------------------------------------------------------------------
function help {# Inline help.
# Select content.
$scripthelp = Get-Content -Raw -Path $PSCommandPath; $sections = [regex]::Matches($scripthelp, "(?im)^## (.+?)(?=\r?\n)"); $selection = $null; $lines = @(); $wrappedLines = @(); $position = 0; $pageSize = 30; $inputBuffer = ""

# Modify fields sent to it with proper word wrapping.
function wordwrap ($field, $maximumlinelength) {if ($null -eq $field) {return $null}
$breakchars = ',.;?!\/ '; $wrapped = @()
if (-not $maximumlinelength) {[int]$maximumlinelength = (100, $Host.UI.RawUI.WindowSize.Width | Measure-Object -Maximum).Maximum}
if ($maximumlinelength -lt 60) {[int]$maximumlinelength = 60}
if ($maximumlinelength -gt $Host.UI.RawUI.BufferSize.Width) {[int]$maximumlinelength = $Host.UI.RawUI.BufferSize.Width}
foreach ($line in $field -split "`n", [System.StringSplitOptions]::None) {if ($line -eq "") {$wrapped += ""; continue}
$remaining = $line
while ($remaining.Length -gt $maximumlinelength) {$segment = $remaining.Substring(0, $maximumlinelength); $breakIndex = -1
foreach ($char in $breakchars.ToCharArray()) {$index = $segment.LastIndexOf($char)
if ($index -gt $breakIndex) {$breakIndex = $index}}
if ($breakIndex -lt 0) {$breakIndex = $maximumlinelength - 1}
$chunk = $segment.Substring(0, $breakIndex + 1); $wrapped += $chunk; $remaining = $remaining.Substring($breakIndex + 1)}
if ($remaining.Length -gt 0 -or $line -eq "") {$wrapped += $remaining}}
return ($wrapped -join "`n")}

# Display a horizontal line.
function line ($colour, $length, [switch]$pre, [switch]$post, [switch]$double) {if (-not $length) {[int]$length = (100, $Host.UI.RawUI.WindowSize.Width | Measure-Object -Maximum).Maximum}
if ($length) {if ($length -lt 60) {[int]$length = 60}
if ($length -gt $Host.UI.RawUI.BufferSize.Width) {[int]$length = $Host.UI.RawUI.BufferSize.Width}}
if ($pre) {Write-Host ""}
$character = if ($double) {"="} else {"-"}
Write-Host -f $colour ($character * $length)
if ($post) {Write-Host ""}}


function scripthelp ($section) {$pattern = "(?ims)^## ($([regex]::Escape($section)).*?)(?=^##|\z)"; $match = [regex]::Match($scripthelp, $pattern); $lines = $match.Groups[1].Value.TrimEnd() -split "`r?`n", 2; if ($lines.Count -gt 1) {$wrappedLines = (wordwrap $lines[1] 100) -split "`n", [System.StringSplitOptions]::None}
else {$wrappedLines = @()}
$position = 0}

# Display Table of Contents.
while ($true) {cls; Write-Host -f cyan "$(Get-ChildItem (Split-Path $PSCommandPath) | Where-Object { $_.FullName -ieq $PSCommandPath } | Select-Object -ExpandProperty BaseName) Help Sections:`n"

if ($sections.Count -gt 7) {$half = [Math]::Ceiling($sections.Count / 2)
for ($i = 0; $i -lt $half; $i++) {$leftIndex = $i; $rightIndex = $i + $half; $leftNumber  = "{0,2}." -f ($leftIndex + 1); $leftLabel   = " $($sections[$leftIndex].Groups[1].Value)"; $leftOutput  = [string]::Empty

if ($rightIndex -lt $sections.Count) {$rightNumber = "{0,2}." -f ($rightIndex + 1); $rightLabel  = " $($sections[$rightIndex].Groups[1].Value)"; Write-Host -f cyan $leftNumber -n; Write-Host -f white $leftLabel -n; $pad = 40 - ($leftNumber.Length + $leftLabel.Length)
if ($pad -gt 0) {Write-Host (" " * $pad) -n}; Write-Host -f cyan $rightNumber -n; Write-Host -f white $rightLabel}
else {Write-Host -f cyan $leftNumber -n; Write-Host -f white $leftLabel}}}

else {for ($i = 0; $i -lt $sections.Count; $i++) {Write-Host -f cyan ("{0,2}. " -f ($i + 1)) -n; Write-Host -f white "$($sections[$i].Groups[1].Value)"}}

# Display Header.
line yellow 100
if ($lines.Count -gt 0) {Write-Host  -f yellow $lines[0]}
else {Write-Host "Choose a section to view." -f darkgray}
line yellow 100

# Display content.
$end = [Math]::Min($position + $pageSize, $wrappedLines.Count)
for ($i = $position; $i -lt $end; $i++) {Write-Host -f white $wrappedLines[$i]}

# Pad display section with blank lines.
for ($j = 0; $j -lt ($pageSize - ($end - $position)); $j++) {Write-Host ""}

# Display menu options.
line yellow 100; Write-Host -f white "[↑/↓]  [PgUp/PgDn]  [Home/End]  |  [#] Select section  |  [Q] Quit  " -n; if ($inputBuffer.length -gt 0) {Write-Host -f cyan "section: $inputBuffer" -n}; $key = [System.Console]::ReadKey($true)

# Define interaction.
switch ($key.Key) {'UpArrow' {if ($position -gt 0) { $position-- }; $inputBuffer = ""}
'DownArrow' {if ($position -lt ($wrappedLines.Count - $pageSize)) { $position++ }; $inputBuffer = ""}
'PageUp' {$position -= 30; if ($position -lt 0) {$position = 0}; $inputBuffer = ""}
'PageDown' {$position += 30; $maxStart = [Math]::Max(0, $wrappedLines.Count - $pageSize); if ($position -gt $maxStart) {$position = $maxStart}; $inputBuffer = ""}
'Home' {$position = 0; $inputBuffer = ""}
'End' {$maxStart = [Math]::Max(0, $wrappedLines.Count - $pageSize); $position = $maxStart; $inputBuffer = ""}

'Enter' {if ($inputBuffer -eq "") {"`n"; return}
elseif ($inputBuffer -match '^\d+$') {$index = [int]$inputBuffer
if ($index -ge 1 -and $index -le $sections.Count) {$selection = $index; $pattern = "(?ims)^## ($([regex]::Escape($sections[$selection-1].Groups[1].Value)).*?)(?=^##|\z)"; $match = [regex]::Match($scripthelp, $pattern); $block = $match.Groups[1].Value.TrimEnd(); $lines = $block -split "`r?`n", 2
if ($lines.Count -gt 1) {$wrappedLines = (wordwrap $lines[1] 100) -split "`n", [System.StringSplitOptions]::None}
else {$wrappedLines = @()}
$position = 0}}
$inputBuffer = ""}

default {$char = $key.KeyChar
if ($char -match '^[Qq]$') {"`n"; return}
elseif ($char -match '^\d$') {$inputBuffer += $char}
else {$inputBuffer = ""}}}}}

# ----------------- IMPORT & CALCULATE STATISTICS -------------------------------------------------
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

# ----------------- DISPLAY DICTIONARY STATISTICS ---------

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

# ----------------- TESTWORDS ---------------------------------------------------------------------
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

# ----------------- FINDWORDS ---------------------------------------------------------------------
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
if (-not $Cheat) {Write-Host -f yellow ("-" * 100)
Write-Host ""}}

[pscustomobject]@{Pattern = $Find
Exclude = $Exclude
Matches = $results.Count
Words   = $results -join ', '}}

# ----------------- GAME --------------------------------------------------------------------------
if ($Play) {$Wins = 0
$Losses = 0
$script:Hints = 0

# ----------------- DISPLAY PLAY FIELD ------------------------------------------------------------
function ShowBoard {Clear-Host
$games = $Wins + $Losses

$hinttext = ''
if ($hintlevel -gt 0) {$hinttext = $answer.Substring(0,$hintlevel).PadRight(5,'_')}
else {$hinttext = '(F4:Hint)'}

Write-Host -f yellow ("TWORDLE".PadLeft(19)) -n; Write-Host -f green ($hinttext.ToUpper().PadLeft(12))
Write-Host -f yellow (" {0,2} Wins / {1,2} Losses / {2,2} Hints" -f $Wins,$Losses,$script:Hints)
Write-Host -f yellow ("-" * 32)

foreach ($row in $board) {Write-Host "`t    " -n
for ($i = 0; $i -lt 5; $i++) {Write-Host "$($row.Word[$i]) " -f $row.Colors[$i] -n}
Write-Host}

for ($i = $board.Count; $i -lt 6; $i++) {Write-Host "`t    _ _ _ _ _"}
Write-Host ""

foreach ($row in @('  ABCDEFGHIJKLM','  NOPQRSTUVWXYZ')) {foreach ($letter in $row.ToCharArray()) {$color = $keyboard[$letter.ToString().ToLower()]
if (!$color) {$color = 'White'}
Write-Host "$letter " -f $color -n}
Write-Host ""}
Write-Host ""}

# ----------------- COLOURIZE ALPHABET ------------------------------------------------------------
function UpdateKeyboard {param($guess,$colors)
for ($i = 0; $i -lt 5; $i++) {$letter = $guess[$i].ToString().ToLower()
$color  = $colors[$i]
switch ($color) {'Green' {$keyboard[$letter] = 'Green'}
'Yellow' {if ($keyboard[$letter] -ne 'Green') {$keyboard[$letter] = 'Yellow'}}
'DarkGray' {if ($keyboard[$letter] -notin 'Green','Yellow') {$keyboard[$letter] = 'DarkGray'}}}}}

# ----------------- INPUT -------------------------------------------------------------------------
function ReadTwordleInput {param([string]$Prompt, [int]$Length = 5, [switch]$YesNo)
Write-Host -f White $Prompt -n
$text = ''
while ($true) {$key = [Console]::ReadKey($true)
switch ($key.Key) {'Escape' {return '__QUIT__'}

'F4' {if ($Play -and $hintlevel -lt 5) {$hintlevel++; $script:Hints++; ShowBoard
Write-Host -f White "Turn $turn`n"; Write-Host -f White "$Prompt$text" -n}; continue}

'Backspace' {if ($text.Length) {$text = $text.Substring(0,$text.Length - 1)
Write-Host "`b `b" -n}}

'Enter' {if ($YesNo) {Write-Host ""; return $text}
if ($text.Length -eq $Length) {Write-Host ""; return $text.ToLower()}}

default {if ($YesNo) {if ($key.KeyChar) {$text += $key.KeyChar.ToString().ToLower()
Write-Host -f Cyan $key.KeyChar.ToString().ToUpper() -n}}

elseif ($key.KeyChar -match '[a-zA-Z]' -and $text.Length -lt $Length) {$text += $key.KeyChar
Write-Host -f Cyan $key.KeyChar.ToString().ToUpper() -n}}}}}

do {$board = @()
$keyboard = @{}
$patterns = @()
$excluded = ''

if ($Import) {ImportTwordleList $Import}
else {ImportTwordleList}

$answer = Get-Random $script:words

foreach ($letter in 'abcdefghijklmnopqrstuvwxyz'.ToCharArray()) {$keyboard["$letter"] = 'White'}
$won = $false
$usedwords = @()

for ($turn = 1; $turn -le 6; $turn++) {ShowBoard
Write-Host -f White "Turn $turn`n"

if ($Cheat -and $turn -gt 1) {$results = FindWord $patterns $excluded

if ($results) {$words = ($results.Words -split ', ') | Where-Object {$_ -and $_ -notin $usedwords}
$matches = $words.Count
Write-Host -f Yellow "There are$($results.Matches) possible matches: " -n

if ($matches -le 250) {Write-Host -f White ($words -join ', ')}
elseif ($matches -gt 250 -and $Force) {Write-Host -f White ($words -join ', ')}
Write-Host ""}}

if ($turn -eq 1 -and $First.ToLower() -in $script:words) {$guess = $First.ToLower()}
elseif ($turn -eq 1 -and $First) {do {$guess = (ReadTwordleInput "First Guess: ")
if ($guess -eq '__QUIT__') {Write-Host -f Cyan "`n`nExiting.`n"; return}}
until ($guess -match '^[a-z]{5}$' -and $script:words -contains $guess)
$First = $guess}
else {do {$guess = (ReadTwordleInput "Guess: ")
if ($guess -eq '__QUIT__') {Write-Host -f Cyan "`n`nExiting.`n"; return}}
until ($guess -match '^[a-z]{5}$' -and $script:words -contains $guess -and $guess -notin $usedwords)}

$usedwords += $guess
$colors = @('DarkGray','DarkGray','DarkGray','DarkGray','DarkGray')
$remaining = $answer.ToCharArray()

for ($i = 0; $i -lt 5; $i++) {if ($guess[$i] -eq $answer[$i]) {$colors[$i] = 'Green'
$remaining[$i] = $null}}

for ($i = 0; $i -lt 5; $i++) {if ($colors[$i] -eq 'Green') {continue}
$idx = [array]::IndexOf($remaining,$guess[$i])

if ($idx -ge 0) {$colors[$i] = 'Yellow'
$remaining[$idx] = $null}}
$knownletters = @()

for ($i = 0; $i -lt 5; $i++) {if ($colors[$i] -in 'Green','Yellow') {$knownletters += $guess[$i]}}
$pattern = ''

for ($i = 0; $i -lt 5; $i++) {switch ($colors[$i]) {'Green' {$pattern += $guess[$i].ToString().ToUpper()}
'Yellow' {$pattern += $guess[$i]}
default {$pattern += '_'

if ($guess[$i] -notin $knownletters -and $excluded -notmatch [regex]::Escape($guess[$i])) {$excluded += $guess[$i]}}}}
$patterns += $pattern
$board += [pscustomobject]@{Word = $guess.ToUpper()
Colors = $colors}
UpdateKeyboard $guess $colors

if ($guess -eq $answer) {$won = $true
$Wins++
ShowBoard
Write-Host -f green "Solved in $turn guesses!`n"
break}}

if (!$won) {$Losses++
ShowBoard
Write-Host -f White "Answer: " -n
Write-Host -f Red "$($answer.ToUpper())`n"}
$playagain = ReadTwordleInput "Play again? (Y/N) " -YesNo

if ($guess -eq '__QUIT__') {Write-Host -f Cyan "`n`nExiting.`n"; return}} 
until ($playagain -notmatch '^(?i)y(es)?$')

Write-Host ""; return}

# ----------------- CALL UTILITIES ----------------------------------------------------------------
if ($help) {help; return}
Write-Host -f yellow "`n`t`t`t`tTWIRDLE/WORDLE Solver"
Write-Host -f yellow ("-" * 100)

if ($Import) {ImportTwordleList $Import}
else {ImportTwordleList}
if (-not $Find -and -not $Exclude -and $Import){Write-Host -f yellow ("-" * 100)}

if ($args.Count -gt 0 -and $args[0] -match '(?i)^[a-z]{5},[a-z]{5}$') {$TestWords = $args[0]}
if ($TestWords){TestTwordleWords $TestWords}
if ($Find) {Findword $Find $Exclude | Format-List}

# ----------------- HELP SCREEN -------------------------------------------------------------------
if (-not $TestWords -and -not $Find) {Write-Host -f cyan "Usage: Twordle -Import <importfile> -TestWords <word1,word2,word3> -Find <_r_wS,W_RDS,...> -Exclude <abcdefg...> -Force -Play -First <word> -Cheat -Help`n"
Write-Host -f cyan "Import" -n; Write-Host -f white " can be used universally to specify a custom word list.`n"
Write-Host -f cyan "TestWords" -n; Write-Host -f white " is a stand-alone parameter that allows you score and compare up to 3 opening turns.`n"
Write-Host -f cyan "Find, Exclude," -n; Write-Host -f white " and " -n; Write-Host -f cyan "Force" -n; Write-Host -f white " work together."
Write-Host -f cyan "Play, First, Cheat," -n; Write-Host -f white " and " -n; Write-Host -f cyan "Force" -n; Write-Host -f white " also work together.`n"
Write-Host -f yellow ("-"*80)
Write-Host -f yellow "`nFor the " -n; Write-Host -f cyan "Find" -n; Write-Host -f yellow " parameter:`n"
Write-Host -f white "Uppercase letters" -n; Write-Host -f yellow "`trepresent the correct letters, in the correct position."
Write-Host -f white "Underscores" -n; Write-Host -f yellow "`t`trepresent unknowns."
Write-Host -f white "Lowercase letters" -n; Write-Host -f yellow "`trepresent the correct letters, but incorrect location."
Write-Host -f white "Commas" -n; Write-Host -f yellow "`t`t`tseparates multiple, sequential guesses."
Write-Host -f cyan "Exclude" -n; Write-Host -f yellow "`t`t`tlists letters that cannot be included in the results."
Write-Host -f cyan "Force" -n; Write-Host -f yellow "`t`t`tforces the display of all results, even if they exceed 250.`n"
Write-Host -f yellow ("-"*80)
Write-Host -f green "`nPlay" -n; Write-Host -f yellow "`tallows you to play the game."
Write-Host -f green "First" -n; Write-Host -f yellow "`tdefines the first play to always use for every game."
Write-Host -f green "Cheat" -n; Write-Host -f yellow "`tdisplays  possible results after each turn."
Write-Host -f green "Force" -n; Write-Host -f yellow "`tforces the display of all results, even if they exceed 250.`n"
Write-Host -f yellow ("-"*80)
Write-Host -f white "`nExample Usages:`n"
Write-Host -f gray "Twordle -TestWords slate,round`nTwordle -Find t_R_s,__RST`nTwordle -Find t_R_s,__RST -Exclude eaud`nTwordle -Find ___ED -Force`nTwordle -Play -First slate -Cheat -Force`n"
Write-Host -f yellow ("-" * 100)
Write-Host ""
return}}

# Helptext.

<#
## Twordle
This module serves two purposes:

* The first is to provide a number of utilities to help play Wordle/Twirdle.
* The second is to actually play an offline version of the game called Twordle.

Usage: Twordle  -Import <importfile> 
		-TestWords <word1,word2,word3> 
		-Find <_r_wS,W_RDS,...> -Exclude <abcdefg...> -Force 
		-Play -First <word> -Cheat -Force
		-Help

You can use -Import to define a custom dictionary file.
The TestWords option provides a weighted statistical analysis of various plays.
The Find option is a cheat tool to assist in solving the puzzle.
The Play option lets you play an offline version of the game.

---------------------------------------------------------------------------------------------------
TestWords allows you to evaluate from one to three opening plays to determine their mathematical effectiveness against other words.

Example Usages:

Twordle -TestWords slate
Twordle -TestWords slate,round,wimpy

---------------------------------------------------------------------------------------------------
FindWords allows you to display a list of words that match a specific pattern:

	Uppercase letters       represent the correct letters, in the correct position.
	Underscores             represent unknowns.
	Lowercase letters       represent the correct letters, but incorrect location.
	Commas                  separates multiple, sequential guesses.

* Exclude is used in conjunction with Find to define which letters have already been ruled out, in order to further reduce the resulting set of possibilities.
* Force will display all results, even if there are more than 250.

Example Usages:

Twordle -Find t_R_s,__RST
Twordle -Find t_R_s,__RST -Exclude eaud
Twordle -Find ___ED -Force

---------------------------------------------------------------------------------------------------
If you choose to play the game there are a few options that can be configured:

	* First defines the first word to play in every game, useful for long sessions.
	* Cheat dynamically displays all the possible word matches after your first turn.
	* Force will display all results, even if there are more than 250.

During gameplay, pressing F4 will reveal each subsequent letter, but the scoreboard at the top will keep track of this. This hint function is independent of the Cheat function.
## Sample TestWords Screen
C:\Users\Public\Desktop> Twordle -TestWords slate,round,punch

                                TWIRDLE/WORDLE Solver
----------------------------------------------------------------------------------------------------

DictionaryFile          : twordle.txt
WordCount               : 5757
BestFirstGuess          : tares
FirstScore              : 15547
BestSecondGuess         : doily
SecondScore             : 9392
BestThirdGuess          : punch
ThirdScore              : 6625
TotalScore              : 31564
MostCommonFirstPosition : s,a,a,e,s
SecondPosition          : c,o,i,t,y
ThirdPosition           : b,i,o,n,e

----------------------------------------------------------------------------------------------------
Guess         : slate, round, punch
UniqueLetters : 13
CoveragePct   : 50
PresenceScore : 19884
PositionScore : 6772
TotalScore    : 26656

## Sample Find Screen
C:\Users\Public\Desktop> Twordle -find __a_e,ra__y,_rea_ -exclude dmnqstlz

                                TWIRDLE/WORDLE Solver
----------------------------------------------------------------------------------------------------

DictionaryFile : twordle.txt
WordCount      : 5757

----------------------------------------------------------------------------------------------------

Pattern : {__a_e, ra__y, _rea_}
Exclude : dmnqstlz
Matches : 1
Words   : yerba
## License
MIT License

Copyright (c) 2026 Craig Plath

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
##>
