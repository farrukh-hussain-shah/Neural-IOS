import SwiftUI

struct HomeView: View {
    var onPremium: @MainActor () -> Void = {}
    var onMenu: @MainActor () -> Void = {}

    @State private var viewModel = HomeViewModel()
    @State private var keyboardPresenter = InAppKeyboardPresenter()

    var body: some View {
        content
            .background { HomeBackground() }
            .inAppKeyboardHost(keyboardPresenter)
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeHeader(onPremium: onPremium, onMenu: onMenu)
                    .padding(.leading, Layout.headerLeading)
                    .padding(.trailing, Layout.headerTrailing)
                    .padding(.top, Layout.headerTop)

                hero
                    .padding(.horizontal, Layout.heroLeading)
                    .padding(.top, Layout.headerToTitle)

                Text("TEST YOUR KEYBOARD")
                    .textStyle(.sectionLabel)
                    .foregroundStyle(AppColor.homeTextSecondary)
                    .padding(.leading, Layout.testLabelLeading)
                    .padding(.top, Layout.subtitleToTestLabel)

                KeyboardTestField(text: $viewModel.testText)
                    .padding(.horizontal, Layout.fieldHorizontal)
                    .padding(.top, Layout.testLabelToField)

                Text("SETUP")
                    .textStyle(.sectionLabelStrong)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.leading, Layout.setupLabelLeading)
                    .padding(.top, Layout.fieldToSetupLabel)

                HomeSettingsCard(viewModel: viewModel)
                    .padding(.horizontal, Layout.cardHorizontal)
                    .padding(.top, Layout.setupLabelToCard)
            }
            .padding(.bottom, Layout.bottomPadding)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
    }

    private enum Layout {
        static let headerTop: CGFloat = 14.narrowScaled
        static let headerLeading: CGFloat = 20.narrowScaled
        static let headerTrailing: CGFloat = 14.narrowScaled
        static let headerToTitle: CGFloat = 27.9.narrowScaled
        static let heroLeading: CGFloat = 16.narrowScaled
        static let titleToSubtitle: CGFloat = 8.7.narrowScaled
        static let subtitleToTestLabel: CGFloat = 30.9.narrowScaled
        static let testLabelLeading: CGFloat = 15.5.narrowScaled
        static let testLabelToField: CGFloat = 13.1.narrowScaled
        static let fieldHorizontal: CGFloat = 16.5.narrowScaled
        static let fieldToSetupLabel: CGFloat = 32.1.narrowScaled
        static let setupLabelLeading: CGFloat = 14.5.narrowScaled
        static let setupLabelToCard: CGFloat = 8.1.narrowScaled
        static let cardHorizontal: CGFloat = 12.5.narrowScaled
        static let bottomPadding: CGFloat = 24.narrowScaled
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: Layout.titleToSubtitle) {
            (Text("NeuralBoard ") + Text("AI").foregroundStyle(AppColor.royal))
                .textStyle(.homeTitle)
                .foregroundStyle(AppColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier(AccessibilityID.homeTitle)
            Text("Smart Typing. AI Powered.\nPerfectly Personalized.")
                .textStyle(.homeSubtitle)
                .foregroundStyle(AppColor.homeTextSecondary)
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
            .dithered()
            .ignoresSafeArea()
    }

    private enum Layout {
        static let glowSize = CGSize(width: 273.scaled, height: 477.5.scaled)
        static let glowOffset = CGSize(width: (-78).scaled, height: (-191).scaled)
        static let glowCornerRadius: CGFloat = 136.5.scaled
        static let glowOpacity: Double = 0.19
        static let glowBlur: CGFloat = 50.scaled
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
