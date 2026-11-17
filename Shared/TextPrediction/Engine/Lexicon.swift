import Foundation

/// The downloaded vocabulary, indexed for the three lookups prediction makes:
/// spelling corrections (SymSpell), completions (by prefix) and next words (bigrams).
///
/// A `Lexicon` never changes once built, so it is built off the main thread (building takes
/// a fraction of a second) and then read from anywhere. What the user teaches the keyboard is
/// kept separately in `UserDictionary`.
final class Lexicon: Sendable {
    struct Word: Equatable, Sendable {
        /// Lowercase lookup key (see `WordNormalizer`).
        let key: String
        /// How the word is written when suggested: lowercase for ordinary words, capitalized
        /// for names ("Aaron").
        let display: String
        let frequency: Int
    }

    /// A word (or short phrase) that follows another, with how often it does.
    struct Continuation: Equatable, Sendable {
        let key: String
        let display: String
        let frequency: Int
    }

    /// Every word, sorted by key so that words sharing a prefix sit next to each other.
    private let words: [Word]
    private let indexByKey: [String: Int]
    private let spelling: SymSpellIndex
    /// Continuations of each previous-word key, most frequent first.
    private let continuationsByKey: [String: [Continuation]]

    init(words entries: [FrequencyListParser.WordEntry], bigrams: [FrequencyListParser.BigramEntry]) {
        let words = Self.mergeCaseVariants(entries)
        self.words = words
        indexByKey = Dictionary(words.enumerated().map { ($1.key, $0) }, uniquingKeysWith: { first, _ in first })
        spelling = SymSpellIndex(words: words.map(\.key))
        continuationsByKey = Self.groupContinuations(bigrams)
    }

    /// Builds the lexicon from the two downloaded files.
    static func load(wordsFile: URL, bigramsFile: URL) throws -> Lexicon {
        let wordsText = try String(contentsOf: wordsFile, encoding: .utf8)
        let bigramsText = (try? String(contentsOf: bigramsFile, encoding: .utf8)) ?? ""
        return Lexicon(
            words: FrequencyListParser.words(in: wordsText),
            bigrams: FrequencyListParser.bigrams(in: bigramsText)
        )
    }

    var wordCount: Int {
        words.count
    }

    func word(forKey key: String) -> Word? {
        indexByKey[key].map { words[$0] }
    }

    func contains(_ key: String) -> Bool {
        indexByKey[key] != nil
    }

    /// Words starting with `prefix` (a key), in alphabetical order, at most `limit` of them.
    func words(withPrefix prefix: String, limit: Int) -> ArraySlice<Word> {
        var low = 0
        var high = words.count
        while low < high {
            let middle = (low + high) / 2
            if words[middle].key < prefix {
                low = middle + 1
            } else {
                high = middle
            }
        }
        var end = low
        while end < words.count, end - low < limit, words[end].key.hasPrefix(prefix) {
            end += 1
        }
        return words[low..<end]
    }

    /// Dictionary words within `maxDistance` edits of `key`, closest first.
    func corrections(for key: String, maxDistance: Int) -> [(word: Word, distance: Int)] {
        spelling.lookup(key, maxDistance: maxDistance).map { (words[$0.wordIndex], $0.distance) }
    }

    func continuations(after previousKey: String) -> [Continuation] {
        continuationsByKey[previousKey] ?? []
    }

    func continuation(after previousKey: String, key: String) -> Continuation? {
        continuationsByKey[previousKey]?.first { $0.key == key }
    }

    /// The word list has some words in several casings ("air 58", "Air 71"). They become one
    /// word with the highest frequency, written in lowercase when a lowercase form exists.
    private static func mergeCaseVariants(_ entries: [FrequencyListParser.WordEntry]) -> [Word] {
        var merged: [String: Word] = [:]
        for entry in entries {
            let key = WordNormalizer.key(for: entry.word)
            guard let existing = merged[key] else {
                merged[key] = Word(key: key, display: entry.word, frequency: entry.frequency)
                continue
            }
            let existingIsLowercase = existing.display == existing.display.lowercased()
            let entryIsLowercase = entry.word == entry.word.lowercased()
            let prefersEntry = entryIsLowercase != existingIsLowercase
                ? entryIsLowercase
                : entry.frequency > existing.frequency
            merged[key] = Word(
                key: key,
                display: prefersEntry ? entry.word : existing.display,
                frequency: max(existing.frequency, entry.frequency)
            )
        }
        return merged.values.sorted { $0.key < $1.key }
    }

    private static func groupContinuations(_ entries: [FrequencyListParser.BigramEntry]) -> [String: [Continuation]] {
        var grouped: [String: [String: Continuation]] = [:]
        for entry in entries {
            let previousKey = WordNormalizer.key(for: entry.previous)
            let key = WordNormalizer.key(for: entry.next)
            if let existing = grouped[previousKey]?[key], existing.frequency >= entry.frequency {
                continue
            }
            grouped[previousKey, default: [:]][key] = Continuation(key: key, display: entry.next, frequency: entry.frequency)
        }
        return grouped.mapValues { continuations in
            continuations.values.sorted { $0.frequency != $1.frequency ? $0.frequency > $1.frequency : $0.key < $1.key }
        }
    }
}
