import Foundation

/// What prediction needs to know about the text before the cursor.
///
///     "I love coff|"   → currentWord "coff", previousWord "love", isSentenceStart false
///     "Thanks. |"      → currentWord "",     previousWord nil,    isSentenceStart true
struct TextContext: Equatable, Sendable {
    /// The partly typed word touching the cursor (empty right after a space).
    let currentWord: String
    /// The word before `currentWord`, when only spaces separate them. Punctuation in between
    /// ends the context, since "Thanks." says little about the next word.
    let previousWord: String?
    /// Whether `currentWord` is the first word of a sentence (or of the text).
    let isSentenceStart: Bool

    init(textBeforeCursor text: String) {
        let current = Self.trailingWord(in: Substring(text))
        let beforeCurrent = text.dropLast(current.count)
        let beforeSpaces = beforeCurrent.trimmingTrailing { $0 == " " }

        currentWord = String(current)
        isSentenceStart = beforeSpaces.isEmpty || beforeSpaces.last.map(Self.endsSentence) == true

        let hasSpaceBefore = beforeSpaces.count < beforeCurrent.count
        let previous = Self.trailingWord(in: beforeSpaces)
        previousWord = hasSpaceBefore && !previous.isEmpty ? String(previous) : nil
    }

    init(currentWord: String, previousWord: String?, isSentenceStart: Bool) {
        self.currentWord = currentWord
        self.previousWord = previousWord
        self.isSentenceStart = isSentenceStart
    }

    static func currentWord(in text: String) -> String {
        String(trailingWord(in: Substring(text)))
    }

    private static func trailingWord(in text: Substring) -> Substring {
        let start = text.lastIndex { !WordNormalizer.isWordCharacter($0) }.map(text.index(after:)) ?? text.startIndex
        return text[start...]
    }

    private static func endsSentence(_ character: Character) -> Bool {
        character == "." || character == "!" || character == "?" || character.isNewline
    }
}

private extension Substring {
    func trimmingTrailing(while predicate: (Character) -> Bool) -> Substring {
        var end = endIndex
        while end > startIndex, predicate(self[index(before: end)]) {
            end = index(before: end)
        }
        return self[startIndex..<end]
    }
}
