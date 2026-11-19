import Foundation

struct KeyboardConfiguration: Equatable {
    enum KeyboardType: String {
        case text
        case phonePad
    }

    enum Placement {
        case inApp
        case systemKeyboard
    }

    enum ReturnKey: String {
        case `return`
        case go
    }

    var type: KeyboardType = .text
    var placement: Placement = .inApp
    var showsGlobeKey = false
    var returnKey: ReturnKey = .return
    var showsSuggestions = true
    var showsSystemRow = true
    var autoCapitalizes = true
    var playsHaptics = false
    var previewKeyID: String?
    /// Improve answers with canned options after a short delay (UI tests; no network or key).
    var usesPreviewRewrites = false

    static let standard = KeyboardConfiguration()

    static func systemKeyboard(showsGlobeKey: Bool) -> KeyboardConfiguration {
        var configuration = KeyboardConfiguration()
        configuration.placement = .systemKeyboard
        configuration.showsSystemRow = false
        configuration.showsGlobeKey = showsGlobeKey
        return configuration
    }
}
