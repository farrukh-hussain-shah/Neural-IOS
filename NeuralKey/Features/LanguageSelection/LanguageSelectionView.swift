import SwiftUI

struct LanguageSelectionView: View {
    let store: LanguageStore
    let onDone: @MainActor () -> Void

    var body: some View {
        GeometryReader { proxy in
            let safeAreaTop = proxy.safeAreaInsets.top

            VStack(spacing: 0) {
                header
                    .padding(
                        .top,
                        AppScale.safeAreaAlignedTop(Layout.headerDesignTop, safeAreaTop: safeAreaTop, reference: .compact)
                    )

                ScrollView {
                    VStack(spacing: Layout.optionSpacing) {
                        ForEach(AppLanguage.allCases) { language in
                            LanguageOptionRow(language: language, isSelected: store.selectedLanguage == language) {
                                withAnimation(AppAnimation.selection) {
                                    store.select(language)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Layout.horizontalMargin)
                    .padding(.top, Layout.subtitleToList)
                    .padding(.bottom, Layout.listBottom)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)

                NativeAdBanner(ad: .sample)
                    .padding(.bottom, Layout.adBottom)
            }
            .frame(height: proxy.size.height + proxy.safeAreaInsets.bottom, alignment: .top)
        }
        .background { RadialGlowBackground(glow: .languageSelection) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Layout.titleToSubtitle) {
            HStack(alignment: .top, spacing: Layout.titleToDone) {
                Text("Choose the Language")
                    .textStyle(.languageTitle)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.top, Layout.titleTop)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier(AccessibilityID.languageTitle)
                Spacer(minLength: 0)
                doneButton
            }
            Text("Choose the language that feels like you.")
                .textStyle(.languageSubtitle)
                .foregroundStyle(AppColor.optionSubtitle)
        }
        .padding(.leading, Layout.horizontalMargin)
        .padding(.trailing, Layout.doneTrailing)
    }

    private var doneButton: some View {
        Button(action: onDone) {
            Text("Done")
                .textStyle(.languageDone)
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: Layout.doneSize.width, height: Layout.doneSize.height)
                .background(RoundedRectangle(cornerRadius: Layout.doneCornerRadius).fill(AppGradient.brand))
        }
        .buttonStyle(.pressable)
        .accessibilityIdentifier(AccessibilityID.languageDone)
    }

    private enum Layout {
        static let headerDesignTop: CGFloat = 49
        static let horizontalMargin: CGFloat = 20.compactScaled
        static let titleTop: CGFloat = 1.compactScaled
        static let titleToDone: CGFloat = 12.compactScaled
        static let titleToSubtitle: CGFloat = 11.9.compactScaled
        static let doneTrailing: CGFloat = 26.compactScaled
        static let doneSize = CGSize(width: 62.compactScaled, height: 27.compactScaled)
        static let doneCornerRadius: CGFloat = 10.compactScaled
        static let subtitleToList: CGFloat = 19.7.compactScaled
        static let optionSpacing: CGFloat = 8.compactScaled
        static let listBottom: CGFloat = 16.compactScaled
        static let adBottom: CGFloat = 17.compactScaled
    }
}

#Preview {
    LanguageSelectionView(store: LanguageStore()) {}
        .preferredColorScheme(.dark)
}
