import Foundation
import Observation

@MainActor
@Observable
final class SettingsStore {
    private enum Key {
        static let hapticFeedback = "NKHapticFeedback"
        static let keyboardAppearance = "NKKeyboardAppearance"
        static let selectedTones = "NKSelectedTones"

        static let all = [hapticFeedback, keyboardAppearance, selectedTones]
    }

    private(set) var isHapticFeedbackEnabled: Bool
    private(set) var keyboardAppearance: KeyboardAppearance
    private(set) var selectedTones: Set<AITone>

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        #if DEBUG
        if LaunchOverrides.shouldResetPreferences {
            Key.all.forEach(defaults.removeObject(forKey:))
        }
        #endif
        isHapticFeedbackEnabled = defaults.bool(forKey: Key.hapticFeedback)
        keyboardAppearance = defaults.string(forKey: Key.keyboardAppearance)
            .flatMap(KeyboardAppearance.init(rawValue:)) ?? .defaultAppearance
        selectedTones = defaults.stringArray(forKey: Key.selectedTones)
            .map { Set($0.compactMap(AITone.init(rawValue:))) } ?? AITone.defaultSelection
        KeyboardSharedState.selectedTones = selectedTones
    }

    var primaryTone: AITone? {
        let professional = AIToneCategory.professional.tones.first(where: selectedTones.contains)
        return professional ?? AITone.allCases.first(where: selectedTones.contains)
    }

    func setHapticFeedback(_ isEnabled: Bool) {
        isHapticFeedbackEnabled = isEnabled
        defaults.set(isEnabled, forKey: Key.hapticFeedback)
    }

    func setKeyboardAppearance(_ appearance: KeyboardAppearance) {
        keyboardAppearance = appearance
        defaults.set(appearance.rawValue, forKey: Key.keyboardAppearance)
    }

    func setSelectedTones(_ tones: Set<AITone>) {
        selectedTones = tones
        defaults.set(tones.map(\.rawValue).sorted(), forKey: Key.selectedTones)
        KeyboardSharedState.selectedTones = tones
    }
}
