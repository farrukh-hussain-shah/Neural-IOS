#if DEBUG
import Foundation

enum LaunchOverrides {
    private static let frozenSplashProgressKey = "NKSplashFrozenProgress"
    private static let initialRouteKey = "NKInitialRoute"

    static var frozenSplashProgress: Double? {
        UserDefaults.standard.string(forKey: frozenSplashProgressKey).flatMap(Double.init)
    }

    static var initialRoute: AppRoute? {
        switch UserDefaults.standard.string(forKey: initialRouteKey) ?? "" {
        case "onboarding": AppRoute.onboarding(.first)
        case "home": AppRoute.home
        default: nil
        }
    }
}
#endif
