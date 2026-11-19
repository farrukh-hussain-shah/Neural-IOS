#if DEBUG
import UIKit

enum LaunchOverrides {
    private static let frozenSplashProgressKey = "NKSplashFrozenProgress"
    private static let initialRouteKey = "NKInitialRoute"
    private static let resetPreferencesKey = "NKResetPreferences"

    static var skipsKeyboardSetup: Bool {
        UserDefaults.standard.bool(forKey: "NKSkipKeyboardSetup")
    }

    /// Keeps the Home headline on its first phrase, for stable screenshots.
    static var freezesHomeHeadline: Bool {
        UserDefaults.standard.bool(forKey: "NKFreezeHomeHeadline")
    }

    static var usesSystemKeyboard: Bool {
        UserDefaults.standard.bool(forKey: "NKUseSystemKeyboard")
    }

    static var systemKeyboardAppearance: UIKeyboardAppearance {
        UserDefaults.standard.string(forKey: "NKSystemKeyboardAppearance") == "light" ? .light : .dark
    }

    static var systemKeyboardAutocapitalization: UITextAutocapitalizationType {
        UserDefaults.standard.string(forKey: "NKSystemKeyboardAutocapitalization") == "none" ? .none : .sentences
    }

    static var shouldResetPreferences: Bool {
        UserDefaults.standard.bool(forKey: resetPreferencesKey)
    }

    static var frozenSplashProgress: Double? {
        UserDefaults.standard.string(forKey: frozenSplashProgressKey).flatMap(Double.init)
    }

    static func keyboardConfiguration(base: KeyboardConfiguration) -> KeyboardConfiguration {
        let defaults = UserDefaults.standard
        var configuration = base
        if let type = defaults.string(forKey: "NKKeyboardType").flatMap(KeyboardConfiguration.KeyboardType.init(rawValue:)) {
            configuration.type = type
        }
        if let returnKey = defaults.string(forKey: "NKKeyboardReturnKey").flatMap(KeyboardConfiguration.ReturnKey.init(rawValue:)) {
            configuration.returnKey = returnKey
        }
        if defaults.object(forKey: "NKKeyboardSuggestions") != nil {
            configuration.showsSuggestions = defaults.bool(forKey: "NKKeyboardSuggestions")
        }
        if defaults.object(forKey: "NKKeyboardSystemRow") != nil {
            configuration.showsSystemRow = defaults.bool(forKey: "NKKeyboardSystemRow")
        }
        if defaults.object(forKey: "NKKeyboardAutoCapitalize") != nil {
            configuration.autoCapitalizes = defaults.bool(forKey: "NKKeyboardAutoCapitalize")
        }
        if defaults.bool(forKey: "NKPreviewRewrites") {
            configuration.usesPreviewRewrites = true
        }
        if let previewKey = defaults.string(forKey: "NKKeyboardPreviewKey") {
            configuration.previewKeyID = "key.\(previewKey)"
        }
        return configuration
    }

    static var initialRoute: AppRoute? {
        switch UserDefaults.standard.string(forKey: initialRouteKey) ?? "" {
        case "language": AppRoute.languageSelection
        case "onboarding": AppRoute.onboarding(.first)
        case "home": AppRoute.home
        default: nil
        }
    }
}
#endif
