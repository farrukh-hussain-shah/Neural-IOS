import SwiftUI
import UIKit

struct OnboardingView: View {
    let step: OnboardingStep
    let onContinue: @MainActor () -> Void
    var onFinish: @MainActor () -> Void = {}

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var isAwaitingSettings = false

    var body: some View {
        OnboardingScaffold(
            pageIndex: step.pageIndex,
            pageCount: OnboardingStep.allCases.count,
            action: step.primaryAction,
            onAction: performPrimaryAction
        ) {
            page
        } footnote: {
            OnboardingFootnoteView(footnote: step.footnote)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, isAwaitingSettings else { return }
            isAwaitingSettings = false
            advanceForKeyboardSetup()
        }
        .onAppear {
            if step == .addKeyboard, KeyboardSetupStatus.current != .notAdded {
                advanceForKeyboardSetup()
            }
        }
    }

    @ViewBuilder
    private var page: some View {
        switch step {
        case .welcome:
            WelcomePageView(content: .standard)
        case .addKeyboard:
            SetupPageView(content: .addKeyboard)
        case .allowFullAccess:
            SetupPageView(content: .allowFullAccess)
        }
    }

    private func performPrimaryAction() {
        guard step.opensKeyboardSettings else {
            onContinue()
            return
        }
        #if DEBUG
        if LaunchOverrides.skipsKeyboardSetup {
            onContinue()
            return
        }
        #endif
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        isAwaitingSettings = true
        openURL(url)
    }

    private func advanceForKeyboardSetup() {
        switch (step, KeyboardSetupStatus.current) {
        case (.addKeyboard, .fullAccess):
            onFinish()
        case (.addKeyboard, .added):
            onContinue()
        case (.allowFullAccess, .added), (.allowFullAccess, .fullAccess):
            onFinish()
        default:
            break
        }
    }
}

#Preview("Welcome") {
    OnboardingView(step: .welcome) {}
}

#Preview("Add Keyboard") {
    OnboardingView(step: .addKeyboard) {}
}

#Preview("Full Access") {
    OnboardingView(step: .allowFullAccess) {}
}
