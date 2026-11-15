import Foundation

struct KeyboardConfiguration: Equatable {
    enum KeyboardType: String {
        case text
        case phonePad
    }

    enum ReturnKey: String {
        case `return`
        case go
    }

    var type: KeyboardType = .text
    var returnKey: ReturnKey = .return
    var showsSuggestions = true
    var showsSystemRow = true
    var autoCapitalizes = true
    var playsHaptics = false
    var previewKeyID: String?

    static let standard = KeyboardConfiguration()
}
