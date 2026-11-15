import SwiftUI

struct PremiumFeatureGrid: View {
    let features: [PremiumFeature]

    private let columns = [
        GridItem(.flexible(), spacing: Layout.columnSpacing),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Layout.rowSpacing) {
            ForEach(features) { feature in
                PremiumFeatureChip(feature: feature)
            }
        }
    }

    private enum Layout {
        static let columnSpacing: CGFloat = 9.premiumScaled
        static let rowSpacing: CGFloat = 8.premiumScaled
    }
}

private struct PremiumFeatureChip: View {
    let feature: PremiumFeature

    var body: some View {
        HStack(spacing: Layout.iconToText) {
            Image(AppImage.premiumFeatureBullet)
                .resizable()
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .accessibilityHidden(true)
            Text(feature.title)
                .textStyle(.premiumFeature)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .offset(y: Layout.titleBaselineNudge)
            Spacer(minLength: 0)
        }
        .padding(.leading, Layout.leadingPadding)
        .frame(height: Layout.height)
        .background(RoundedRectangle(cornerRadius: AppRadius.sm).fill(AppColor.premiumSurface))
    }

    private enum Layout {
        static let height: CGFloat = 27.premiumScaled
        static let leadingPadding: CGFloat = 13.premiumScaled
        static let iconSize: CGFloat = 11.premiumScaled
        static let iconToText: CGFloat = 7.premiumScaled
        static let titleBaselineNudge: CGFloat = 0.8.premiumScaled
    }
}
