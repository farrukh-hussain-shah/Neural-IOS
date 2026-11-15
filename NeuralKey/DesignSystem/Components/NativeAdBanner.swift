import SwiftUI

struct NativeAdContent {
    let icon: AppImage
    let title: String
    let body: String
    let actionTitle: LocalizedStringKey

    static let sample = NativeAdContent(
        icon: .adSampleLogo,
        title: "Easypaisa-Mobile Load",
        body: "A warm welcome to our new customers",
        actionTitle: "Install"
    )
}

struct NativeAdBanner: View {
    let ad: NativeAdContent
    var onAction: @MainActor () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: Layout.iconToText) {
                Image(ad.icon)
                    .resizable()
                    .frame(width: Layout.iconSize, height: Layout.iconSize)
                    .background(RoundedRectangle(cornerRadius: Layout.iconCornerRadius).fill(AppColor.adIconTile))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Layout.titleToBody) {
                    HStack(alignment: .top, spacing: Layout.titleToBadge) {
                        Text(verbatim: ad.title)
                            .textStyle(.adTitle)
                            .foregroundStyle(AppColor.textPrimary)
                            .lineLimit(1)
                        badge
                            .padding(.top, Layout.badgeTop)
                    }
                    Text(verbatim: ad.body)
                        .textStyle(.adSubtitle)
                        .foregroundStyle(AppColor.optionSubtitle)
                        .lineLimit(1)
                }
                .padding(.top, Layout.textTop)

                Spacer(minLength: 0)
            }

            Button(action: onAction) {
                Text(ad.actionTitle)
                    .textStyle(.adAction)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: Layout.actionHeight)
                    .background(
                        RoundedRectangle(cornerRadius: Layout.actionCornerRadius, style: .continuous)
                            .fill(AppColor.royal)
                    )
            }
            .buttonStyle(.pressable)
            .padding(.top, Layout.textToAction)
        }
        .padding(.horizontal, Layout.padding)
        .padding(.vertical, Layout.padding)
        .frame(maxWidth: .infinity)
        .background(AppColor.adSurface)
        .overlay(Rectangle().strokeBorder(AppColor.adBorder, lineWidth: 1))
    }

    private var badge: some View {
        Text("AD")
            .textStyle(.adBadge)
            .foregroundStyle(AppColor.adBadgeText)
            .frame(width: Layout.badgeSize.width, height: Layout.badgeSize.height)
            .background(RoundedRectangle(cornerRadius: Layout.badgeCornerRadius).fill(AppColor.adBadge))
    }

    private enum Layout {
        static let padding: CGFloat = 12.compactScaled
        static let iconSize: CGFloat = 41.compactScaled
        static let iconCornerRadius: CGFloat = 12.6.compactScaled
        static let iconToText: CGFloat = 16.5.compactScaled
        static let textTop: CGFloat = 0.3.compactScaled
        static let titleToBody: CGFloat = 6.5.compactScaled
        static let titleToBadge: CGFloat = 3.compactScaled
        static let badgeTop: CGFloat = 2.7.compactScaled
        static let badgeSize = CGSize(width: 19.compactScaled, height: 14.compactScaled)
        static let badgeCornerRadius: CGFloat = 4.compactScaled
        static let textToAction: CGFloat = 10.5.compactScaled
        static let actionHeight: CGFloat = 50.compactScaled
        static let actionCornerRadius: CGFloat = 16.compactScaled
    }
}
