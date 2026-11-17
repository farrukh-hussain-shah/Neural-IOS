import Foundation

/// Turns what the user is typing into suggestions, and learns from what they type and pick.
///
/// While a word is being typed, candidates come from:
/// - completions: downloaded and learned words that start with the typed letters
/// - corrections: SymSpell matches within 1–2 edits, only when the typed word isn't a real word
///
/// After a space, candidates are next words: bigram continuations of the previous word,
/// downloaded and learned.
///
/// Every candidate gets a score — its frequency, plus a bonus when it often follows the previous
/// word, minus a penalty per edit for corrections — and the best are returned. What the user
/// types and picks raises those frequencies (see `UserDictionary`).
///
/// Works before the word lists are downloaded too: it then offers only what the user has taught
/// it, plus a few common sentence starters.
///
/// Not thread-safe: use one engine from one thread (`PredictionService` keeps it on the main actor).
final class TextPredictionEngine {
    private typealias Ranking = TextPredictionConfiguration.Ranking
    private typealias Correction = TextPredictionConfiguration.Correction
    private typealias Learning = TextPredictionConfiguration.Learning

    /// The downloaded vocabulary; nil until the word lists are downloaded and loaded.
    var lexicon: Lexicon?
    private(set) var userDictionary: UserDictionary

    init(lexicon: Lexicon? = nil, userDictionary: UserDictionary = UserDictionary()) {
        self.lexicon = lexicon
        self.userDictionary = userDictionary
    }

    /// The best suggestions for the text around the cursor, best first.
    func predictions(for context: TextContext, limit: Int) -> [Prediction] {
        guard limit > 0 else { return [] }
        if context.currentWord.isEmpty {
            return nextWords(for: context, limit: limit)
        }
        return wordSuggestions(for: context, limit: limit)
    }

    /// Learns from a finished word: raises its frequency, remembers it if it's new, and counts it
    /// as following the previous word.
    func learn(_ word: String, context: TextContext, source: LearningSource) {
        guard WordNormalizer.isLearnable(word) else { return }
        let key = WordNormalizer.key(for: word)
        userDictionary.record(
            word,
            isKnownWord: lexicon?.contains(key) == true,
            previousWord: context.previousWord.flatMap { WordNormalizer.isLearnable($0) ? $0 : nil },
            isSentenceStart: context.isSentenceStart,
            source: source
        )
    }

    /// Whether `key` is a real word: in the downloaded list, or learned and confirmed.
    func isKnownWord(_ key: String) -> Bool {
        lexicon?.contains(key) == true || userDictionary.learnedWord(forKey: key)?.isConfirmed == true
    }

    /// The frequency used for ranking: the downloaded frequency (or `newWordFrequency` for a
    /// learned word), raised by how often the user has used it. Nil for words that may not be
    /// suggested.
    func frequency(ofKey key: String) -> Int? {
        let base: Int
        if let word = lexicon?.word(forKey: key) {
            base = word.frequency
        } else if userDictionary.learnedWord(forKey: key)?.isConfirmed == true {
            base = Learning.newWordFrequency
        } else {
            return nil
        }
        return Self.boost(base, uses: userDictionary.uses(ofKey: key), weight: Learning.usageWeight)
    }

    // MARK: - While typing a word

    private struct Candidate {
        let key: String
        let kind: Prediction.Kind
        let score: Int
    }

    private func wordSuggestions(for context: TextContext, limit: Int) -> [Prediction] {
        let typed = context.currentWord
        let typedKey = WordNormalizer.key(for: typed)
        let previousKey = context.previousWord.map { WordNormalizer.key(for: $0) }
        var best: [String: Candidate] = [:]

        func offer(_ key: String, kind: Prediction.Kind, scoreAdjustment: Int = 0) {
            guard key != typedKey, let frequency = frequency(ofKey: key) else { return }
            let score = frequency + contextBonus(after: previousKey, key: key) + scoreAdjustment
            if let existing = best[key], existing.score >= score {
                return
            }
            best[key] = Candidate(key: key, kind: kind, score: score)
        }

        for word in lexicon?.words(withPrefix: typedKey, limit: Ranking.maxCompletionsScanned) ?? [] {
            offer(word.key, kind: .completion)
        }
        for (key, _) in userDictionary.confirmedWords where key.hasPrefix(typedKey) {
            offer(key, kind: .completion)
        }
        let isMidWord = !best.isEmpty

        if typedKey.count >= Correction.minimumWordLength, !isKnownWord(typedKey) {
            let typedLetters = WordNormalizer.scalars(of: typedKey)
            for (key, distance) in corrections(for: typedKey) {
                let letters = WordNormalizer.scalars(of: key)
                let typo = distance == 1 ? TypoModel.kind(typed: typedLetters, correction: letters) : .other
                var penalty = distance * Ranking.penaltyPerEdit - TypoModel.bonus(for: typo)
                if letters.count < typedLetters.count, typo != .doubledLetter {
                    penalty += Ranking.shorterCorrectionPenalty
                }
                if isMidWord {
                    penalty += Ranking.midWordCorrectionPenalty
                }
                offer(key, kind: .correction, scoreAdjustment: -penalty)
            }
        }

        return best.values
            .sorted { $0.score != $1.score ? $0.score > $1.score : $0.key < $1.key }
            .prefix(limit)
            .map { Prediction(text: WordNormalizer.applyCasing(of: typed, to: display(forKey: $0.key)), kind: $0.kind) }
    }

    /// Downloaded and learned words within the allowed number of edits of `typedKey`.
    private func corrections(for typedKey: String) -> [(key: String, distance: Int)] {
        let maxDistance = typedKey.count <= Correction.singleEditMaxLength ? 1 : Correction.maxEditDistance
        var result = (lexicon?.corrections(for: typedKey, maxDistance: maxDistance) ?? [])
            .map { (key: $0.word.key, distance: $0.distance) }

        let typedLetters = WordNormalizer.scalars(of: typedKey)
        for (key, _) in userDictionary.confirmedWords where lexicon?.contains(key) != true {
            let letters = WordNormalizer.scalars(of: key)
            if let distance = EditDistance.damerauLevenshtein(typedLetters, letters, maxDistance: maxDistance) {
                result.append((key: key, distance: distance))
            }
        }
        return result
    }

    // MARK: - After a space

    private func nextWords(for context: TextContext, limit: Int) -> [Prediction] {
        var scores: [String: Int] = [:]
        var displays: [String: String] = [:]

        if let previous = context.previousWord {
            let previousKey = WordNormalizer.key(for: previous)
            for continuation in lexicon?.continuations(after: previousKey) ?? [] {
                scores[continuation.key] = contextBonus(after: previousKey, key: continuation.key)
                displays[continuation.key] = continuation.display
            }
            for (key, _) in userDictionary.continuations(after: previousKey) where scores[key] == nil && isKnownWord(key) {
                scores[key] = contextBonus(after: previousKey, key: key)
                displays[key] = display(forKey: key)
            }
        }

        var texts = scores
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .prefix(limit)
            .compactMap { displays[$0.key] }

        let fallback = context.isSentenceStart ? Ranking.sentenceStartWords : Ranking.midSentenceWords
        for word in fallback where texts.count < limit {
            let key = WordNormalizer.key(for: word)
            if !texts.contains(where: { WordNormalizer.key(for: $0) == key }) {
                texts.append(word)
            }
        }

        return texts.map { text in
            Prediction(
                text: context.isSentenceStart ? WordNormalizer.capitalizingFirstLetter(text) : text,
                kind: .nextWord
            )
        }
    }

    // MARK: - Scoring helpers

    /// Extra score for a word that often follows `previousKey`: the downloaded pair frequency
    /// (or `newBigramFrequency` for a pair only the user has typed), raised by the user's uses.
    private func contextBonus(after previousKey: String?, key: String) -> Int {
        guard let previousKey else { return 0 }
        let downloaded = lexicon?.continuation(after: previousKey, key: key)?.frequency
        let uses = userDictionary.bigramUses(after: previousKey, key: key)
        guard downloaded != nil || uses > 0 else { return 0 }
        return Self.boost(downloaded ?? Learning.newBigramFrequency, uses: uses, weight: Learning.bigramUsageWeight)
    }

    /// How a word is written: the downloaded spelling ("Aaron"), else as the user wrote it.
    private func display(forKey key: String) -> String {
        lexicon?.word(forKey: key)?.display ?? userDictionary.learnedWord(forKey: key)?.display ?? key
    }

    private static func boost(_ base: Int, uses: Int, weight: Int) -> Int {
        min(base + uses * weight, max(base, Learning.maxFrequency))
    }
}
