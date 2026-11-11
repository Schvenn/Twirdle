# TWIRDLE/WORDLE Solver and Game
This tool started as an experiment. I was looking for the best starting word for the game Twirdle based not just on the most common letters in the English language, but also their best locations.

Twirdle is a Wordle clone, hosted on tweet.app, which is a subscription-based Twitter alternative to which I have a lifetime subscription as an early adopter.

Once I had created a tool to determine that, I decided to find out what the best follow up word would be, because 10 letters covering two turns will often give you a very strong edge on the game, with the second word being dependant on the first.
That's how this tool was born.

Then, I just kept going:

* I decided to let it evaluate alternate words to start the game and score them accordingly, as well.
* I also decided to allow the import of a custom dictionary, since I don't really know what word list the developers actually use. The included list is based on Scrabble's TWL.

At this point, the game just developed into a complete solver, because I was curious about the mechanics. 
So, I added the following:

* The ability to use uppercase, lowercase and underscores demonstrating current puzzle state, so that the script would return all possible word matches.
* The ability to define excluded letters.
* The ability to add multiple, sequential turns.
* A help screen.
* Next, I added the ability to force the output, even if the resulting number of words was greater than 250.
* I extended the word coverage to 3 words for those people who really want to push the boundaries.
* And finally, the best feature was recreating the actual game within the tool itself and since this is a solving tool, there is even a cheat switch to play the game with it enabled.

So, I did it.
I proved I could write a script that would solve the puzzles with as little effort as possible.
I'm actually kind of sad about it.
While it was fun to develop, "beating" the game can take the fun out of it, if you use it as a cheat.
Even cooler, I wrote this in under 250 lines of code.

I decided to publish it anyway, because despite the game being less than a month old on the platform at the time of writing this script, I already see that there are a dozen or so people already blatantly cheating, by solving every puzzle in under 1 second, like @exo, @jesuschrist, @jkt, @santa.
Yes, I'm calling them out, directly.
So, the integrity of the game is already compromised, but by using a tool like this properly, even using it after you have solved the puzzle honestly, it can actually help you to learn strategies and expand your vocabulary to think of words you may have missed the first time around, meaning it has some intrinsic value, even as a legitimate tool.

Personally, I use this to tool validate my first and second word plays from a mathematical standpoint, because I enjoy actually playing the game, but this tool is in the wild now.
So, do with it what you will.

---

Here is a sample output:

## Statistics

| Metric | Value |
|----------|----------|
| Dictionary File | `twirdle.txt` |
| Word Count | `5,757` |
| Best First Guess | `tares` |
| First Score | `15,547` |
| Best Second Guess | `doily` |
| Second Score | `9,392` |
| Total Score | `24,939` |
| Most Common First Position | `s, a, a, e, s` |
| Second Position | `c, o, i, t, y` |
| Third Position | `b, i, o, n, e` |

---

## Usage

```text
Usage: Twirdle -Import <importfile> -TestWords <word1,word2,word3> -Find <_r_wS,W_RDS,...> -Exclude <abcdefg...> -Force -Play -First <word> -Cheat -Help
```
`Import` can be used universally to specify a custom word list.<br><br>
`TestWords` is a stand-alone parameter that allows you score and compare up to 3 opening turns.<br><br>
`Find`, `Exclude`, and `Force` work together.<br>
`Play`, `First`, `Cheat`, and `Force` also work together.<br>

For the Find parameter:
|Parameter/Format|Description|
|---|---|
|Uppercase letters|represent the correct letters, in the correct position.|
|Underscores|represent unknowns.|
|Lowercase letters|represent the correct letters, but incorrect location.|
|Commas|separates multiple, sequential guesses.|
|Exclude|lists letters that cannot be included in the results.|
|Force|forces the display of all results, even if they exceed 250.|

---

|Parameter|Description|
|---|---|
|Play|allows you to play the game.|
|First|defines the first play to always use for every game.|
|Cheat|displays  possible results after each turn.|
|Force|forces the display of all results, even if they exceed 250.|

---

Example Usage:

```
Twirdle -TestWords slate,round
Twirdle -Find t_R_s,__RST
Twirdle -Find t_R_s,__RST -Exclude eaud
Twirdle -Find ___ED -Force
Twordle -Play -First slate -Cheat -Force 
```
---

# Game Play

* Correct letters in the correct place will appear in green.
* Misplaced letters will appear in yellow.
* Incorrect letters will appear in dark grey.
* The alphabet at the bottom will do the same, so that you can keep track of what letters are in play and those that are not yet played.
* The game will not let you replay a word or play an invalid word.
* You can import a custom dictionary with the `-import` parameter, as well.
* Possible matches will only appear if the `-cheat` parameter is used.
* F4 will display each letter sequentially, every time it is pressed, but the scoreboard at the top of the screen will keep track of this.

```
            TWORDLE   (F4:HINT)
  0 Wins /  0 Losses /  0 Hints
--------------------------------
            S L A T E
            R O U N D
            _ _ _ _ _
            _ _ _ _ _
            _ _ _ _ _
            _ _ _ _ _

    A B C D E F G H I J K L M
    N O P Q R S T U V W X Y Z

Turn 3

There are 22 possible matches: ...

Guess: WIMPY

```
---
# How to Solve Twirdle/Wordle 

For best results, apparently we should start with:

1. **First guess:** `tares`
2. **Second guess:** `doily`

I don't, though.
I prefer `slate` and `round`, because they're more natural words; and just knowing this, I already have a great head start on the game.

As a strategy, I only use `round` as the second word if the game tells me that I have only 1 or 2 letters right, but neither in the correct position, because between those 10 letters, including 4 vowels, I will likely guess the overwhelming majority of words the game chooses in 4 turns or less.

Does knowing these two pieces of information about the English language to start the game constitute cheating, to begin with?
Maybe, but no moreso than Wheel of Fortune giving players RSTLNE on their final puzzle, because they know people will pick those, anyway.
So, I'm just hedging my bets and I'm comfortable with this strategy.

I imagine you wouldn't still be reading this far if you weren't also curious.
Happy gaming!
