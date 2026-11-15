import SwiftUI

struct OnboardingScaffold<Content: View, Footnote: View>: View {
    let pageIndex: Int
    let pageCount: Int
    let action: OnboardingAction
    let onAction: @MainActor () -> Void
    @ViewBuilder let content: Content
    @ViewBuilder let footnote: Footnote

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 0) {
                PageIndicator(count: pageCount, currentIndex: pageIndex)
                    .accessibilityIdentifier(AccessibilityID.onboardingPageIndicator)
                    .padding(.top, Layout.indicatorTop)
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                ZStack(alignment: .topLeading) {
                    ScrollView {
                        content
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                            .padding(.top, Layout.contentTop)
                            .padding(.bottom, AppSpacing.s24)
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                    .id(pageIndex)
                    .transition(AppAnimation.onboardingPage)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .animation(AppAnimation.onboardingContent, value: pageIndex)

                VStack(spacing: Layout.footnoteToButton) {
                    ZStack {
                        footnote
                            .textStyle(.caption)
                            .foregroundStyle(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .id(pageIndex)
                            .transition(.opacity)
                    }
                    PrimaryButton(title: action.title, trailingIcon: action.icon, action: onAction)
                        .accessibilityIdentifier(AccessibilityID.onboardingPrimaryAction)
                }
                .animation(AppAnimation.onboardingContent, value: pageIndex)
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.bottom, proxy.safeAreaInsets.bottom > 0 ? 0 : AppSpacing.s16)
            }
        }
        .background { OnboardingBackground() }
    }
}

private enum Layout {
    static let indicatorTop: CGFloat = 25
    static let contentTop: CGFloat = 26
    static let footnoteToButton: CGFloat = 13
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
