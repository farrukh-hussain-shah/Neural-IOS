import Foundation

/// Remembers which keyboard setup step the user reached, so onboarding can resume
/// after iOS terminates the app (it does that when Full Access is switched on).
enum OnboardingProgress {
    private static let storageKey = "NKOnboardingProgress"

    static func record(_ route: AppRoute, defaults: UserDefaults = .standard) {
        switch route {
        case .onboarding(let step) where step.opensKeyboardSettings:
            defaults.set(step.rawValue, forKey: storageKey)
        case .home:
            defaults.removeObject(forKey: storageKey)
        default:
            break
        }
    }

    /// The route to resume at when a keyboard setup step was in progress.
    static func resumeRoute(defaults: UserDefaults = .standard) -> AppRoute? {
        guard let rawValue = defaults.object(forKey: storageKey) as? Int,
              let step = OnboardingStep(rawValue: rawValue),
              step.opensKeyboardSettings else {
            return nil
        }
        switch (step, KeyboardSetupStatus.current) {
        case (_, .fullAccess), (.allowFullAccess, .added):
            return .home
        case (_, .added):
            return .onboarding(.allowFullAccess)
        case (_, .notAdded):
            return .onboarding(.addKeyboard)
        }
    }
}
