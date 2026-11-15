import SwiftUI

struct OnboardingView: View {
    let step: OnboardingStep
    let onContinue: @MainActor () -> Void

    var body: some View {
        OnboardingScaffold(
            pageIndex: step.pageIndex,
            pageCount: OnboardingStep.allCases.count,
            action: step.primaryAction,
            onAction: onContinue
        ) {
            page
        } footnote: {
            OnboardingFootnoteView(footnote: step.footnote)
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
