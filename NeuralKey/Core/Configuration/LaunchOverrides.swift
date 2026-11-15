#if DEBUG
import Foundation

enum LaunchOverrides {
    private static let frozenSplashProgressKey = "NKSplashFrozenProgress"

    static var frozenSplashProgress: Double? {
        UserDefaults.standard.string(forKey: frozenSplashProgressKey).flatMap(Double.init)
    }
}
#endif
