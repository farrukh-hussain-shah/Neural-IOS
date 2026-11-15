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
        static let size = CGSize(width: 202, height: 50)
        static let leadingPadding: CGFloat = 8
        static let iconSize: CGFloat = 34
        static let iconTop: CGFloat = 8
        static let iconToText: CGFloat = 15
        static let textTop: CGFloat = 10.8
        static let titleToSubtitle: CGFloat = 3.7
    }
}
