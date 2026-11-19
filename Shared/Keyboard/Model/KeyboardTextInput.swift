import Foundation

@MainActor
protocol KeyboardTextInput: AnyObject {
    var textBeforeCursor: String { get }
    var textAfterCursor: String { get }
    var hasText: Bool { get }

    func insertText(_ text: String)
    func deleteBackward()
    func performReturn()
    /// Replaces the `before` characters before the cursor and the `after` characters after it
    /// with `text` (Improve uses this to put a rewritten option in place of what was typed).
    func replace(charactersBefore before: Int, charactersAfter after: Int, with text: String)
}
