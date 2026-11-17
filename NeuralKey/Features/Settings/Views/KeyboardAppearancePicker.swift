import SwiftUI

struct KeyboardAppearancePicker: View {
    let selection: KeyboardAppearance
    let onSelect: @MainActor (KeyboardAppearance) -> Void

    var body: some View {
        HStack(spacing: Layout.tileSpacing) {
            ForEach(KeyboardAppearance.allCases) { appearance in
                let isSelected = appearance == selection
                Button {
                    onSelect(appearance)
                } label: {
                    VStack(spacing: Layout.tileToLabel) {
                        AppearanceTile(appearance: appearance, isSelected: isSelected)
                        Text(appearance.title)
                            .singleLineLabel()
                            .textStyle(.settingsTileLabel)
                            .foregroundStyle(isSelected ? AppColor.royal : AppColor.settingsSecondary)
                            .shadow(color: isSelected ? AppColor.royal.opacity(0.5) : .clear, radius: Layout.labelGlow)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.pressable)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                .accessibilityIdentifier(AccessibilityID.keyboardAppearance(appearance))
            }
        }
        .animation(AppAnimation.selection, value: selection)
    }

    private enum Layout {
        static let tileSpacing: CGFloat = 13.narrowScaled
        static let tileToLabel: CGFloat = 8.narrowScaled
        static let labelGlow: CGFloat = 4.narrowScaled
    }
}

private struct AppearanceTile: View {
    let appearance: KeyboardAppearance
    let isSelected: Bool

    private var tileShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Layout.cornerRadius)
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: Layout.height)
            .background(background)
            .clipShape(tileShape)
            .overlay {
                tileShape.strokeBorder(
                    isSelected ? AppColor.royal : AppColor.appearanceTileBorder,
                    lineWidth: isSelected ? Layout.selectedBorderWidth : 1
                )
            }
            .shadow(color: isSelected ? AppColor.royal.opacity(0.18) : .clear, radius: Layout.selectedGlow)
    }

    @ViewBuilder
    private var background: some View {
        switch appearance {
        case .system: tileShape.fill(AppGradient.appearanceSystem)
        case .dark: tileShape.fill(AppColor.appearanceDark)
        case .light: tileShape.fill(AppColor.appearanceLight)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch appearance {
        case .system:
            RoundedRectangle(cornerRadius: Layout.systemInnerCornerRadius)
                .fill(AppColor.appearanceSystemCore)
                .frame(width: Layout.systemCoreSize, height: Layout.systemCoreSize)
                .frame(width: Layout.systemOuterSize, height: Layout.systemOuterSize)
                .background(
                    RoundedRectangle(cornerRadius: Layout.systemOuterCornerRadius)
                        .fill(AppColor.appearanceSystemInner)
                )
        case .dark:
            Image(.moon)
                .resizable()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .foregroundStyle(AppColor.appearanceMoon)
        case .light:
            Image(.sun)
                .resizable()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .foregroundStyle(AppColor.appearanceSun)
        }
    }

    private enum Layout {
        static let height: CGFloat = 84.narrowScaled
        static let cornerRadius: CGFloat = 16.narrowScaled
        static let selectedBorderWidth: CGFloat = 1.5.narrowScaled
        static let selectedGlow: CGFloat = 10.narrowScaled
        static let systemOuterSize: CGFloat = 40.narrowScaled
        static let systemCoreSize: CGFloat = 33.5.narrowScaled
        static let systemOuterCornerRadius: CGFloat = 4.narrowScaled
        static let systemInnerCornerRadius: CGFloat = 2.narrowScaled
        static let iconSize: CGFloat = 24.narrowScaled
    }
}
