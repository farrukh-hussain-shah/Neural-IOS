import SwiftUI

struct CircleIconButton<Background: ShapeStyle>: View {
    let icon: AppIcon
    let background: Background
    var foreground: Color = AppColor.textPrimary
    let accessibilityLabel: LocalizedStringKey
    var size: CGFloat = AppSize.circleButton
    var iconSize: CGFloat = AppSize.Icon.regular
    var action: @MainActor () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(foreground)
                .frame(width: size, height: size)
                .background(Circle().fill(background))
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(Text(accessibilityLabel))
    }
}
