import SwiftUI

struct HomeHeader: View {
    var onPremium: @MainActor () -> Void = {}
    var onMenu: @MainActor () -> Void = {}

    var body: some View {
        HStack(spacing: 0) {
            AppLogo(size: AppSize.headerLogo, cornerRadius: Layout.logoCornerRadius)
                .shadow(color: AppColor.royal.opacity(Layout.logoGlowOpacity), radius: Layout.logoGlowRadius)

            Text(verbatim: "Neural Key")
                .textStyle(.brandName)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.leading, Layout.logoToName)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: Layout.logoToName)

            CircleIconButton(
                icon: .crown,
                background: AppGradient.brand,
                accessibilityLabel: "Premium",
                size: Layout.premiumSize,
                iconSize: Layout.premiumIconSize,
                action: onPremium
            )
            .accessibilityIdentifier(AccessibilityID.homePremiumButton)

            CircleIconButton(
                icon: .menu,
                background: AppColor.controlSurface,
                accessibilityLabel: "Menu",
                size: Layout.menuSize,
                iconSize: Layout.menuIconSize,
                action: onMenu
            )
            .accessibilityIdentifier(AccessibilityID.homeMenuButton)
            .padding(.leading, Layout.premiumToMenu)
        }
    }

    private enum Layout {
        static let logoCornerRadius: CGFloat = 7.narrowScaled
        static let logoGlowOpacity: Double = 0.55
        static let logoGlowRadius: CGFloat = 7.narrowScaled
        static let logoToName: CGFloat = 20.5.narrowScaled
        static let premiumSize: CGFloat = 30.narrowScaled
        static let premiumIconSize: CGFloat = 14.narrowScaled
        static let menuSize: CGFloat = 32.narrowScaled
        static let menuIconSize: CGFloat = 15.narrowScaled
        static let premiumToMenu: CGFloat = 20.5.narrowScaled
    }
}
