<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Twordle</title>

<link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ccircle cx='50' cy='50' r='50' fill='%23e53935'/%3E%3Ctext x='50' y='40' font-family='Arial,sans-serif' font-size='60' font-weight='bold' fill='white' text-anchor='middle' dominant-baseline='central'%3ET%3C/text%3E%3Ctext x='50' y='60' font-family='Arial,sans-serif' font-size='60' font-weight='bold' fill='white' text-anchor='middle' dominant-baseline='central'%3EW%3C/text%3E%3C/svg%3E">

<meta name="viewport" content="width=device-width, initial-scale=1">

<style>
body{background:#000000; color:white; font-family:Arial,Helvetica,sans-serif; text-align:center; margin:0; padding:20px;}
h1{margin-bottom:10px;}
#message{height: 40px; margin-bottom:15px; color:white; font-weight:bold;}
#message.solved{color:#00FF00 !important;}
#message.error{color:#FF0000 !important;}
#message.notice{color:#FFFFFF !important;}
#message.warning{color:#F54927 !important;}

#headerRow{display:grid; grid-template-columns: 220px 1fr 300px; gap:20px; max-width:1400px; margin:auto;}
#headerRow h1{text-align:center; margin:0 0 15px 0;}

#layout{display:grid; grid-template-columns: 220px 1fr 300px; gap:20px; max-width:1400px; margin:auto; align-items:start;}

#helpButton{color:#ff0000; cursor:pointer; font-size:16px; font-weight:bold;}
#helpPopup{display:none; position:fixed; inset:0; background:rgba(0,0,0,.8); z-index:1000; justify-content:center; align-items:center; padding:15px; box-sizing:border-box;}
#helpContent{position:relative; background:#222; border:1px solid #555; border-radius:8px; padding:25px; max-width:400px; width:100%; max-height:85vh; overflow-y:auto; box-sizing:border-box; text-align:left; line-height:1.5;}
#helpContent h2{text-align:center; margin-top:0;}
#helpContent button{position:absolute; top:10px; right:10px; padding:4px 9px;}
#helpContent p{margin:12px 0;}
#helpButton,#soundButton{display:inline-block; cursor:pointer;}

#confirmPopup{display:none; position:fixed; inset:0; background:rgba(0,0,0,.8); z-index:1100; justify-content:center; align-items:center; padding:5px; box-sizing:border-box;}
#profilePopup{display:none; position:fixed; inset:0; background:rgba(0,0,0,.8); z-index:1100; justify-content:center; align-items:center; padding:5px; box-sizing:border-box;}
#dictionaryPopup{display:none; position:fixed; inset:0; background:rgba(0,0,0,.8); z-index:1100; justify-content:center; align-items:center; padding:5px; box-sizing:border-box;}
#firstGuessPopup{display:none; position:fixed; inset:0; background:rgba(0,0,0,.8); z-index:1100; justify-content:center; align-items:center; padding:5px; box-sizing:border-box;}

#confirmContent{background:#222; border:1px solid #555; border-radius:8px; padding:10px; max-width:350px; width:100%; box-sizing:border-box; text-align:center;}
#confirmContent h3{margin-top:10px; margin-bottom:15px;}
#confirmContent p{margin:5px 0 12px;}
#confirmContent button{margin:0 5px;}

#toggleConfirm {font-size:12px}
#firstGuess {margin-top:5px;}
#saveGuess {margin-top:5px; background:#225555; border:1px solid #4466aa; border-radius:6px; color:#fff;}
#profileConfirm {margin-top:5px;}
#dictionarySelect{margin-top:5px; margin-bottom:10px; padding:8px 8px; font-size:14px; font-weight:bold; cursor:pointer; background:#449; color:#fff; border:1px solid #666; border-radius:4px; width:175px;}
#newGame{color:#ffff00; cursor:pointer; font-size:16px; font-weight:bold;}

#statsPanel{text-align:left;}

#gamePanel{text-align:center;}
#controls {margin-top:5px;}

#sidePanel{position:relative; min-height:450px; max-height:450px;}
#cheatPanel{position:absolute; inset:0; z-index:1;}
#profilePanel{position:absolute; inset:0; z-index:2;}
th{background:#227; font-weight: bold;}
.profileword{cursor:pointer; color:#7db4ff;}
.profileword:hover{text-decoration:underline;}

#cheatPanel{display:none; text-align:left; border:1px solid #444; padding:10px; overflow-y:auto; max-height:450px;}
#cheatHeader {text-align:center; font-size:20px; font-weight:bold; padding-bottom:10px;}
#possibleWords{text-align:center; font-size:12px; line-height:1.5; word-wrap:break-word;}
#currentWord{font-weight:bold; color:#538d4e;}

#profilePanel{display:none; text-align:left; border:1px solid #444; padding:10px; overflow-y:auto; max-height:450px;}
#profileHeader {text-align:center; font-size:20px; font-weight:bold; padding-bottom:10px;}
#profileWords{text-align:center; font-size:12px; line-height:1.5; word-wrap:break-word;}

#secondaryButtons{margin-top:10px; margin-bottom:20px;}
#secondaryButtons button{margin:0 5px;}

#board{display:flex; flex-direction:column; gap:5px; align-items:center; margin-bottom:20px;}
.row{display:flex; gap:5px;}
.tile{width:60px; height:60px; border:2px solid #3a3a3c; display:flex; justify-content:center; align-items:center; font-size:32px;font-weight:bold; text-transform:uppercase; transition:transform .2s;}

.tile.revealed{animation:pop .15s ease-out;}
@keyframes pop{0%{transform:scale(0.99);}
99%{transform:scale(1.01);}
100%{transform:scale(1);}}

.green{background:#538d4e; border-color:#538d4e;}
.yellow{background:#b59f3b; border-color:#b59f3b;}
.gray{background:#3a3a3c; border-color:#3a3a3c;}
#guess{background:#223355; border:1px solid #4466aa; border-radius:6px; color:#fff;}

input{width:120px; height:35px; font-size:26px; text-transform:uppercase; text-align:center;}
button{padding:8px 8px; font-size:14px; font-weight:bold; cursor:pointer; background:#449; color:#fff; border:1px solid #666; border-radius:4px;}
button:active{transform:scale(0.95)}

#keyboard{max-width:700px; margin:auto;}
.keyrow{margin-top:5px;}
.key{display:inline-block; width:32px; padding:10px 0; margin:2px; border-radius:4px; background:#818384; font-weight:bold; cursor:pointer; user-select:none;}
.key.special{width:60px;}
.key:active{transform:scale(0.95);}
.key.green{background:#538d4e;}
.key.yellow{background:#b59f3b;}
.key.gray{background:#3a3a3c;}

#playagain{display:none; margin-top:15px;}

#footer{margin-top:100px; padding-bottom:20px; font-size:8px;}

@media(max-width:1000px){body{padding:10px;}
@media(max-width:1000px){#board .tile{width:min(12vw,48px); height:min(12vw,48px); font-size:min(8vw,32px);}}
@media(max-width:1000px) and (max-height:800px){#board .tile{width:min(10vw,40px); height:min(10vw,40px); font-size:min(7vw,26px);}}
@media(max-width:1000px) and (max-height:700px){#board .tile{width:min(8vw,32px); height:min(8vw,32px); font-size:min(6vw,22px);}}
#headerRow{grid-template-columns:minmax(0,1fr);}
#layout{grid-template-columns:minmax(0,1fr); gap:15px;}
#statsPanel{order:2; width:auto;}
#gamePanel{order:1; min-width:0;}
#sidePanel{order:4; position:relative; width:100%;}
#cheatPanel{min-width:0;}
#profilePanel{min-width:0;}
.tile{width:48px; height:48px; font-size:26px;}
.key{width:27px; padding:9px 0; margin:1px;}}
</style>

</head>
<body>

<div id="headerRow">
<div></div>
<h1>Twordle</h1>
<div></div>
</div>

<div id="helpPopup" onclick="if(event.target===this)toggleHelp()">
<div id="helpContent">
<button onclick="toggleHelp()">✕</button>
<h2>How to Play Twordle v3.1</h2>
<p>Guess the hidden five-letter word in six attempts.</p>
<ul>
<li>Enter any valid five-letter word.</li>
<li>Press Enter to submit your guess.</li>
<li>Each guess provides colour-coded clues.</li>
</ul>
<h3>Colour Clues</h3>
<p><span class="green">Green</span> - Correct letter in the correct position.</p>
<p><span class="yellow">Yellow</span> - Correct letter in the wrong position.</p>
<p><span class="gray">Grey</span> - Letter is not in the word.</p>
<h3>Additional Features</h3>
<ul>
<li>The keyboard at the bottom helps you keep track of all 3 colours.</li>
<li>Current Word lets you keep track of correctly guessed letters in their right spots.</li>
<li>If you guess 5 invalid words in the same round, you lose that game.</li>
<li>Clear Stats to erase your history and start again.</li>
</ul>
<h3>Cheat Features</h3>
<ul>
<li>Hint will reveal the first unguessed letter, but not the whole word. This is the least offensive cheat.</li>
<li>Evaluate will test a word to see how much it reduces the results, but be careful. It let's you test invalid words.</li>
<li>Cheat Shows you all possible matches. You have to be really stumped to use this.</li>
<li>Undo removes the last played word. This is the most egregious cheat.</li>
</ul>
<h3>Privacy</h3>
<p>This page uses localStorage/cookies to save those stats and for no other reason.</p>
<p style="text-align:center; font-weight:bold; margin-top:20px;">Have fun!</p>
</div></div>

<div id="confirmPopup" onclick="if(event.target===this)toggleConfirm()">
<div id="confirmContent">
<h3>Are you sure you want to clear your statistics?</h3>
<p>This will permanently erase all your wins, losses, hints and invalid words.</p>
<button onclick="clearCookie()">Yes, Clear Stats</button>
<button onclick="toggleConfirm()">Cancel</button>
</div></div>

<div id="dictionaryPopup" onclick="if(event.target===this)toggleDictionaryPopup()">
<div id="confirmContent">
<h3>Change Dictionary?</h3>
<p>Changing dictionaries will immediately start a new game.</p>
<button onclick="changeDictionary()">Yes, Change Dictionary</button>
<button onclick="cancelDictionaryChange()">Cancel</button>
</div>
</div>

<div id="profilePopup" onclick="if(event.target===this)toggleProfileConfirm()">
<div id="confirmContent">
<h3>Are you sure you want to clear your player profile?</h3>
<p>This will permanently erase all your word tracking, wins, and losses.</p>
<button onclick="clearProfile()">Yes, Clear Profile</button>
<button onclick="toggleProfileConfirm()">Cancel</button>
</div>
</div>

<div id="firstGuessPopup" onclick="if(event.target===this)toggleFirstGuessConfirm()">
<div id="confirmContent">
<h3>Clear Saved First Guess?</h3>
<p>Are you sure you want to clear the saved first guess "<span id="firstGuessWord"></span>"?</p>
<button onclick="clearFirstGuess()">Yes, Clear First Guess</button>
<button onclick="toggleFirstGuessConfirm()">Cancel</button>
</div>
</div>

<div id="layout">
<div id="statsPanel">
<div id="helpButton" onclick="toggleHelp()">Help ?</div> | <div id="soundButton" onclick="toggleSound()">🔊</div><br>
<br>
<div id="newGame" onclick="newGame()">New Game</div>
<br>
<div>Wins: <span id="wins">0</span></div>
<div>Losses: <span id="losses">0</span></div>
<br>
<div>Win %: <span id="winpct">0</span></div>
<div>Turns/Win: <span id="winavg">0</span></div>
<div>Invalid Words: <span id="invalidcount">0</span></div>
<br>
<div style = "color:#ff0000;">Cheats Used:</div>
<div>Hints: <span id="hintcount">0</span></div>
<div>Cheats: <span id="cheatcount">0</span></div>
<div>Undo: <span id="undocount">0</span></div>
<br>
<div><button onclick="toggleConfirm()">Clear Stats</button></div>
<br>
<div>Current Word: <span id="currentWord"></span></div>
<br>
<div><button id="profileButton" onclick="toggleProfile()">🔴 Player Profile</button><br>
<div><input id="saveGuess" maxlength="5" autocomplete="off"><br>
<button id="firstGuess" onclick="saveGuess()">Save First Guess</button></div>
<button id="profileConfirm" onclick="toggleProfileConfirm()">Clear Profile</button>
</div>
<br>
<div><select id="dictionarySelect" onchange="confirmDictionaryChange()"><option value="Twordle.txt" selected>Standard Dictionary</option><option value="SOWPODS5.txt">SOWPODS Extreme</option></select></div>
</div>

<div id="gamePanel">
<div id="message"></div>
<div id="board"></div>

<div id="controls"><input id="guess" maxlength="5" autocomplete="off"> <button onclick="submitGuess()">Guess</button></div>
<div id="secondaryButtons"><button id="hintButton" onclick="giveHint()">Hint</button><button id="evaluateButton" onclick="evaluateGuess()">Evaluate</button><button id="cheatButton" onclick="toggleCheat()">🔴 Cheat</button><button id="undoButton" onclick="undo()">Undo</button></div>
<div id="keyboard"></div>

<button id="playagain" onclick="newGame()">Play Again</button></div>

<div id="sidePanel">
<div id="cheatPanel">
<div id="cheatHeader">Possible Words:</div>
<div id="possibleWords"></div>
</div>

<div id="profilePanel">
<div id="profileHeader">Player Profile:</div>
<div id="profileWords"></div>
</div>
</div>
</div>

<div id="footer"><table><tr><td style="text-align:left;"><a href="https://github.com/Schvenn/Twirdle">Twordle on Github</a> is a WORDLE&trade; inspired clone created by Schvenn.<br><br>
This version was created with the intent of allowing people to play<br>
multiple rounds per day, and learn strategies.<br><br>
<a href="https://www.nytimes.com/games/wordle/index.html" rel="noopener noreferrer" target="_blank">Original Wordle</a> |
<a href="https://www.nytimes.com/2022/01/03/technology/wordle-word-game-creator.html" rel="noopener noreferrer" target="_blank">Original Creator</a> |
<a href="https://www.nytco.com/press/the-new-york-times-acquires-wordle/" rel="noopener noreferrer" target="_blank">Ownership</a><br><br>
Twordle is an independently developed word game and is not<br>
affiliated with or endorsed by The New York Times Company.<br>
WORDLE&trade; is a trademark of The New York Times Company.</td></tr></table></div>

<script>
let dictionary = [];
let pendingDictionary = null;
let currentDictionary = "Twordle.txt";
let soundenabled = true;
let answer = "";
let turn = 0;
let board = [];
let gameover = false;
let keyboard = {};
let usedWords = [];
let totalInvalidWords = 0;
let invalidWords = 0;
let evaluateEnabled = true;
let cheatEnabled = false;
let profileEnabled = true;
let lastCheatTurn = -1;
let wins = 0;
let losses = 0;
let totalWinTurns = 0;
let totalHints = 0;
let totalCheats = 0;
let totalUndos = 0;
let hintedPositions = [];
let previousMatches = dictionary.length;
let profile = {};

async function loadDictionary(file){const response = await fetch(file);
if(!response.ok){throw new Error(`Unable to load dictionary: ${file}`);}
const text = await response.text();
dictionary = text
.split(/\r?\n/)
.map(word => word.trim().toLowerCase())
.filter(word => /^[a-z]{5}$/.test(word));
currentDictionary = file;}

async function changeDictionary(){const file = pendingDictionary;
localStorage.setItem("twordleDictionary",file);
await loadDictionary(file);
newGame();
setMessage(file === "Twordle.txt"
? `Standard dictionary loaded (${dictionary.length.toLocaleString()} words).`
: `SOWPODS Extreme dictionary loaded (${dictionary.length.toLocaleString()} words).`,
"notice");
pendingDictionary = null;
toggleDictionaryPopup();}

function toggleHelp(){playClickSound();
const popup=document.getElementById("helpPopup");
popup.style.display=popup.style.display==="flex"?"none":"flex";}

function toggleSound(){if(soundenabled) playClickSound();
soundenabled = !soundenabled;

if(soundenabled) playClickSound();
updateSoundButton();}

function updateSoundButton(){document.getElementById("soundButton").textContent = soundenabled ? "🔊" : "🔇";}

function toggleCheat(){cheatEnabled = !cheatEnabled;
if(cheatEnabled && profileEnabled){profileEnabled = false;
document
.getElementById("profilePanel")
.style.display = "none";
updateProfileButton();
setMessage("Player Profile turned off.","notice");}

updateCheatButton();

document
.getElementById("cheatPanel")
.style.display = cheatEnabled
? "block"
: "none";

if(cheatEnabled) {beep(500,0.05,"triangle", 0.03);
setTimeout(()=>beep(700,0.05,"triangle", 0.03),50);
setTimeout(()=>beep(900,0.08,"triangle", 0.03),100);}

if(cheatEnabled && turn > 0 && lastCheatTurn !== turn){totalCheats++;
lastCheatTurn = turn;}

updatePossibleWords();
updateStats();}

function updateCheatButton(){document
.getElementById("cheatButton")
.textContent = (cheatEnabled ? "🟢 " : "🔴 ") + "Cheat";}

function toggleProfile(){profileEnabled = !profileEnabled;
if(profileEnabled && cheatEnabled){cheatEnabled = false;
document
.getElementById("cheatPanel")
.style.display = "none";
updateCheatButton();
setMessage("Cheat turned off.","notice");}

updateProfileButton();
document
.getElementById("profilePanel")
.style.display = profileEnabled
? "block"
: "none";
updateProfilePanel();}

function updateProfileButton(){document
.getElementById("profileButton")
.textContent = (profileEnabled ? "🟢 " : "🔴 ") + "Player Profile";}

function saveStats(){const stats = JSON.stringify({wins:wins,losses:losses,totalHints:totalHints,totalInvalidWords:totalInvalidWords,totalWinTurns:totalWinTurns,totalCheats:totalCheats,totalUndos:totalUndos});
try{localStorage.setItem("twordleStats",stats);}catch(e){console.warn("Unable to save TWORDLE stats to localStorage.");}
try{document.cookie = "twordleStats=" + encodeURIComponent(stats) + "; max-age=31536000; path=/; SameSite=Lax";}catch(e){console.warn("Unable to save TWORDLE stats cookie.");}}

function loadStats(){let stats = null;
try{stats = localStorage.getItem("twordleStats");}catch(e){}
if(!stats){const cookie = document.cookie.split("; ").find(row => row.startsWith("twordleStats="));
if(cookie){stats = decodeURIComponent(cookie.substring("twordleStats=".length));}}
if(stats){try{const data = JSON.parse(stats);
wins = Number(data.wins) || 0;
losses = Number(data.losses) || 0;
totalWinTurns = Number(data.totalWinTurns) || 0;
totalHints = Number(data.totalHints) || 0;
totalInvalidWords = Number(data.totalInvalidWords) || 0;
totalCheats = Number(data.totalCheats) || 0;
totalUndos = Number(data.totalUndos) || 0;}catch(e){console.warn("Unable to load TWORDLE stats.");}}}

function saveProfile(){const data = JSON.stringify(profile);
try{localStorage.setItem("twordleProfile",data);}catch(e){}
try{document.cookie = "twordleProfile=" + encodeURIComponent(data) + "; max-age=31536000; path=/; SameSite=Lax";}catch(e){}}

function loadProfile(){let data = null;
try{data = localStorage.getItem("twordleProfile");}catch(e){}

if(!data){const cookie = document.cookie.split("; ").find(row => row.startsWith("twordleProfile="));

if(cookie){data = decodeURIComponent(cookie.substring("twordleProfile=".length));}}

if(data){try{profile = JSON.parse(data);}catch(e){profile = {};}}

try{firstguess = localStorage.getItem("twordleFirstGuess") || "";}catch(e){}
document.getElementById("saveGuess").value = firstguess.toUpperCase();}

function saveGuess(){const guess = document
.getElementById("saveGuess")
.value
.toLowerCase()
.trim();

if(!guess){if(firstguess){toggleFirstGuessConfirm();}
return;}

if(!/^[a-z]{5}$/.test(guess)){setMessage("Enter a five-letter word.");
return;}

if(!dictionary.includes(guess)){setMessage("That word is not in the dictionary.");
return;}

try{localStorage.setItem("twordleFirstGuess",guess);}catch(e){}
firstguess = guess;
setMessage(`First guess saved: ${guess.toUpperCase()}`);}

function toggleConfirm(){const popup=document.getElementById("confirmPopup");popup.style.display=popup.style.display==="flex"?"none":"flex";}

function toggleProfileConfirm(){const popup=document.getElementById("profilePopup");popup.style.display=popup.style.display==="flex"?"none":"flex";}

function toggleFirstGuessConfirm(){document.getElementById("firstGuessWord").textContent = firstguess.toUpperCase();
const popup = document.getElementById("firstGuessPopup");
popup.style.display = popup.style.display === "flex"
? "none"
: "flex";}

function clearFirstGuess(){try{localStorage.removeItem("twordleFirstGuess");}catch(e){}
firstguess = "";
document
.getElementById("saveGuess")
.value = "";
toggleFirstGuessConfirm();
setMessage("Saved first guess cleared.","notice");}

function clearCookie(){try{document.cookie = "twordleStats=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";}catch(e){}
try{localStorage.removeItem("twordleStats");}catch(e){}
location.reload();}

function clearProfile(){try{document.cookie = "twordleProfile=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";}catch(e){}
try{localStorage.removeItem("twordleProfile");}catch(e){}
try{localStorage.removeItem("twordleFirstGuess");}catch(e){}
location.reload();}

function toggleDictionaryPopup(){const popup = document.getElementById("dictionaryPopup");
popup.style.display = popup.style.display === "flex"
? "none"
: "flex";}

function confirmDictionaryChange(){const selected = document
.getElementById("dictionarySelect")
.value;

if(selected === currentDictionary){return;}
pendingDictionary = selected;
toggleDictionaryPopup();}

function cancelDictionaryChange(){document
.getElementById("dictionarySelect")
.value = currentDictionary;
toggleDictionaryPopup();}

function ensureProfileWord(word){if(!profile[word]){profile[word] = {date:"", counts:[0,0,0,0,0,0,0,0,0,0,0,0]};}}

function updateStats(){document
.getElementById("wins")
.textContent = wins;

document
.getElementById("losses")
.textContent = losses;

document
.getElementById("winavg")
.textContent = wins? (totalWinTurns / wins).toFixed(1): "0";

document
.getElementById("hintcount")
.textContent = totalHints;

document
.getElementById("currentWord")
.textContent = answer.split("").map((letter,i) =>
hintedPositions.includes(i) || board.some(row => row.colors[i] === "green")
? letter.toUpperCase()
: "_").join("");

document
.getElementById("invalidcount")
.textContent = totalInvalidWords;

const total = wins + losses;

document
.getElementById("winpct")
.textContent =
total
? Math.round(wins / total * 100): 0;

document
.getElementById("cheatcount")
.textContent = totalCheats;

document
.getElementById("undocount")
.textContent = totalUndos;

saveStats();
updateProfileWords();
saveProfile();}

function giveHint(){if(gameover)
return;

let revealed = [];

for(let i=0;i<5;i++){if(hintedPositions.includes(i) || board.some(row => row.colors[i] === "green")){revealed.push(i);}}

if(revealed.length >= 4){setMessage("No more hints available.","warning");
return;}

for(let i=0;i<4;i++){if(!revealed.includes(i)){hintedPositions.push(i);
totalHints++;
updateStats();
updatePossibleWords();
setMessage("Hint revealed.","notice");
return;}}}

function evaluateGuess(){const guess = document
.getElementById("guess")
.value
.trim()
.toLowerCase();

if(!guess){if(evaluateEnabled){evaluateEnabled = false;
updateEvaluateButton();
setMessage("Evaluate is now turned off.","notice");
return;}
evaluateEnabled = true;
updateEvaluateButton();
const matches = dictionary.filter(word => wordMatchesBoard(word));
setMessage(`Based on your current board, there ${matches.length === 1 ? "is" : "are"} ${matches.length.toLocaleString()} possible ${matches.length === 1 ? "match" : "matches"}.`,"notice");
return;}

if(!/^[a-z]{5}$/.test(guess)){setMessage("Enter a five-letter word to evaluate.");return;}
const candidates = dictionary.filter(word => wordMatchesBoard(word));
const before = candidates.length;
let totalRemaining = 0;

if(board.length === 0){setMessage("Submit your first guess before using Evaluate.","notice");
return;}

for(const possibleAnswer of candidates){const pattern = scoreGuess(guess, possibleAnswer);
let remaining = 0;

for(const candidate of candidates){const test = scoreGuess(guess, candidate);
let same = true;

for(let i = 0; i < 5; i++){if(test[i] !== pattern[i]){same = false;
break;}}

if(same) remaining++;}
totalRemaining += remaining;}

const averageRemaining = Math.round(totalRemaining / before);
const reduction = before - averageRemaining;
const percent = before ? Math.round(reduction / before * 100) : 0;
setMessage(`${guess.toUpperCase()} is expected to reduce ${before} possibilites to about ${averageRemaining} (↓${percent}%).`,"message");}

function updateEvaluateButton(){document
.getElementById("evaluateButton")
.textContent = (evaluateEnabled ? "🟢 " : "🔴 ") + "Evaluate";}

function updateEvaluateStatus(){if(!evaluateEnabled){return;}
const matches = dictionary.filter(word => wordMatchesBoard(word));
setMessage(`Based on your current board, there ${matches.length.toLocaleString()} possible ${matches.length === 1 ? "match" : "matches"}.`,"notice");}

function wordMatchesBoard(word){for(const row of board){const test = scoreGuess(row.word.toLowerCase(), word);
for(let i=0;i<5;i++){if(test[i] !== row.colors[i]){return false;}}}

for(const i of hintedPositions){if(word[i] !== answer[i]){return false;}}
return true;}

function undo(){if(gameover || board.length === 0) {return;}
totalUndos++;
beep(1000,0.03,"triangle", 0.03);
setTimeout(()=>beep(850,0.03,"triangle", 0.03),30);
setTimeout(()=>beep(700,0.05,"triangle", 0.03),60);
board.pop();
usedWords.pop();
turn = Math.max(0, turn - 1);
keyboard = {};
buildKeyboard();
for(const row of board){updateKeyboard(row.word.toLowerCase(), row.colors);}
renderBoard();
updatePossibleWords();
updateStats();
setMessage("Last guess removed.","notice");}

function buildKeyboard(){const rows = ["QWERTYUIOP",
"ASDFGHJKL",
"←ZXCVBNM↵"];
let html = "";

for(const row of rows){html += '<div class="keyrow">';

for(const letter of row){const special = letter === "←" || letter === "↵"
? " special"
: "";

html += `<span class="key${special}" id="key-${letter}">${letter}</span>`;}
html += "</div>";}

document.getElementById("keyboard").innerHTML = html;

document.querySelectorAll("#keyboard .key").forEach(key=>{key.addEventListener("click",()=>{
if(gameover) return;
const input = document.getElementById("guess");
const keytext = key.textContent;

if(keytext === "←"){input.value = input.value.slice(0,-1);
beep(600,0.01,"triangle");
input.focus();
return;}

if(keytext === "↵"){submitGuess();
input.focus();
return;}

if(input.value.length < 5){input.value += keytext.toLowerCase();
beep(800,0.01,"triangle");
setMessage(`Loaded ${cell.dataset.word.toUpperCase()}.`,"notice");}

input.focus();});});}

function renderBoard(){const boardDiv =
document.getElementById("board");
let html = "";
for(let r = 0; r < 6; r++){html += '<div class="row">';

if(board[r]){const row = board[r];
for(let c = 0; c < 5; c++){const color = row.revealed[c] ? row.colors[c] : "";
const revealclass = board.activeRow === r && row.revealed[c]
? "revealed"
: "";
html += `<div class="tile ${color} ${revealclass}">${row.word[c]}</div>`;}}

else {for(let c = 0; c < 5; c++){html += '<div class="tile"></div>';}}
html += '</div>';}
boardDiv.innerHTML = html;}

function setMessage(text,type="notice"){const message = document.getElementById("message");
message.textContent = text;
message.className = type;}

function updateKeyboard(word,colors){for(let i = 0; i < 5; i++){const letter = word[i].toUpperCase();
const key = document.getElementById(`key-${letter}`);
const current = keyboard[letter];
const next = colors[i];
if(next === "green"){keyboard[letter] = "green";}
else if(next === "yellow" && current !== "green"){keyboard[letter] = "yellow";}
else if(next === "gray" && !current){keyboard[letter] = "gray";}
key.className = "key " + keyboard[letter];}}

function updatePossibleWords(){if(!cheatEnabled)
return;

const matches = dictionary.filter(word => wordMatchesBoard(word));

document
.getElementById("possibleWords")
.innerHTML = "<b>" + matches.length + (matches.length === 1 ? " match" : " matches") + "</b><br><br>" + matches.join(", ");}

function scoreGuess(guess, answerWord){let colors = ["gray","gray","gray","gray","gray"];
let remaining = answerWord.split("");

for(let i = 0; i < 5; i++){if(guess[i] === answerWord[i]){colors[i] = "green";
remaining[i] = null;}}

for(let i = 0; i < 5; i++){if(colors[i] === "green")
continue;

const idx = remaining.indexOf(guess[i]);
if(idx >= 0){colors[i] = "yellow";
remaining[idx] = null;}}

return colors;}

function updateProfileWords(){const topwords = Object.entries(profile)
.filter(([word,data]) => data.counts.slice(0,6).reduce((a,b) => a + b, 0) > 0)
.sort((a,b) => {const awins = a[1].counts.slice(0,6).reduce((x,y) => x + y, 0);
const bwins = b[1].counts.slice(0,6).reduce((x,y) => x + y, 0);
if(bwins !== awins) {return bwins - awins;}
const apos = a[1].counts.findIndex((count,i) => i < 6 && count > 0);
const bpos = b[1].counts.findIndex((count,i) => i < 6 && count > 0);
return apos - bpos;})
.slice(0,10);

let html = "<hr><h3>Top Winning Words:</h3>";
html += "<table border='1' style='width:100%; border-collapse:collapse; text-align:center;'>";
html += "<tr><th rowspan=2>Word</th><th colspan=6>Round</th></tr> <tr><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th></tr>";

for(const [word,data] of topwords){html += "<tr>";
html += `<td class="profileword" data-word="${word}">${word.toUpperCase()}</td>`;
for(let i = 0; i < 6; i++){html += `<td>${data.counts[i]}</td>`;}
html += "</tr>";}
html += "</table><br>";

html += "<hr><h3>Words Without a Win:</h3>";
html += "<table border='1' style='width:100%; border-collapse:collapse; text-align:center;'>";
html += "<tr><th rowspan=2>Word</th><th colspan=6>Round</th></tr> <tr><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th></tr>";

for(const [word,data] of Object.entries(profile)){const wins = data.counts.slice(0,6).reduce((a,b) => a + b, 0);

if(wins === 0 && losses > 0){html += "<tr>";
html += `<td>${word.toUpperCase()}</td>`;

for(let i = 6; i < 12; i++){html += `<td>${data.counts[i]}</td>`;}
html += "</tr>";}}
html += "</table>";

document
.getElementById("profileWords")
.innerHTML = html;

document.querySelectorAll(".profileword").forEach(cell=>{cell.addEventListener("click",()=>{if(gameover) return;
const guessinput = document.getElementById("guess");
guessinput.value = "";
guessinput.value = cell.dataset.word.toUpperCase();
beep(800,0.01,"triangle");
guessinput.focus();});});}

function updateProfile(result){const today = new Date().toISOString().split("T")[0];
for(let i = 0; i < usedWords.length; i++){const word = usedWords[i];

if(!profile[word]){profile[word] = {date:today,counts:[0,0,0,0,0,0,0,0,0,0,0,0]};}
profile[word].date = today;

if(result === "win"){profile[word].counts[i]++;}

if(result === "loss"){profile[word].counts[i + 6]++;}}}

function submitGuess(){if(gameover)
return;

let guess = document
.getElementById("guess")
.value
.trim()
.toLowerCase();

if(!/^[a-z]{5}$/.test(guess)){setMessage("Enter a five-letter word.","notice");
beep(150,0.25,"sawtooth", 0.02);
return;}

if(usedWords.includes(guess)){setMessage(`${guess.toUpperCase()} has already been guessed.`,"notice");
document.getElementById("guess").value = "";
beep(300,0.12,"square", 0.02);
setTimeout(()=>beep(200,0.12,"square", 0.02),100);
return;}

if(!dictionary.includes(guess)){invalidWords++;
totalInvalidWords++;
updateStats();
if(invalidWords >= 5){setMessage(`Too many invalid words. Answer: ${answer.toUpperCase()}`,"error");
document.getElementById("guess").value = "";
gameover = true;
losses++;
playLoseSound();
updateStats();
updateProfile("loss");
document
.getElementById("playagain")
.style.display = "inline-block";
return;}

setMessage(`${guess.toUpperCase()} is not in this dictionary. ${5 - invalidWords} invalid guesses remaining.`,"warning");
document.getElementById("guess").value = "";
setTimeout(()=>beep(200,0.12,"square", 0.02),100);
beep(150,0.25,"sawtooth", 0.02);
return;}

usedWords.push(guess);

const colors = scoreGuess(guess, answer);
board.push({word:guess.toUpperCase(), colors:colors, revealed:[false,false,false,false,false]});
board.activeRow = board.length - 1;
updateKeyboard(guess,colors);
renderBoard();
revealRow(board.length - 1);

updatePossibleWords();
updateStats();

document
.getElementById("cheatPanel")
.style.display = "none";
cheatEnabled = false;
updateCheatButton();

document
.getElementById("guess")
.value = "";

if(guess === answer){setMessage("Solved!","solved");
document
.getElementById("playagain")
.style.display = "inline-block";

gameover = true;
wins++;
totalWinTurns += board.length;
updateProfile("win");
updateStats();
beep(523,0.08,"triangle");
setTimeout(()=>beep(659,0.08,"triangle"),80);
setTimeout(()=>beep(784,0.10,"triangle"),160);
setTimeout(()=>beep(1047,0.35,"square"),250);
return;}
turn++;

if(turn >= 6){setMessage("Answer: " + answer.toUpperCase(),"error");
playLoseSound();

document
.getElementById("playagain")
.style.display = "inline-block";

gameover = true;
losses++;
updateProfile("loss");
updateStats();
return;}

updateEvaluateStatus();}

function revealRow(rowindex){const row = board[rowindex];
console.log("reveal");
for(let i = 0; i < 5; i++){setTimeout(()=>{
row.revealed[i] = true;

if(row.colors[i] === "green"){beep(900,0.04,"triangle",0.02);}
else if(row.colors[i] === "yellow"){beep(700,0.03,"triangle",0.02);}
else{beep(300,0.02,"square",0.02);}
renderBoard();
if(i === 4){board.activeRow = -1;}},i * 200);}}

const audiocontext = new (window.AudioContext || window.webkitAudioContext)();

function beep(freq,duration,type="sine",volume=0.1){if(audiocontext.state === "suspended"){audiocontext.resume();}
const osc = audiocontext.createOscillator();
const gain = audiocontext.createGain();
osc.type = type;
osc.frequency.value = freq;
osc.connect(gain);
gain.connect(audiocontext.destination);
gain.gain.value = volume;
osc.start();
gain.gain.exponentialRampToValueAtTime(0.0001, audiocontext.currentTime + duration);
osc.stop(audiocontext.currentTime + duration);
osc.onended = ()=>{osc.disconnect();
gain.disconnect();};}

function playLoseSound(){const ctx = new AudioContext();
const osc = ctx.createOscillator();
const gain = ctx.createGain();
osc.type = "sawtooth";
osc.frequency.setValueAtTime(250,ctx.currentTime);
osc.frequency.exponentialRampToValueAtTime(80, ctx.currentTime + 0.75);
osc.connect(gain);
gain.connect(ctx.destination);
gain.gain.setValueAtTime(0.03,ctx.currentTime);
gain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + 0.75);
osc.start();
osc.stop(ctx.currentTime + 0.75);}

function playClickSound(){beep(1200,0.01,"triangle");}

function newGame(){answer = dictionary[Math.floor(Math.random() * dictionary.length)];
board = [];
keyboard = {};
usedWords = [];
invalidWords = 0;
turn = 0;
gameover = false;
hintedPositions = [];
lastCheatTurn = -1;

document
.getElementById("cheatPanel")
.style.display = "none";
cheatEnabled = false;
updateCheatButton();

updateProfileButton();

document
.getElementById("playagain")
.style.display = "none";

document
.getElementById("guess")
.value = firstguess
? firstguess.toUpperCase()
: "";

setMessage("");
buildKeyboard();
updateEvaluateButton();


renderBoard();
updateStats();
document.getElementById("guess").focus();

if(firstguess){submitGuess();}

updateProfileWords();
document.getElementById("possibleWords").innerHTML = "";
beep(523,0.10,"sine", 0.02);
setTimeout(()=>beep(784,0.15,"sine", 0.02),100);}

document.getElementById("guess").addEventListener("keydown",e=>{if(e.key.length === 1) beep(800,0.01,"triangle");
if(e.key === "Backspace") beep(600,0.01,"triangle");
if(e.key === "Delete") beep(600,0.01,"triangle");

if(e.key === "Enter"){if(gameover){newGame();}else{submitGuess();}}});

document.getElementById("saveGuess").addEventListener("keydown",e=>{if(e.key.length === 1) beep(800,0.01,"triangle");
if(e.key === "Backspace") beep(600,0.01,"triangle");
if(e.key === "Delete") beep(600,0.01,"triangle");

if(e.key === "Enter"){saveGuess();}});

document.addEventListener("click",e=>{if(e.target.closest("button")){document.getElementById("guess").focus();}});

document.addEventListener("click",e=>{if(e.target.matches("button")){playClickSound();}});

document.getElementById("board").addEventListener("click",()=>{document.getElementById("guess").focus();});

if(window.visualViewport){window.visualViewport.addEventListener("resize",()=>{document.body.classList.toggle("keyboardOpen",window.visualViewport.height < window.innerHeight * 0.75);});}

async function initialize(){const savedDictionary = localStorage.getItem("twordleDictionary") || "Twordle.txt";
document
.getElementById("dictionarySelect")
.value = savedDictionary;
await loadDictionary(savedDictionary);

loadStats();
loadProfile();
newGame();
updateProfileButton();
document.getElementById("profilePanel").style.display = profileEnabled ? "block" : "none";
updateProfileWords();}

initialize();
</script>

</body>
</html>
