import Foundation

/// One suggestion produced by `TextPredictionEngine`.
struct Prediction: Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        /// A likely spelling of the word being typed ("helo" → "hello").
        case correction
        /// A longer word starting with what was typed ("hel" → "hello").
        case completion
        /// The likely next word after a space ("good " → "morning").
        case nextWord
    }

    let text: String
    let kind: Kind
}

/// How a word reached the text, which decides how much the keyboard trusts it when learning.
enum LearningSource: Sendable {
    /// Typed letter by letter and ended with a space, return or punctuation.
    case typed
    /// Picked from the suggestion bar (a completion, correction or next word).
    case selectedSuggestion
    /// The quoted, exactly-as-typed suggestion was picked: the user says this word is right,
    /// so a new word is learned at once instead of after `usesToConfirmNewWord` uses.
    case keptTypedWord
}
