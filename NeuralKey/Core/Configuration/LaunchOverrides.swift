#if DEBUG
import Foundation

enum LaunchOverrides {
    private static let frozenSplashProgressKey = "NKSplashFrozenProgress"
    private static let initialRouteKey = "NKInitialRoute"
    private static let resetPreferencesKey = "NKResetPreferences"

    static var shouldResetPreferences: Bool {
        UserDefaults.standard.bool(forKey: resetPreferencesKey)
    }

    static var frozenSplashProgress: Double? {
        UserDefaults.standard.string(forKey: frozenSplashProgressKey).flatMap(Double.init)
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
