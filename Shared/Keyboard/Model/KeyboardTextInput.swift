import Foundation

@MainActor
protocol KeyboardTextInput: AnyObject {
    var textBeforeCursor: String { get }
    var hasText: Bool { get }

    func insertText(_ text: String)
    func deleteBackward()
    func performReturn()
}
