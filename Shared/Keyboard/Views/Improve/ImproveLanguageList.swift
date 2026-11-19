import SwiftUI

/// Picks the language the Improve options are written in (Keyboard SVG › Default-7, Default-8).
struct ImproveLanguageList: View {
    let controller: KeyboardController

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Select Language")
                    .font(.system(size: ImproveLayout.headerTitleSize - 1, weight: .semibold))
                    .foregroundStyle(AppColor.keyboardGlassText)
                HStack {
                    ToolbarCircleButton(symbol: "chevron.left", isAccent: false, label: "Back", identifier: "keyboard.improve.languages.back") {
                        controller.hideImproveLanguages()
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, ImproveLayout.edgeInset - 2.keyboardScaled)
            .padding(.top, ImproveLayout.panelTop)

            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(Array(RewriteLanguage.all.enumerated()), id: \.element.id) { index, language in
                        if index > 0 {
                            Rectangle()
                                .fill(AppColor.keyboardGlassDivider)
                                .frame(height: 1)
                        }
                        row(language)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: ImproveLayout.listCornerRadius, style: .continuous)
                        .fill(AppColor.keyboardGlass)
                )
                .clipShape(RoundedRectangle(cornerRadius: ImproveLayout.listCornerRadius, style: .continuous))
                .padding(.horizontal, ImproveLayout.listInset)
                .padding(.vertical, ImproveLayout.chipsToCards)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("keyboard.improve.languages")
    }

    private func row(_ language: RewriteLanguage) -> some View {
        let isSelected = language == controller.improve.language
        return Button {
            controller.selectImproveLanguage(language)
        } label: {
            HStack {
                Text(verbatim: language.name)
                    .font(.system(size: ImproveLayout.listFontSize))
                    .foregroundStyle(AppColor.keyboardGlassText)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: ImproveLayout.chipFontSize, weight: .semibold))
                        .foregroundStyle(AppColor.keyboardAccent)
                } else if language.isDetect {
                    Image(systemName: "sparkles")
                        .font(.system(size: ImproveLayout.chipFontSize, weight: .medium))
                        .foregroundStyle(AppColor.keyboardAccent)
                }
            }
            .padding(.horizontal, ImproveLayout.cardPadding + 2.keyboardScaled)
            .frame(height: ImproveLayout.listRowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("keyboard.improve.languages.\(language.id)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
