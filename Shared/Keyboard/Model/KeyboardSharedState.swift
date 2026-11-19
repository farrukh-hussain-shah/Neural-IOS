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

    private static let selectedTonesKey = "NKSelectedTones"

    /// The AI tones picked in the app (Settings › AI Tone Adjustment), in the shared container
    /// so the keyboard can offer them in Improve.
    static var selectedTones: Set<AITone> {
        get {
            sharedDefaults?.stringArray(forKey: selectedTonesKey)
                .map { Set($0.compactMap(AITone.init(rawValue:))) } ?? AITone.defaultSelection
        }
        set {
            sharedDefaults?.set(newValue.map(\.rawValue).sorted(), forKey: selectedTonesKey)
        }
    }

    static func recordFullAccess(_ hasFullAccess: Bool) {
        guard hasFullAccess else { return }
        sharedDefaults?.set(true, forKey: fullAccessKey)
    }
}
