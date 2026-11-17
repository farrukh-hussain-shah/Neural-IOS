import Foundation

/// One slot of the suggestion bar.
struct KeyboardSuggestion: Identifiable, Equatable {
    enum Kind: Equatable {
        /// Exactly what was typed, shown in quotes; picking it keeps (and teaches) the word.
        case verbatim
        /// A longer word starting with what was typed.
        case completion
        /// A likely spelling of what was typed.
        case correction
        /// The likely next word after a space.
        case nextWord
    }

    let id: Int
    let text: String
    let kind: Kind

    var displayText: String {
        kind == .verbatim ? "“\(text)”" : text
    }
}

/// Fills the suggestion bar from the text before the cursor, using `PredictionService`.
///
/// While typing a word: the word itself in quotes, then the two best completions or corrections.
/// After a space: the three most likely next words.
@MainActor
enum SuggestionProvider {
    static let slotCount = 3

    static func suggestions(
        forTextBeforeCursor text: String,
        service: PredictionService = .shared
    ) -> [KeyboardSuggestion] {
        let context = TextContext(textBeforeCursor: text)
        guard !context.currentWord.isEmpty else {
            return service.predictions(for: context, limit: slotCount)
                .enumerated()
                .map { KeyboardSuggestion(id: $0, text: $1.text, kind: Kind($1.kind)) }
        }

        var result = [KeyboardSuggestion(id: 0, text: context.currentWord, kind: .verbatim)]
        result += service.predictions(for: context, limit: slotCount - 1)
            .enumerated()
            .map { KeyboardSuggestion(id: $0 + 1, text: $1.text, kind: Kind($1.kind)) }
        return result
    }

    static func currentWord(in text: String) -> String {
        TextContext.currentWord(in: text)
    }

    private typealias Kind = KeyboardSuggestion.Kind
}

private extension KeyboardSuggestion.Kind {
    init(_ kind: Prediction.Kind) {
        switch kind {
        case .completion:
            self = .completion
        case .correction:
            self = .correction
        case .nextWord:
            self = .nextWord
        }
    }
}
