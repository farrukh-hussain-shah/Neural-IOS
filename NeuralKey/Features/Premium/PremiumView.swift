import SwiftUI

struct PremiumView: View {
    let onClose: @MainActor () -> Void

    @State private var viewModel = PremiumViewModel()
    @Namespace private var selectionNamespace

    private let content = PremiumContent.standard

    var body: some View {
        GeometryReader { proxy in
            let screenHeight = proxy.size.height + proxy.safeAreaInsets.bottom

            ZStack(alignment: .topTrailing) {
                PremiumBackground(topInsetDelta: proxy.safeAreaInsets.top - Layout.designSafeAreaTop)

                if screenHeight >= Layout.minimumScreenHeight {
                    screen
                        .frame(height: screenHeight, alignment: .top)
                } else {
                    ScrollView {
                        screen
                    }
                    .scrollIndicators(.hidden)
                }

                closeButton
            }
        }
    }

    private var screen: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, Layout.titleTop)

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

    private var closeButton: some View {
        Button(action: onClose) {
            Image(.close)
                .resizable()
                .frame(width: AppSize.Icon.regular, height: AppSize.Icon.regular)
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: Layout.closeSize, height: Layout.closeSize)
                .background(RoundedRectangle(cornerRadius: Layout.closeCornerRadius).fill(AppColor.premiumSurface))
                .padding(Layout.closeHitSlop)
                .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(Text("Close"))
        .accessibilityIdentifier(AccessibilityID.premiumClose)
        .padding(.top, Layout.closeTop - Layout.closeHitSlop)
        .padding(.trailing, Layout.closeTrailing - Layout.closeHitSlop)
    }

    private enum Layout {
        static let designSafeAreaTop: CGFloat = 44
        static let minimumScreenHeight: CGFloat = 761

        static let closeTop: CGFloat = 6
        static let closeTrailing: CGFloat = 16
        static let closeSize: CGFloat = 24
        static let closeCornerRadius: CGFloat = 5
        static let closeHitSlop: CGFloat = 10

        static let titleTop: CGFloat = 214.3
        static let titleToSubtitle: CGFloat = 3.2
        static let sparklesSize = CGSize(width: 21, height: 21.5)
        static let sparklesGap: CGFloat = 1.4
        static let sparklesRise: CGFloat = 1.3

        static let subtitleToAdButton: CGFloat = 16.4
        static let adButtonToFeatures: CGFloat = 20
        static let featuresLeading: CGFloat = 17
        static let featuresTrailing: CGFloat = 13
        static let featuresToPlans: CGFloat = 39
        static let plansHorizontal: CGFloat = 18
        static let planSpacing: CGFloat = 13.5
        static let plansToRenewalNote: CGFloat = 16.8

        static let minimumMiddleSpacing: CGFloat = 16
        static let disclaimerToSubscribe: CGFloat = 18.8
        static let subscribeHorizontal: CGFloat = 16
        static let subscribeToLinks: CGFloat = 20.4
        static let linksBottom: CGFloat = 14.7
    }
}

#Preview {
    PremiumView {}
        .preferredColorScheme(.dark)
}
