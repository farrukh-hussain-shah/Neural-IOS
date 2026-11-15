import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeHeader()
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.s20)

                hero
                    .padding(.horizontal, AppSpacing.s32)
                    .padding(.top, AppSpacing.s40)

                Text("TEST YOUR KEYBOARD")
                    .textStyle(.sectionLabel)
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.horizontal, AppSpacing.s32)
                    .padding(.top, AppSpacing.s20)

                KeyboardTestField(text: $viewModel.testText)
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.s12)

                Text("TYPING & FEEDBACK")
                    .textStyle(.sectionLabelStrong)
                    .foregroundStyle(AppColor.textSubdued)
                    .padding(.horizontal, AppSpacing.s28)
                    .padding(.top, AppSpacing.s36)

                HomeSettingsCard(viewModel: viewModel)
                    .padding(.horizontal, AppSpacing.s16)
                    .padding(.top, AppSpacing.s8)
            }
            .padding(.bottom, AppSpacing.s32)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .background { HomeBackground() }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s8) {
            (Text("NeuralBoard ") + Text("AI").foregroundStyle(AppColor.royal))
                .textStyle(.homeTitle)
                .foregroundStyle(AppColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
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
