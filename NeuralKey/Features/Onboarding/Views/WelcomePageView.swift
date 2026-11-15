import SwiftUI

struct WelcomePageView: View {
    let content: WelcomeContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TwoToneHeadline(primary: content.headline.primary, accent: content.headline.accent)

            Text(content.message)
                .textStyle(.bodyLarge)
                .foregroundStyle(AppColor.textSecondary)
                .padding(.top, AppSpacing.s12)

            VStack(spacing: AppSpacing.s12) {
                ForEach(content.features) { feature in
                    FeatureCard(feature: feature)
                }
            }
            .padding(.top, AppSpacing.s28)
        }
    }
}

private struct FeatureCard: View {
    let feature: FeatureHighlight

    var body: some View {
        HStack(spacing: AppSpacing.s14) {
            IconTile(icon: feature.icon, style: .feature)
            VStack(alignment: .leading, spacing: AppSpacing.s2) {
                Text(feature.title)
                    .textStyle(.cardTitle)
                    .foregroundStyle(AppColor.textPrimary)
                Text(feature.subtitle)
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.s16)
        .frame(minHeight: AppSize.featureCardHeight)
        .background(RoundedRectangle(cornerRadius: AppRadius.xl).fill(AppColor.cardSurface))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.xl).strokeBorder(AppColor.cardBorder, lineWidth: 1))
        .accessibilityElement(children: .combine)
    }
}
