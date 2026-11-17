import Foundation

/// Spelling correction with the Symmetric Delete algorithm (SymSpell, by Wolf Garbe), the same
/// technique the Android keyboard uses.
///
/// How it works:
/// 1. When built, every dictionary word is reduced to all the strings you get by deleting up to
///    `maxEditDistance` letters from it ("hello" → "hllo", "helo", "hell", "hlo", …).
/// 2. To correct a typed word, the same deletes are made from it. Any dictionary word that shares
///    a delete with the typed word is a candidate ("helo" and "hello" both reduce to "helo").
/// 3. Each candidate's real edit distance is checked, and those within the limit are returned.
///
/// Only deletes are generated (never inserts or replacements), so the index stays small and a
/// lookup is a handful of binary searches instead of a scan of the whole dictionary.
///
/// Memory: rather than storing the delete strings, each delete is stored as a 32-bit hash packed
/// with the word's index into one sorted `[UInt64]` (about 7 MB for 32,000 words), which fits the
/// keyboard extension's tight memory limit. A hash collision only adds a candidate, which the
/// edit-distance check then rejects, so results stay exact.
struct SymSpellIndex: Sendable {
    struct Match: Equatable, Sendable {
        /// Position of the word in the list the index was built from.
        let wordIndex: Int
        let distance: Int
    }

    let maxEditDistance: Int
    let prefixLength: Int
    private let words: [[UInt32]]
    private let entries: [UInt64]

    /// - Parameter words: lowercase keys (see `WordNormalizer.key(for:)`); a `Match`'s
    ///   `wordIndex` is a position in this array.
    init(
        words: [String],
        maxEditDistance: Int = TextPredictionConfiguration.Correction.maxEditDistance,
        prefixLength: Int = TextPredictionConfiguration.Correction.prefixLength
    ) {
        self.maxEditDistance = maxEditDistance
        self.prefixLength = prefixLength
        self.words = words.map(WordNormalizer.scalars(of:))

        var entries: [UInt64] = []
        entries.reserveCapacity(words.count * 24)
        var deletes = Set<UInt32>()
        for (index, word) in self.words.enumerated() {
            deletes.removeAll(keepingCapacity: true)
            Self.collectDeletes(of: Array(word.prefix(prefixLength)), maxDistance: maxEditDistance, into: &deletes)
            for hash in deletes {
                entries.append(Self.pack(hash: hash, wordIndex: index))
            }
        }
        entries.sort()
        self.entries = entries
    }

    /// Dictionary words within `maxDistance` edits of `term` (a lowercase key), closest first.
    func lookup(_ term: String, maxDistance requested: Int) -> [Match] {
        let input = WordNormalizer.scalars(of: term)
        let maxDistance = min(requested, maxEditDistance)
        guard !input.isEmpty, maxDistance >= 0 else { return [] }

        let inputPrefix = Array(input.prefix(prefixLength))
        var matches: [Match] = []
        var checkedWords = Set<Int>()
        var checkedDeletes: Set<UInt32> = [Self.hash(inputPrefix)]
        var queue = [inputPrefix]
        var next = 0

        // Breadth first: the typed prefix, then everything one letter shorter, and so on.
        while next < queue.count {
            let candidate = queue[next]
            next += 1
            let deletedLetters = inputPrefix.count - candidate.count
            if deletedLetters > maxDistance {
                break
            }

            for wordIndex in wordIndices(sharing: Self.hash(candidate)) where checkedWords.insert(wordIndex).inserted {
                let word = words[wordIndex]
                if let distance = EditDistance.damerauLevenshtein(input, word, maxDistance: maxDistance) {
                    matches.append(Match(wordIndex: wordIndex, distance: distance))
                }
            }

            if deletedLetters < maxDistance, !candidate.isEmpty {
                for position in candidate.indices {
                    var shorter = candidate
                    shorter.remove(at: position)
                    if checkedDeletes.insert(Self.hash(shorter)).inserted {
                        queue.append(shorter)
                    }
                }
            }
        }
        return matches.sorted { $0.distance < $1.distance }
    }

    /// Indices of every word that has a delete with this hash.
    private func wordIndices(sharing hash: UInt32) -> [Int] {
        let lowest = Self.pack(hash: hash, wordIndex: 0)
        var low = 0
        var high = entries.count
        while low < high {
            let middle = (low + high) / 2
            if entries[middle] < lowest {
                low = middle + 1
            } else {
                high = middle
            }
        }
        var result: [Int] = []
        var position = low
        while position < entries.count, UInt32(truncatingIfNeeded: entries[position] >> 32) == hash {
            result.append(Int(UInt32(truncatingIfNeeded: entries[position])))
            position += 1
        }
        return result
    }

    /// Adds the hash of `word` and of every string made by deleting up to `maxDistance` letters.
    private static func collectDeletes(of word: [UInt32], maxDistance: Int, into hashes: inout Set<UInt32>) {
        hashes.insert(hash(word))
        var level = [word]
        for _ in 0..<maxDistance {
            var shorter: [[UInt32]] = []
            for candidate in level where !candidate.isEmpty {
                for position in candidate.indices {
                    var delete = candidate
                    delete.remove(at: position)
                    if hashes.insert(hash(delete)).inserted {
                        shorter.append(delete)
                    }
                }
            }
            level = shorter
        }
    }

    /// FNV-1a over the letters.
    private static func hash(_ letters: [UInt32]) -> UInt32 {
        var hash: UInt32 = 2_166_136_261
        for letter in letters {
            hash = (hash ^ letter) &* 16_777_619
        }
        return hash
    }

    private static func pack(hash: UInt32, wordIndex: Int) -> UInt64 {
        UInt64(hash) << 32 | UInt64(UInt32(wordIndex))
    }
}
