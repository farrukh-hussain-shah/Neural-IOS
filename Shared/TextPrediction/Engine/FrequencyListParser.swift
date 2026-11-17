import Foundation

/// Reads the downloaded word lists.
///
/// Both files are UTF-8 text, one entry per line, separated by spaces, frequency last:
///
///     frequency_dictionary.txt          bigram_frequency_dictionary.txt
///     hello 70                          good morning 72
///     Aaron 36                          New Zealand 🇳🇿 68
///
/// In the bigram list the first word is the previous word and everything between it and the
/// frequency is what follows it (usually one word, sometimes a short phrase). Lines that don't
/// fit the format are skipped.
enum FrequencyListParser {
    struct WordEntry: Equatable, Sendable {
        let word: String
        let frequency: Int
    }

    struct BigramEntry: Equatable, Sendable {
        let previous: String
        let next: String
        let frequency: Int
    }

    static func words(in text: String) -> [WordEntry] {
        lines(of: text).compactMap { fields in
            guard fields.count == 2, let frequency = Int(fields[1]) else { return nil }
            return WordEntry(word: String(fields[0]), frequency: frequency)
        }
    }

    static func bigrams(in text: String) -> [BigramEntry] {
        lines(of: text).compactMap { fields in
            guard fields.count >= 3, let frequency = Int(fields[fields.count - 1]) else { return nil }
            let next = fields[1..<(fields.count - 1)].joined(separator: " ")
            return BigramEntry(previous: String(fields[0]), next: next, frequency: frequency)
        }
    }

    /// Counts valid lines, used to reject a broken download before it replaces a good file.
    static func validLineCount(in text: String, resource: DictionaryResource) -> Int {
        switch resource {
        case .words:
            return words(in: text).count
        case .bigrams:
            return bigrams(in: text).count
        }
    }

    private static func lines(of text: String) -> [[Substring]] {
        text.split(whereSeparator: \.isNewline).map { $0.split(separator: " ") }
    }
}
