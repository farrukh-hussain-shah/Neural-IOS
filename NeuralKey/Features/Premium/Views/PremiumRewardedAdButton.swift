import SwiftUI

struct PremiumRewardedAdButton: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    var action: @MainActor () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: Layout.iconToText) {
                Image(.adBadge)
                    .resizable()
                    .frame(width: Layout.iconSize, height: Layout.iconSize)
                    .padding(.top, Layout.iconTop)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: Layout.titleToSubtitle) {
                    Text(title)
                        .textStyle(.premiumAdTitle)
                    Text(subtitle)
                        .textStyle(.premiumAdSubtitle)
                }
                .lineLimit(1)
                .fixedSize()
                .padding(.top, Layout.textTop)
            }
            .foregroundStyle(AppColor.textPrimary)
            .padding(.leading, Layout.leadingPadding)
            .frame(width: Layout.size.width, height: Layout.size.height, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: AppRadius.xl).fill(AppGradient.brandReversed))
        }
        .buttonStyle(.pressable)
    }

    private enum Layout {
        static let size = CGSize(width: 202.premiumScaled, height: 50.premiumScaled)
        static let leadingPadding: CGFloat = 8.premiumScaled
        static let iconSize: CGFloat = 34.premiumScaled
        static let iconTop: CGFloat = 8.premiumScaled
        static let iconToText: CGFloat = 15.premiumScaled
        static let textTop: CGFloat = 10.8.premiumScaled
        static let titleToSubtitle: CGFloat = 3.7.premiumScaled
    }
}
