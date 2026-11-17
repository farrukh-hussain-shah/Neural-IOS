import SwiftUI

struct AppRootView: View {
    @State private var router = AppRouter(initialRoute: Self.initialRoute)
    @State private var languageStore = LanguageStore()
    @State private var settingsStore = SettingsStore()

    var body: some View {
        ZStack {
            switch router.route {
            case .splash:
                SplashView(onFinish: router.completeSplash)
                    .transition(.opacity)
            case .languageSelection:
                LanguageSelectionView(store: languageStore, onDone: router.completeLanguageSelection)
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
            case .onboarding(let step):
                OnboardingView(step: step, onContinue: router.continueOnboarding, onFinish: router.finishOnboarding)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .home:
                ZStack {
                    HomeView(onPremium: router.presentPremium, onMenu: router.presentSettings)
                    if router.isSettingsPresented {
                        SettingsDrawer(
                            store: settingsStore,
                            languageStore: languageStore,
                            onUpgrade: router.presentPremium,
                            onClose: router.dismissSettings
                        )
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                    }
                }
                .animation(AppAnimation.drawer, value: router.isSettingsPresented)
                .transition(.opacity)
                .fullScreenCover(isPresented: $router.isPremiumPresented) {
                        PremiumView(onClose: router.dismissPremium)
                            .preferredColorScheme(.dark)
                            .appLanguage(languageStore.selectedLanguage)
                    }
            }
        }
        .animation(.easeInOut(duration: AppConfiguration.Transition.duration), value: router.route)
        .background(AppColor.onboardingBackground.ignoresSafeArea())
        .environment(languageStore)
        .environment(settingsStore)
        .appLanguage(languageStore.selectedLanguage)
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
