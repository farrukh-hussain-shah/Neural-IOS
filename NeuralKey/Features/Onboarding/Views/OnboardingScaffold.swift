import SwiftUI

struct OnboardingScaffold<Content: View, Footnote: View>: View {
    let pageIndex: Int
    let action: OnboardingAction
    let onAction: @MainActor () -> Void
    @ViewBuilder let content: Content
    @ViewBuilder let footnote: Footnote

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 0) {
                PageIndicator(count: AppConfiguration.Onboarding.pageCount, currentIndex: pageIndex)
                    .padding(.top, AppSpacing.s24)

                ScrollView {
                    content
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, AppSpacing.s28)
                        .padding(.bottom, AppSpacing.s24)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)

                VStack(spacing: AppSpacing.s12) {
                    footnote
                        .textStyle(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    PrimaryButton(title: action.title, trailingIcon: action.icon, action: onAction)
                }
                .padding(.bottom, proxy.safeAreaInsets.bottom > 0 ? 0 : AppSpacing.s16)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
        .background { OnboardingBackground() }
    }
}

struct OnboardingFootnoteView: View {
    let footnote: OnboardingFootnote

    var body: some View {
        switch footnote {
        case .message(let message):
            Text(message)
        case .legalConsent:
            Text("By enabling, you agree to our ")
                + Text("Terms").underline().foregroundStyle(AppColor.pale)
                + Text(" & ").foregroundStyle(AppColor.pale)
                + Text("Privacy Policy").underline().foregroundStyle(AppColor.pale)
        }
    }
}

private struct OnboardingBackground: View {
    var body: some View {
        GeometryReader { proxy in
            RadialGradient(
                stops: [
                    .init(color: AppColor.onboardingGlow, location: 0),
                    .init(color: AppColor.onboardingBackground, location: 0.75)
                ],
                center: Layout.glowCenter,
                startRadius: 0,
                endRadius: proxy.size.width * Layout.glowRadiusRatio
            )
        }
        .background(AppColor.onboardingBackground)
        .ignoresSafeArea()
    }

    private enum Layout {
        static let glowCenter = UnitPoint(x: 331.5 / 390, y: 0)
        static let glowRadiusRatio: CGFloat = 351 / 390
    }
}
