import SwiftUI

struct ToneChip: View {
    let tone: AITone
    let isSelected: Bool
    let onToggle: @MainActor () -> Void

    private var chipShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Layout.cornerRadius)
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 0) {
                Image(tone.iconName)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: Layout.iconSize, height: Layout.iconSize)
                    .foregroundStyle(isSelected ? AppColor.toneAccent : AppColor.toneChipIcon)
                    .accessibilityHidden(true)

                Text(tone.title)
                    .textStyle(.toneChip)
                    .foregroundStyle(AppColor.toneChipText)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.leading, Layout.iconToText)

                Image(.checkCircle)
                    .resizable()
                    .frame(width: Layout.checkSize, height: Layout.checkSize)
                    .foregroundStyle(AppColor.toneAccent)
                    .scaleEffect(isSelected ? 1 : 0.5)
                    .opacity(isSelected ? 1 : 0)
                    .padding(.leading, Layout.textToCheck)
                    .accessibilityHidden(true)
            }
            .padding(.leading, Layout.leadingPadding)
            .padding(.trailing, Layout.trailingPadding)
            .frame(height: Layout.height)
            .background {
                ZStack {
                    chipShape.fill(AppColor.toneChipSurface)
                    chipShape.fill(AppGradient.toneSelected).opacity(isSelected ? 1 : 0)
                }
            }
            .overlay {
                chipShape.strokeBorder(
                    isSelected ? AppColor.toneChipBorderSelected : AppColor.toneChipBorder,
                    lineWidth: 1
                )
            }
            .contentShape(chipShape)
        }
        .buttonStyle(.pressable)
        .animation(AppAnimation.selection, value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier(AccessibilityID.tone(tone))
    }

    private enum Layout {
        static let height: CGFloat = 28.5.narrowScaled
        static let cornerRadius: CGFloat = 9.narrowScaled
        static let leadingPadding: CGFloat = 10.8.narrowScaled
        static let trailingPadding: CGFloat = 10.8.narrowScaled
        static let iconSize: CGFloat = 14.4.narrowScaled
        static let iconToText: CGFloat = 6.3.narrowScaled
        static let textToCheck: CGFloat = 5.8.narrowScaled
        static let checkSize: CGFloat = 14.4.narrowScaled
    }
}
