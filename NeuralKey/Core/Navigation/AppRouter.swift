import Observation

enum AppRoute: Equatable {
    case splash
    case languageSelection
    case onboarding(OnboardingStep)
    case home
}

@MainActor
@Observable
final class AppRouter {
    private(set) var route: AppRoute
    var isPremiumPresented = false
    var isSettingsPresented = false

    init(initialRoute: AppRoute = .splash) {
        if case .onboarding = initialRoute, let resumed = OnboardingProgress.resumeRoute() {
            route = resumed
        } else {
            route = initialRoute
        }
    }

    func completeSplash() {
        navigate(to: OnboardingProgress.resumeRoute() ?? .languageSelection)
    }

    func completeLanguageSelection() {
        navigate(to: .onboarding(.first))
    }

    func continueOnboarding() {
        guard case .onboarding(let step) = route else { return }
        navigate(to: step.next.map(AppRoute.onboarding) ?? .home)
    }

    func finishOnboarding() {
        navigate(to: .home)
    }

    private func navigate(to newRoute: AppRoute) {
        route = newRoute
        OnboardingProgress.record(newRoute)
    }

    func presentPremium() {
        isPremiumPresented = true
    }

    func dismissPremium() {
        isPremiumPresented = false
    }

    func presentSettings() {
        isSettingsPresented = true
    }

    func dismissSettings() {
        isSettingsPresented = false
    }
}
