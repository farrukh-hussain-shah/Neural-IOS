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

    init(initialRoute: AppRoute = .splash) {
        route = initialRoute
    }

    func completeSplash() {
        route = .languageSelection
    }

    func completeLanguageSelection() {
        route = .onboarding(.first)
    }

    func continueOnboarding() {
        guard case .onboarding(let step) = route else { return }
        route = step.next.map(AppRoute.onboarding) ?? .home
    }

    func presentPremium() {
        isPremiumPresented = true
    }

    func dismissPremium() {
        isPremiumPresented = false
    }
}
