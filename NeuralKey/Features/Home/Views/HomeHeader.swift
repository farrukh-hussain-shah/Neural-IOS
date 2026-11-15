import SwiftUI

struct HomeHeader: View {
    var onPremium: @MainActor () -> Void = {}

    var body: some View {
        HStack(spacing: 0) {
            AppLogo(size: AppSize.headerLogo, cornerRadius: AppRadius.xs)

            Text(verbatim: "Neural Key")
                .textStyle(.brandName)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.leading, AppSpacing.s8)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: AppSpacing.s12)

            CircleIconButton(
                icon: .crown,
                background: AppGradient.brand,
                accessibilityLabel: "Premium",
                action: onPremium
            )
            .accessibilityIdentifier(AccessibilityID.homePremiumButton)

            CircleIconButton(
                icon: .menu,
                background: AppColor.controlSurface,
                foreground: AppColor.textOnAccent,
                accessibilityLabel: "Menu"
            )
            .padding(.leading, AppSpacing.s24)
        }
    }
}
