import SwiftUI

struct SettingsUpgradeCard: View {
    let action: @MainActor () -> Void

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Layout.cornerRadius)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Image(.crown)
                    .resizable()
                    .frame(width: Layout.crownIconSize, height: Layout.crownIconSize)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: Layout.crownSize, height: Layout.crownSize)
                    .background(Circle().fill(AppGradient.brand))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Layout.titleToSubtitle) {
                    Text("Unlock Full Access")
                        .textStyle(.settingsCardTitle)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("Unlimited AI Rewrite & Ad Free")
                        .textStyle(.settingsCardSubtitle)
                        .foregroundStyle(AppColor.settingsSecondary)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .padding(.leading, Layout.crownToText)

                Spacer(minLength: Layout.minimumGap)

                HStack(spacing: Layout.pillTextToChevron) {
                    Text("Upgrade")
                        .textStyle(.settingsPill)
                    Image(.chevronRight)
                        .resizable()
                        .frame(width: Layout.pillChevronSize, height: Layout.pillChevronSize)
                }
                .foregroundStyle(AppColor.textPrimary)
                .padding(.leading, Layout.pillLeading)
                .padding(.trailing, Layout.pillTrailing)
                .frame(height: Layout.pillHeight)
                .background(RoundedRectangle(cornerRadius: Layout.pillCornerRadius).fill(AppColor.settingsPill))
            }
            .padding(.leading, Layout.leadingPadding)
            .padding(.trailing, Layout.trailingPadding)
            .frame(height: Layout.height)
            .background {
                cardShape.fill(AppColor.settingsSurface)
                    .overlay(cardShape.fill(AppGradient.upgradeCard))
            }
            .overlay(cardShape.strokeBorder(AppColor.settingsUpgradeBorder, lineWidth: 1))
            .contentShape(cardShape)
        }
        .buttonStyle(.pressable)
        .accessibilityIdentifier(AccessibilityID.settingsUpgrade)
    }

    private enum Layout {
        static let height: CGFloat = 63.5.narrowScaled
        static let cornerRadius: CGFloat = 16.narrowScaled
        static let leadingPadding: CGFloat = 14.5.narrowScaled
        static let trailingPadding: CGFloat = 14.narrowScaled
        static let crownSize: CGFloat = 29.5.narrowScaled
        static let crownIconSize: CGFloat = 15.narrowScaled
        static let crownToText: CGFloat = 12.5.narrowScaled
        static let titleToSubtitle: CGFloat = 1.narrowScaled
        static let minimumGap: CGFloat = 8.narrowScaled
        static let pillHeight: CGFloat = 23.5.narrowScaled
        static let pillCornerRadius: CGFloat = 8.narrowScaled
        static let pillLeading: CGFloat = 11.narrowScaled
        static let pillTrailing: CGFloat = 9.narrowScaled
        static let pillTextToChevron: CGFloat = 6.narrowScaled
        static let pillChevronSize: CGFloat = 12.narrowScaled
    }
}
