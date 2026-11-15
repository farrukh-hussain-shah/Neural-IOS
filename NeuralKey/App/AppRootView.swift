import SwiftUI

struct AppRootView: View {
    @State private var router = AppRouter(initialRoute: Self.initialRoute)

    var body: some View {
        ZStack {
            switch router.route {
            case .splash:
                SplashView(onFinish: router.completeSplash)
                    .transition(.opacity)
            case .onboarding(let step):
                OnboardingView(step: step, onContinue: router.continueOnboarding)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .home:
                HomeView(onPremium: router.presentPremium)
                    .transition(.opacity)
                    .fullScreenCover(isPresented: $router.isPremiumPresented) {
                        PremiumView(onClose: router.dismissPremium)
                            .preferredColorScheme(.dark)
                    }
            }
        }
        .animation(.easeInOut(duration: AppConfiguration.Transition.duration), value: router.route)
        .background(AppColor.onboardingBackground.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private static var initialRoute: AppRoute {
        #if DEBUG
        return LaunchOverrides.initialRoute ?? .splash
        #else
        return .splash
        #endif
    }
}

#Preview {
    AppRootView()
}
