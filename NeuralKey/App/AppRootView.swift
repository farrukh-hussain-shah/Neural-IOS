import SwiftUI

struct AppRootView: View {
    @State private var router = AppRouter()

    var body: some View {
        ZStack {
            switch router.route {
            case .splash:
                SplashView(onFinish: router.completeSplash)
                    .transition(.opacity)
            case .onboarding(let step):
                OnboardingView(step: step, onContinue: router.continueOnboarding)
                    .id(step)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .home:
                HomeView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: AppConfiguration.Transition.duration), value: router.route)
        .background(AppColor.onboardingBackground.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AppRootView()
}
