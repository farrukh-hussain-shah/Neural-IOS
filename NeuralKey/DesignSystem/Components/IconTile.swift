import SwiftUI

struct IconTile: View {
    struct Style {
        let tileSize: CGFloat
        let iconSize: CGFloat
        let cornerRadius: CGFloat
        let background: Color
        let foreground: Color

        static let feature = Style(
            tileSize: AppSize.featureTile,
            iconSize: AppSize.Icon.large,
            cornerRadius: AppRadius.md,
            background: AppColor.iconTile,
            foreground: AppColor.soft
        )

        static let setting = Style(
            tileSize: AppSize.settingTile,
            iconSize: AppSize.settingIcon,
            cornerRadius: AppRadius.settingTile,
            background: AppColor.tintedTile,
            foreground: AppColor.royal
        )
    }

    let icon: AppIcon
    var style: Style = .feature

    var body: some View {
        Image(icon)
            .resizable()
            .scaledToFit()
            .frame(width: style.iconSize, height: style.iconSize)
            .foregroundStyle(style.foreground)
            .frame(width: style.tileSize, height: style.tileSize)
            .background(RoundedRectangle(cornerRadius: style.cornerRadius).fill(style.background))
            .accessibilityHidden(true)
    }
}
