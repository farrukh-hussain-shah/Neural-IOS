import Foundation

enum KeyboardSetupState: Equatable {
    case notAdded
    case added
    case fullAccess
}

enum KeyboardSetupStatus {
    private static let enabledKeyboardsKey = "AppleKeyboards"

    static var current: KeyboardSetupState {
        let enabledKeyboards = UserDefaults.standard.stringArray(forKey: enabledKeyboardsKey) ?? []
        guard enabledKeyboards.contains(KeyboardSharedState.extensionBundleIdentifier) else {
            return .notAdded
        }
        return KeyboardSharedState.reportedFullAccess ? .fullAccess : .added
    }
}
