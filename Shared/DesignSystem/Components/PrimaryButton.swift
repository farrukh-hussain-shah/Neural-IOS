import SwiftUI

struct PrimaryButton: View {
    struct Style {
        let background: AnyShapeStyle
        let height: CGFloat
        let cornerRadius: CGFloat
        let textStyle: AppTextStyle
        let titleBaselineNudge: CGFloat

        static let standard = Style(
            background: AnyShapeStyle(AppColor.primary),
            height: AppSize.primaryButtonHeight,
            cornerRadius: AppRadius.lg,
            textStyle: .button,
            titleBaselineNudge: 1
        )

        static let premium = Style(
            background: AnyShapeStyle(AppGradient.brand),
            height: AppSize.premiumButtonHeight,
            cornerRadius: AppRadius.xl,
            textStyle: .premiumButton,
            titleBaselineNudge: 0.3
        )
    }

    let title: LocalizedStringKey
    var trailingIcon: AppIcon?
    var style: Style = .standard
    let action: @MainActor () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.s10) {
                Text(title)
                    .textStyle(style.textStyle)
                    .singleLineLabel()
                    .offset(y: style.titleBaselineNudge)
                if let trailingIcon {
                    Image(trailingIcon)
                        .resizable()
                        .frame(width: AppSize.Icon.medium, height: AppSize.Icon.medium)
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(AppColor.textPrimary)
            .padding(.horizontal, AppSpacing.s16)
            .frame(maxWidth: .infinity)
            .frame(height: style.height)
            .background(RoundedRectangle(cornerRadius: style.cornerRadius).fill(style.background))
        }
        .buttonStyle(.pressable)
    }
}

#Preview {
    VStack(spacing: AppSpacing.s16) {
        PrimaryButton(title: "Set Up Keyboard", trailingIcon: .arrowRight) {}
        PrimaryButton(title: "Subscribe Now", style: .premium) {}
    }
    .padding()
    .background(AppColor.onboardingBackground)
}
