import SwiftUI

struct CircleIconButton<Background: ShapeStyle>: View {
    let icon: AppIcon
    let background: Background
    var foreground: Color = AppColor.textPrimary
    let accessibilityLabel: LocalizedStringKey
    var action: @MainActor () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: AppSize.Icon.regular, height: AppSize.Icon.regular)
                .foregroundStyle(foreground)
                .frame(width: AppSize.circleButton, height: AppSize.circleButton)
                .background(Circle().fill(background))
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(Text(accessibilityLabel))
    }
}
