import Foundation

/// Turns words into the lookup keys every prediction table uses, and applies the typed casing
/// back onto suggestions.
///
/// Keys are lowercase with a straight apostrophe, so "Don’t", "don't" and "DON'T" are one word.
enum WordNormalizer {
    static func key(for word: some StringProtocol) -> String {
        word.lowercased().replacingOccurrences(of: "’", with: "'")
    }

    /// The Unicode scalar values of a key, the form SymSpell and the edit distance work on.
    static func scalars(of key: some StringProtocol) -> [UInt32] {
        key.unicodeScalars.map(\.value)
    }

    /// Whether `character` can be part of a word the user is typing.
    static func isWordCharacter(_ character: Character) -> Bool {
        character.isLetter || character == "'" || character == "’"
    }

    /// Whether a word is worth learning: real letters, not a link, number or pasted code.
    static func isLearnable(_ word: String) -> Bool {
        let count = word.count
        guard count >= 2, count <= TextPredictionConfiguration.Learning.maxWordLength else { return false }
        guard word.contains(where: \.isLetter) else { return false }
        return word.allSatisfy { isWordCharacter($0) || $0 == "-" }
    }

    /// Gives `suggestion` the casing the user is typing in: "HEL" → "HELLO", "Hel" → "Hello".
    /// Words that are capitalized in the dictionary (names) keep their capital.
    static func applyCasing(of typed: String, to suggestion: String) -> String {
        if typed.count > 1, typed == typed.uppercased(), typed != typed.lowercased() {
            return suggestion.uppercased()
        }
        if let first = typed.first, first.isUppercase {
            return capitalizingFirstLetter(suggestion)
        }
        return suggestion
    }

    static func capitalizingFirstLetter(_ word: String) -> String {
        guard let first = word.first else { return word }
        return first.uppercased() + word.dropFirst()
    }
}
