import SwiftUI

struct HomeView: View {
    var onPremium: @MainActor () -> Void = {}

    @State private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeHeader(onPremium: onPremium)
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.s20)

                hero
                    .padding(.leading, Layout.heroLeading)
                    .padding(.trailing, AppSpacing.screenHorizontal)
                    .padding(.top, Layout.heroTop)

                Text("TEST YOUR KEYBOARD")
                    .textStyle(.sectionLabel)
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.leading, Layout.testLabelLeading)
                    .padding(.top, Layout.testLabelTop)

                KeyboardTestField(text: $viewModel.testText)
                    .padding(.leading, Layout.fieldLeading)
                    .padding(.trailing, Layout.fieldTrailing)
                    .padding(.top, Layout.fieldTop)

                Text("TYPING & FEEDBACK")
                    .textStyle(.sectionLabelStrong)
                    .foregroundStyle(AppColor.textSubdued)
                    .padding(.leading, Layout.feedbackLabelLeading)
                    .padding(.top, Layout.feedbackLabelTop)

                HomeSettingsCard(viewModel: viewModel)
                    .padding(.leading, Layout.cardLeading)
                    .padding(.trailing, Layout.cardTrailing)
                    .padding(.top, Layout.cardTop)
            }
            .padding(.bottom, AppSpacing.s32)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .background { HomeBackground() }
    }

    private enum Layout {
        static let heroTop: CGFloat = 42.5
        static let heroLeading: CGFloat = 31
        static let heroSubtitleSpacing: CGFloat = 6
        static let testLabelTop: CGFloat = 33
        static let testLabelLeading: CGFloat = 35
        static let fieldTop: CGFloat = 12.5
        static let fieldLeading: CGFloat = 31
        static let fieldTrailing: CGFloat = 17
        static let feedbackLabelTop: CGFloat = 35
        static let feedbackLabelLeading: CGFloat = 27
        static let cardTop: CGFloat = 8.5
        static let cardLeading: CGFloat = 23
        static let cardTrailing: CGFloat = 9
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: Layout.heroSubtitleSpacing) {
            (Text("NeuralBoard ") + Text("AI").foregroundStyle(AppColor.royal))
                .textStyle(.homeTitle)
                .foregroundStyle(AppColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier(AccessibilityID.homeTitle)
            Text("Smart Typing. AI Powered.\nPerfectly Personalized.")
                .textStyle(.homeSubtitle)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

private struct HomeBackground: View {
    var body: some View {
        AppColor.homeBackground
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Layout.glowCornerRadius)
                    .fill(AppColor.royal.opacity(Layout.glowOpacity))
                    .frame(width: Layout.glowSize.width, height: Layout.glowSize.height)
                    .offset(Layout.glowOffset)
                    .blur(radius: Layout.glowBlur)
            }
            .ignoresSafeArea()
    }

    private enum Layout {
        static let glowSize = CGSize(width: 273, height: 477.5)
        static let glowOffset = CGSize(width: -78, height: -191)
        static let glowCornerRadius: CGFloat = 136.5
        static let glowOpacity: Double = 0.19
        static let glowBlur: CGFloat = 50
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
