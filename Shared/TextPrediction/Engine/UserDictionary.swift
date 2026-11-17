import Foundation

/// What the keyboard has learned from the user, saved on the device.
///
/// - Every word the user types or picks gets a use count, which raises it in future suggestions.
/// - Words that aren't in the downloaded list (names, slang, …) are learned too. Such a word is
///   suggested once it is *confirmed*: typed `usesToConfirmNewWord` times, or picked from the
///   suggestion bar. This keeps one-off typos out of the suggestions.
/// - Word pairs ("see" → "you") are counted, which raises the second word in next-word
///   predictions after the first.
///
/// A plain value type: the engine changes it on the main thread and hands a copy to a
/// background task to save, so saving never blocks typing.
struct UserDictionary: Codable, Equatable, Sendable {
    struct LearnedWord: Codable, Equatable, Sendable {
        /// How the word is written ("Farrukh").
        var display: String
        var uses: Int
        /// True once the word may be suggested and used as a correction.
        var isConfirmed: Bool
        var lastUsed: Date
    }

    static let currentVersion = 1

    private(set) var version = UserDictionary.currentVersion
    /// Learned words by key (see `WordNormalizer`).
    private(set) var words: [String: LearnedWord] = [:]
    /// How often each word followed each previous word: previous key → next key → uses.
    private(set) var bigrams: [String: [String: Int]] = [:]

    init() {}

    func learnedWord(forKey key: String) -> LearnedWord? {
        words[key]
    }

    func uses(ofKey key: String) -> Int {
        words[key]?.uses ?? 0
    }

    func bigramUses(after previousKey: String, key: String) -> Int {
        bigrams[previousKey]?[key] ?? 0
    }

    /// Learned words that may be suggested.
    var confirmedWords: [(key: String, word: LearnedWord)] {
        words.filter { $0.value.isConfirmed }.map { ($0.key, $0.value) }
    }

    /// Learned continuations of `previousKey`, most used first.
    func continuations(after previousKey: String) -> [(key: String, uses: Int)] {
        (bigrams[previousKey] ?? [:])
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .map { ($0.key, $0.value) }
    }

    /// Records one use of `word`.
    /// - Parameters:
    ///   - isKnownWord: whether the word is in the downloaded list; known words are always usable.
    ///   - previousWord: the word before it in the same sentence, to learn the pair.
    ///   - isSentenceStart: a capital at the start of a sentence says nothing about how the word
    ///     is normally written, so it doesn't change the learned spelling.
    mutating func record(
        _ word: String,
        isKnownWord: Bool,
        previousWord: String?,
        isSentenceStart: Bool,
        source: LearningSource,
        now: Date = Date()
    ) {
        let key = WordNormalizer.key(for: word)
        var entry = words[key] ?? LearnedWord(
            display: isSentenceStart ? key : word,
            uses: 0,
            isConfirmed: false,
            lastUsed: now
        )
        if !isSentenceStart {
            entry.display = word
        }
        entry.uses += 1
        entry.lastUsed = now
        entry.isConfirmed = entry.isConfirmed
            || isKnownWord
            || source != .typed
            || entry.uses >= TextPredictionConfiguration.Learning.usesToConfirmNewWord
        words[key] = entry

        if let previousWord {
            let previousKey = WordNormalizer.key(for: previousWord)
            bigrams[previousKey, default: [:]][key, default: 0] += 1
            trimContinuations(of: previousKey)
        }
        trimWordsIfNeeded()
    }

    /// Keeps the word list within `maxWords`, dropping unconfirmed words first, then the least
    /// used and longest unused.
    private mutating func trimWordsIfNeeded() {
        let limit = TextPredictionConfiguration.Learning.maxWords
        guard words.count > limit else { return }
        let removable = words
            .sorted { lhs, rhs in
                if lhs.value.isConfirmed != rhs.value.isConfirmed {
                    return !lhs.value.isConfirmed
                }
                if lhs.value.uses != rhs.value.uses {
                    return lhs.value.uses < rhs.value.uses
                }
                return lhs.value.lastUsed < rhs.value.lastUsed
            }
            .prefix(words.count - limit)
        for (key, _) in removable {
            words[key] = nil
            bigrams[key] = nil
        }
    }

    private mutating func trimContinuations(of previousKey: String) {
        guard let continuations = bigrams[previousKey],
              continuations.count > TextPredictionConfiguration.Learning.maxBigramsPerWord else { return }
        let kept = continuations
            .sorted { $0.value > $1.value }
            .prefix(TextPredictionConfiguration.Learning.maxBigramsPerWord)
        bigrams[previousKey] = Dictionary(uniqueKeysWithValues: kept.map { ($0.key, $0.value) })
    }
}

extension UserDictionary {
    /// Reads a saved dictionary; an empty one if the file is missing or from an unknown version.
    static func load(from url: URL) -> UserDictionary {
        guard let data = try? Data(contentsOf: url),
              let dictionary = try? JSONDecoder().decode(UserDictionary.self, from: data),
              dictionary.version == currentVersion else {
            return UserDictionary()
        }
        return dictionary
    }

    func save(to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(self).write(to: url, options: .atomic)
    }
}
