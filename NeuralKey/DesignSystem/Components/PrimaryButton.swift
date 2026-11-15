import SwiftUI

struct PrimaryButton: View {
    let title: LocalizedStringKey
    var trailingIcon: AppIcon?
    let action: @MainActor () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.s10) {
                Text(title)
                    .textStyle(.button)
                if let trailingIcon {
                    Image(trailingIcon)
                        .resizable()
                        .frame(width: AppSize.Icon.medium, height: AppSize.Icon.medium)
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(AppColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: AppSize.primaryButtonHeight)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColor.primary)
                    .appShadow(.primaryButton)
            }
        }
        .buttonStyle(.pressable)
    }
}

#Preview {
    PrimaryButton(title: "Set Up Keyboard", trailingIcon: .arrowRight) {}
        .padding()
        .background(AppColor.onboardingBackground)
}
