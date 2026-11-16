import Foundation

enum KeyboardSharedState {
    static let appGroupIdentifier = "group.com.neuralkey.app"
    static let extensionBundleIdentifier = "com.neuralkey.app.keyboard"

    private static let fullAccessKey = "NKKeyboardHasFullAccess"

    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    static var reportedFullAccess: Bool {
        sharedDefaults?.bool(forKey: fullAccessKey) ?? false
    }

    static func recordFullAccess(_ hasFullAccess: Bool) {
        guard hasFullAccess else { return }
        sharedDefaults?.set(true, forKey: fullAccessKey)
    }
}
