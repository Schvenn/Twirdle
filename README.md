# TWIRDLE Word Solver
This tool started as an experiment. I was looking for the best starting word for the game Twirdle based not just on the most common letters in the English language, but also their best locations.
Once I had created a tool to determine that, I decided to find out what the best follow up word would be, because 10 letters covering two turns will often give you a very strong edge on the game, with the second word being dependant on the first.
That's how this tool was born.

Then, I just kept going.

* I decided to let it evaluate alternate words to start the game and score them accordingly, as well.
* I also decided to allow the import of a custom dictionary, since I don't really know what word list the developers actually use. The included list is based on Scrabble's TWL.

At this point, the game just developed into a complete solver, because I was curious about the mechanics. 
So, I added the following:

* The ability to use uppercase, lowercase and underscores demonstrating current puzzle state, so that the script would return all possible word matches.
* The ability to define excluded letters.

Well, I did it.
I proved I could write a script that would solve the puzzles with as little effort as possible.
I'm actually kind of sad about it.
While it was fun to develop, "beating" the game can take the fun out of it, if you use it as a cheat.
Even cooler, I wrote this in under 120 lines of code.

I decided to publish it anyway, because despite the game being less than a month old on the platform, I already see that there are a dozen or so people already blatantly cheating, by solving every puzzle in under 1 second, like @exo, @jesuschrist, @jkt, @santa.
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
Twirdle -TestWords <word1,word2> -Find <L_ttERs> -Exclude <letters> -Import <importfile>
```

> **Note:** `TestWords` and `Find`/`Exclude` are mutually exclusive.

---

## Find Function Syntax

| Pattern | Meaning |
|----------|----------|
| Uppercase letters | Correct letter in the correct position |
| `_` (underscore) | Unknown letter |
| Lowercase letters | Correct letter, but in the wrong position |

### Example

```text
A_pLe
```

- `A` = correct letter, correct position
- `_` = unknown letter
- `p` = letter exists but is in the wrong position
- `L` = correct letter, correct position
- `e` = letter exists but is in the wrong position

---

# How to Solve Twirdle 

For best results, apparently we should start with:

1. **First guess:** `tares`
2. **Second guess:** `doily`

I don't, though.
I prefer `slate` and `round`, because they're more natural words.

As a strategy, I start with `slate` and only use `round` as the next word if the game tells me that I have only 1 or 2 letters right, but in the wrong position.
Between those 10 letters, including 4 vowels, I will likely guess the overwhelming majority of words the game can present in 4 turns or less.

Does knowing these two pieces of information about the English language to start the game constitute cheating, to begin with?
Maybe, but no moreso than Wheel of Fortune giving players RSTLNE on their final puzzle, because they know people will pick those, anyway.
So, I'm just hedging my bets and I'm comfortable with this strategy.

I imagine you wouldn't still be reading this far if you weren't also curious.
Happy gaming!
