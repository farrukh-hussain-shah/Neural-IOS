import SwiftUI

struct LanguageOptionRow: View {
    let language: AppLanguage
    let isSelected: Bool
    let onSelect: @MainActor () -> Void

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Layout.cornerRadius)
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 0) {
                flagTile

                VStack(alignment: .leading, spacing: Layout.titleToSubtitle) {
                    Text(language.name)
                        .textStyle(.languageOptionTitle)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(language.selectionHint)
                        .textStyle(.languageOptionSubtitle)
                        .foregroundStyle(isSelected ? AppColor.optionSubtitleSelected : AppColor.optionSubtitle)
                }
                .padding(.leading, Layout.tileToText)

                Spacer(minLength: Layout.tileToText)

                LanguageRadio(isSelected: isSelected)
            }
            .padding(.leading, Layout.leadingPadding)
            .padding(.trailing, Layout.trailingPadding)
            .frame(height: Layout.height)
            .background {
                ZStack {
                    cardShape.fill(AppColor.optionSurface)
                    cardShape.fill(AppColor.optionSurfaceSelected).opacity(isSelected ? 1 : 0)
                }
            }
            .overlay {
                ZStack {
                    cardShape.strokeBorder(AppColor.optionBorder, lineWidth: Layout.borderWidth)
                    cardShape.strokeBorder(AppGradient.brand, lineWidth: Layout.borderWidth).opacity(isSelected ? 1 : 0)
                }
            }
            .contentShape(cardShape)
        }
        .buttonStyle(.pressable)
        .animation(AppAnimation.selection, value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier(AccessibilityID.languageOption(language))
    }

    private var flagTile: some View {
        let tileShape = RoundedRectangle(cornerRadius: Layout.tileCornerRadius)
        return Image(language.flag)
            .resizable()
            .frame(width: Layout.flagSize.width, height: Layout.flagSize.height)
            .frame(width: Layout.tileSize, height: Layout.tileSize)
            .background {
                ZStack {
                    tileShape.fill(AppColor.optionTile)
                    tileShape.fill(AppGradient.brand).opacity(isSelected ? Layout.selectedTileOpacity : 0)
                }
            }
            .accessibilityHidden(true)
    }

    private enum Layout {
        static let height: CGFloat = 66.compactScaled
        static let cornerRadius: CGFloat = 12.compactScaled
        static let borderWidth: CGFloat = 1
        static let leadingPadding: CGFloat = 12.compactScaled
        static let trailingPadding: CGFloat = 16.compactScaled
        static let tileSize: CGFloat = 40.compactScaled
        static let tileCornerRadius: CGFloat = 10.compactScaled
        static let selectedTileOpacity: Double = 0.1
        static let flagSize = CGSize(width: 28.compactScaled, height: 24.compactScaled)
        static let tileToText: CGFloat = 12.compactScaled
        static let titleToSubtitle: CGFloat = 5.compactScaled
    }
}

private struct LanguageRadio: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(AppColor.radioBorder, lineWidth: Layout.ringWidth)
                .opacity(isSelected ? 0 : 1)
            Circle()
                .strokeBorder(AppGradient.brand, lineWidth: Layout.ringWidth)
                .opacity(isSelected ? 1 : 0)
            Circle()
                .fill(AppGradient.brand)
                .frame(width: Layout.dotDiameter, height: Layout.dotDiameter)
                .scaleEffect(isSelected ? 1 : 0.2)
                .opacity(isSelected ? 1 : 0)
        }
        .frame(width: Layout.diameter, height: Layout.diameter)
        .accessibilityHidden(true)
    }

    private enum Layout {
        static let diameter: CGFloat = 20.compactScaled
        static let ringWidth: CGFloat = 1.5.compactScaled
        static let dotDiameter: CGFloat = 10.compactScaled
    }
}
