import SwiftUI

struct PremiumView: View {
    let onClose: @MainActor () -> Void

    @State private var viewModel = PremiumViewModel()
    @Namespace private var selectionNamespace

    private let content = PremiumContent.standard

    var body: some View {
        GeometryReader { proxy in
            let safeAreaTop = proxy.safeAreaInsets.top
            let heightBelowSafeTop = proxy.size.height + proxy.safeAreaInsets.bottom

            ZStack(alignment: .topTrailing) {
                PremiumBackground()

                if heightBelowSafeTop + safeAreaTop >= Layout.minimumScreenHeight {
                    screen(safeAreaTop: safeAreaTop)
                        .frame(height: heightBelowSafeTop, alignment: .top)
                } else {
                    ScrollView {
                        screen(safeAreaTop: safeAreaTop)
                    }
                    .scrollIndicators(.hidden)
                }

                closeButton(safeAreaTop: safeAreaTop)
            }
        }
    }

    private func screen(safeAreaTop: CGFloat) -> some View {
        VStack(spacing: 0) {
            header
                .padding(
                    .top,
                    AppScale.safeAreaAlignedTop(Layout.titleDesignTop, safeAreaTop: safeAreaTop, reference: .compact)
                )

            PremiumRewardedAdButton(title: content.rewardedAdTitle, subtitle: content.rewardedAdSubtitle)
                .padding(.top, Layout.subtitleToAdButton)

            PremiumFeatureGrid(features: content.features)
                .padding(.leading, Layout.featuresLeading)
                .padding(.trailing, Layout.featuresTrailing)
                .padding(.top, Layout.adButtonToFeatures)

            planPicker
                .padding(.horizontal, Layout.plansHorizontal)
                .padding(.top, Layout.featuresToPlans)

            Text(content.renewalNote)
                .textStyle(.premiumFinePrint)
                .foregroundStyle(AppColor.premiumFinePrint)
                .padding(.top, Layout.plansToRenewalNote)

            Spacer(minLength: Layout.minimumMiddleSpacing)

            Text(content.trialDisclaimer)
                .textStyle(.premiumDisclaimer)
                .foregroundStyle(AppColor.premiumTextSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            PrimaryButton(title: content.subscribeTitle, style: .premium) {}
                .accessibilityIdentifier(AccessibilityID.premiumSubscribe)
                .padding(.horizontal, Layout.subscribeHorizontal)
                .padding(.top, Layout.disclaimerToSubscribe)

            PremiumFooterLinks(
                restoreTitle: content.restoreTitle,
                termsTitle: content.termsTitle,
                privacyTitle: content.privacyTitle
            )
            .padding(.top, Layout.subscribeToLinks)
            .padding(.bottom, Layout.linksBottom)
        }
        .frame(maxWidth: .infinity)
    }

    private var header: some View {
        VStack(spacing: Layout.titleToSubtitle) {
            Text(content.title)
                .textStyle(.premiumTitle)
                .foregroundStyle(AppColor.textPrimary)
                .overlay(alignment: .topTrailing) {
                    Image(AppImage.premiumSparkles)
                        .resizable()
                        .frame(width: Layout.sparklesSize.width, height: Layout.sparklesSize.height)
                        .alignmentGuide(.trailing) { $0[.leading] - Layout.sparklesGap }
                        .alignmentGuide(.top) { _ in Layout.sparklesRise }
                        .accessibilityHidden(true)
                }
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier(AccessibilityID.premiumTitle)

            Text(content.subtitle)
                .textStyle(.premiumSubtitle)
                .foregroundStyle(AppColor.textPrimary)
        }
    }

    private var planPicker: some View {
        HStack(spacing: Layout.planSpacing) {
            ForEach(content.plans) { option in
                PremiumPlanCard(
                    option: option,
                    isSelected: viewModel.selectedPlan == option.plan,
                    selectionNamespace: selectionNamespace
                ) {
                    withAnimation(AppAnimation.selection) {
                        viewModel.select(option.plan)
                    }
                }
            }
        }
    }

    private func closeButton(safeAreaTop: CGFloat) -> some View {
        let top = max(
            AppScale.safeAreaAlignedTop(Layout.closeDesignTop, safeAreaTop: safeAreaTop, reference: .compact),
            Layout.closeMinimumTop
        )
        return Button(action: onClose) {
            Image(.close)
                .resizable()
                .frame(width: Layout.closeIconSize, height: Layout.closeIconSize)
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: Layout.closeSize, height: Layout.closeSize)
                .background(RoundedRectangle(cornerRadius: Layout.closeCornerRadius).fill(AppColor.premiumSurface))
                .padding(Layout.closeHitSlop)
                .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(Text("Close"))
        .accessibilityIdentifier(AccessibilityID.premiumClose)
        .padding(.top, top - Layout.closeHitSlop)
        .padding(.trailing, Layout.closeTrailing - Layout.closeHitSlop)
    }

    private enum Layout {
        static let minimumScreenHeight: CGFloat = 805.compactScaled

        static let closeDesignTop: CGFloat = 50
        static let closeMinimumTop: CGFloat = 6.compactScaled
        static let closeTrailing: CGFloat = 16.compactScaled
        static let closeSize: CGFloat = 24.compactScaled
        static let closeIconSize: CGFloat = 20.compactScaled
        static let closeCornerRadius: CGFloat = 5.compactScaled
        static let closeHitSlop: CGFloat = 10.compactScaled

        static let titleDesignTop: CGFloat = 258.3
        static let titleToSubtitle: CGFloat = 3.2.compactScaled
        static let sparklesSize = CGSize(width: 21.compactScaled, height: 21.5.compactScaled)
        static let sparklesGap: CGFloat = 1.4.compactScaled
        static let sparklesRise: CGFloat = 1.3.compactScaled

        static let subtitleToAdButton: CGFloat = 16.4.compactScaled
        static let adButtonToFeatures: CGFloat = 20.compactScaled
        static let featuresLeading: CGFloat = 17.compactScaled
        static let featuresTrailing: CGFloat = 13.compactScaled
        static let featuresToPlans: CGFloat = 39.compactScaled
        static let plansHorizontal: CGFloat = 18.compactScaled
        static let planSpacing: CGFloat = 13.5.compactScaled
        static let plansToRenewalNote: CGFloat = 16.8.compactScaled

        static let minimumMiddleSpacing: CGFloat = 16.compactScaled
        static let disclaimerToSubscribe: CGFloat = 18.8.compactScaled
        static let subscribeHorizontal: CGFloat = 16.compactScaled
        static let subscribeToLinks: CGFloat = 20.4.compactScaled
        static let linksBottom: CGFloat = 14.7.compactScaled
    }
}

#Preview {
    PremiumView {}
        .preferredColorScheme(.dark)
}
