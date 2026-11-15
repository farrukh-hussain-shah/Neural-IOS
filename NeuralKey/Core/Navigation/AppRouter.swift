import Observation

enum AppRoute: Equatable {
    case splash
    case onboarding(OnboardingStep)
    case home
}

@MainActor
@Observable
final class AppRouter {
    private(set) var route: AppRoute

    init(initialRoute: AppRoute = .splash) {
        route = initialRoute
    }

    func completeSplash() {
        route = .onboarding(.first)
    }

    func continueOnboarding() {
        guard case .onboarding(let step) = route else { return }
        route = step.next.map(AppRoute.onboarding) ?? .home
    }
}
