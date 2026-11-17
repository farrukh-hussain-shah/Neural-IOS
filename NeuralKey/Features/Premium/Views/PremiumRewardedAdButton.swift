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
                .singleLineLabel(minimumScale: 0.75)
                .padding(.top, Layout.textTop)
            }
            .foregroundStyle(AppColor.textPrimary)
            .padding(.leading, Layout.leadingPadding)
            .padding(.trailing, Layout.leadingPadding)
            .frame(width: Layout.size.width, height: Layout.size.height, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: AppRadius.xl).fill(AppGradient.brandReversed))
        }
        .buttonStyle(.pressable)
    }

    private enum Layout {
        static let size = CGSize(width: 202.compactScaled, height: 50.compactScaled)
        static let leadingPadding: CGFloat = 8.compactScaled
        static let iconSize: CGFloat = 34.compactScaled
        static let iconTop: CGFloat = 8.compactScaled
        static let iconToText: CGFloat = 15.compactScaled
        static let textTop: CGFloat = 10.8.compactScaled
        static let titleToSubtitle: CGFloat = 3.7.compactScaled
    }
}
