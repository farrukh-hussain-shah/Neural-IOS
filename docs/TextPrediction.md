# Word prediction (SymSpell)

The suggestion bar offers corrections, completions and next words. It uses two downloadable
word lists and the SymSpell algorithm, the same technique the Android keyboard uses, and it
learns from what the user types.

## Word lists

| File | Format | Used for |
| --- | --- | --- |
| `frequency_dictionary.txt` | `word frequency` per line | correction and completion |
| `bigram_frequency_dictionary.txt` | `previous next frequency` per line | next-word prediction |

Frequencies are on a 10–99 scale; higher means more common. The URLs are in
`TextPredictionConfiguration.Remote`.

The lists are too large to ship in the app, so they are **downloaded in the background when
the app launches** (`DictionarySync.start()` in `NeuralKeyApp.init`, while the splash screen
shows). They are saved in the App Group container, where the keyboard extension reads them,
and refreshed weekly with a conditional request. If the app hasn't downloaded them yet, the
keyboard downloads them itself when it has Full Access.

## Code layout

```
Shared/TextPrediction/
  TextPredictionConfiguration.swift   every tunable value (URLs, weights, limits)
  PredictionService.swift             entry point used by the keyboard (one per process)
  Model/
    TextContext.swift                 current word, previous word, sentence start
    Prediction.swift                  a suggestion, and how a word was entered (LearningSource)
    WordNormalizer.swift              lookup keys and casing
  Engine/
    TextPredictionEngine.swift        ranks candidates and learns
    Lexicon.swift                     the downloaded words, indexed
    SymSpellIndex.swift               SymSpell spelling correction
    EditDistance.swift                Damerau–Levenshtein distance
    TypoModel.swift                   bonuses for common typos
    FrequencyListParser.swift         reads the two files
    UserDictionary.swift              learned words and word pairs
  Storage/
    PredictionStorage.swift           where files live
    DictionaryDownloader.swift        background download and refresh
NeuralKey/Core/TextPrediction/
  DictionarySync.swift                starts the download at app launch
```

The keyboard connects in two places:

- `SuggestionProvider` fills the three suggestion slots from `PredictionService`.
- `KeyboardController` reports finished words to `PredictionService.learn`: when a space,
  return or punctuation ends a typed word, and when a suggestion is picked.

## How a suggestion is chosen

While typing a word, slot 1 is the word itself in quotes. Slots 2 and 3 are the best of:

- **completions**: words starting with the typed letters;
- **corrections**: SymSpell matches within 1 edit (words up to 4 letters) or 2 edits, offered
  only when the typed word isn't a real word.

Score = frequency + bonus when the word often follows the previous word − 25 per edit for
corrections. Common typos (a skipped, swapped or doubled letter, or a neighbouring key) get a
bonus back, so "helo" offers "hello". After a space, the three most frequent continuations of
the previous word are shown.

## Learning

`UserDictionary` is saved as `TextPrediction/user_dictionary.json`.

- Each use of a word adds `usageWeight` to its frequency, and each use of a word pair adds
  `bigramUsageWeight` to that pair.
- A new word (a name, slang) is suggested once it has been typed twice, or at once if the user
  picks the quoted typed word. This keeps one-off typos out of the suggestions.
- At most 5,000 learned words are kept; unconfirmed and rarely used words are dropped first.

## Checks

`scripts/ci/check_prediction.sh` runs on every push (iOS Build workflow). It downloads the real
lists, checks SymSpell against a brute-force search, and checks corrections, next words,
learning, saving and speed. The simulator test `test13WordPrediction` checks the same flow in
the app's keyboard.
