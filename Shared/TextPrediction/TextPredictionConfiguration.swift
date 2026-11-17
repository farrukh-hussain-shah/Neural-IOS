import Foundation

/// Every tunable value of word correction, completion, next-word prediction and learning.
///
/// Change behaviour here rather than in the engine code. Frequencies in the downloaded word lists
/// are on a 10–99 scale (higher means more common), so the weights below are on that scale too.
enum TextPredictionConfiguration {
    /// The downloadable word lists. They are too large to ship inside the app, so the app
    /// downloads them in the background on launch (see `DictionaryDownloader`).
    enum Remote {
        /// One word per line: `word frequency`. Used for correction and completion.
        static let wordsURL = URL(string: "https://neuralixsmc.info/frequency_dictionary.txt")!
        /// One pair per line: `previous next frequency`. Used for next-word prediction.
        static let bigramsURL = URL(string: "https://neuralixsmc.info/bigram_frequency_dictionary.txt")!
        /// How long a downloaded list is used before the server is asked for a newer one.
        static let refreshInterval: TimeInterval = 7 * 24 * 60 * 60
        static let requestTimeout: TimeInterval = 60
        /// A download with fewer valid lines than this is rejected (an error page, a cut-off file).
        static let minimumValidLines = 1_000
    }

    /// SymSpell spelling correction (see `SymSpellIndex`).
    enum Correction {
        /// The largest number of edits (insert, delete, replace, swap) a correction may need.
        static let maxEditDistance = 2
        /// Only the first letters of each word are indexed; longer words are still matched in full.
        /// 7 is SymSpell's recommended balance between memory and speed.
        static let prefixLength = 7
        /// Words shorter than this are never corrected.
        static let minimumWordLength = 3
        /// Words up to this length allow 1 edit; longer words allow `maxEditDistance`.
        static let singleEditMaxLength = 4
    }

    /// How candidates are scored. Higher scores are shown first.
    enum Ranking {
        /// Subtracted from a correction's score for each edit it needs.
        static let penaltyPerEdit = 25
        /// Extra penalty for a correction shorter than what was typed, so a half-typed word is
        /// completed ("hel" → "hello") rather than cut short ("hel" → "he").
        static let shorterCorrectionPenalty = 10
        /// Extra penalty for corrections while the typed letters still start real words: the
        /// user is probably mid-word, so "good mor" offers "morning" before "for".
        static let midWordCorrectionPenalty = 25
        /// Bonus for the most common typos: a skipped, swapped or doubled letter (see `TypoModel`).
        static let likelyTypoBonus = 20
        /// Bonus for a letter replaced by a key next to it ("helo" → "help").
        static let neighbouringKeyBonus = 10
        /// Completions scanned per keystroke before the best are picked.
        static let maxCompletionsScanned = 4_000
        /// Shown after the first word of a sentence when nothing better is known.
        static let sentenceStartWords = ["I", "The", "I’m"]
        /// Shown mid-sentence when the previous word has no known continuation.
        static let midSentenceWords = ["and", "the", "to"]
    }

    /// How the keyboard learns from the user (see `UserDictionary`).
    enum Learning {
        /// Added to a word's frequency each time the user types or picks it.
        static let usageWeight = 4
        /// Added to a word pair's frequency each time the user types it.
        static let bigramUsageWeight = 8
        /// Starting frequency of a word the user taught the keyboard (a name, slang, …).
        static let newWordFrequency = 40
        /// Starting frequency of a word pair only the user has typed.
        static let newBigramFrequency = 40
        /// A learned frequency never goes above this, so one word can't push out everything else.
        static let maxFrequency = 150
        /// An unknown word must be typed this many times before it is suggested, so a one-off
        /// typo isn't learned. Picking the typed word from the suggestion bar confirms it at once.
        static let usesToConfirmNewWord = 2
        /// Learned words kept at most; the least used unconfirmed ones are dropped first.
        static let maxWords = 5_000
        /// Learned continuations kept per word.
        static let maxBigramsPerWord = 20
        /// Words longer than this are not learned (pasted links, codes).
        static let maxWordLength = 32
        /// Learned words are saved this long after the last change, so typing doesn't write to disk.
        static let saveDelay: TimeInterval = 2
    }
}
