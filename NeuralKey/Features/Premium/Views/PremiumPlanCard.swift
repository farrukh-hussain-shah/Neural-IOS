import SwiftUI

struct PremiumPlanCard: View {
    let option: PremiumPlanOption
    let isSelected: Bool
    let selectionNamespace: Namespace.ID
    let onSelect: @MainActor () -> Void

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                Text(option.title)
                    .textStyle(.premiumPlanTitle)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, Layout.titleTop)

                Capsule()
                    .fill(AppColor.premiumDivider)
                    .frame(height: Layout.dividerThickness)
                    .padding(.horizontal, Layout.dividerInset)
                    .padding(.top, Layout.titleToDivider)

                priceTag
                    .padding(.horizontal, Layout.priceInset)
                    .padding(.top, Layout.dividerToPrice)

                savingsLabel
                    .padding(.top, Layout.priceToSavings)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Layout.height)
            .background { background }
            .overlay(alignment: .topTrailing) {
                PremiumRadio(isSelected: isSelected)
                    .padding(.top, Layout.radioTop)
                    .padding(.trailing, Layout.radioTrailing)
            }
            .overlay(alignment: .top) {
                if let badge = option.badge {
                    PremiumBadge(title: badge)
                        .offset(y: -PremiumBadge.height / 2)
                }
            }
            .contentShape(cardShape)
        }
        .buttonStyle(.pressable)
        .animation(AppAnimation.selection, value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier(AccessibilityID.premiumPlan(option.plan))
    }

    private var background: some View {
        ZStack {
            cardShape.fill(AppColor.premiumSurface)
            if isSelected {
                cardShape
                    .fill(AppGradient.brand)
                    .matchedGeometryEffect(id: Self.selectionHighlightID, in: selectionNamespace)
            }
        }
    }

    private var priceTag: some View {
        let priceStyle: AppTextStyle = isSelected ? .premiumPlanPriceSelected : .premiumPlanPrice
        let unitFont = AppTextStyle.premiumPlanUnit.font
        let shadow = AppShadow.premiumPill
        let label = Text(verbatim: option.price).font(priceStyle.font)
            + Text(verbatim: " ").font(unitFont)
            + Text(option.billingUnit).font(unitFont)
        return label
            .foregroundStyle(isSelected ? AppColor.premiumPriceSelected : AppColor.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
            .frame(height: Layout.priceHeight)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(isSelected ? AppColor.premiumPillSelected : AppColor.premiumSurface)
                    .shadow(color: isSelected ? .clear : shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
            }
    }

    private var savingsLabel: some View {
        let label = Text(verbatim: "\(option.savings) ").font(AppTextStyle.premiumPlanSaving.font)
            + Text("Save").font(AppTextStyle.premiumPlanUnit.font)
        return label
            .foregroundStyle(AppColor.textPrimary)
            .lineLimit(1)
    }

    private static let selectionHighlightID = "premium.selectionHighlight"

    private enum Layout {
        static let height: CGFloat = 113.compactScaled
        static let titleTop: CGFloat = 11.5.compactScaled
        static let titleToDivider: CGFloat = 11.9.compactScaled
        static let dividerThickness: CGFloat = 0.5.compactScaled
        static let dividerInset: CGFloat = 12.compactScaled
        static let dividerToPrice: CGFloat = 11.75.compactScaled
        static let priceInset: CGFloat = 13.compactScaled
        static let priceHeight: CGFloat = 26.compactScaled
        static let priceToSavings: CGFloat = 12.6.compactScaled
        static let radioTop: CGFloat = 8.3.compactScaled
        static let radioTrailing: CGFloat = 8.1.compactScaled
    }
}

private struct PremiumRadio: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(isSelected ? AppColor.premiumRadioSelected : AppColor.premiumRadio, lineWidth: Layout.ringWidth)
            Circle()
                .fill(AppColor.textPrimary)
                .frame(width: Layout.dotDiameter, height: Layout.dotDiameter)
                .scaleEffect(isSelected ? 1 : 0.2)
                .opacity(isSelected ? 1 : 0)
        }
        .frame(width: Layout.diameter, height: Layout.diameter)
        .accessibilityHidden(true)
    }

    private enum Layout {
        static let diameter: CGFloat = 12.5.compactScaled
        static let ringWidth: CGFloat = 1.25.compactScaled
        static let dotDiameter: CGFloat = 7.5.compactScaled
    }
}

private struct PremiumBadge: View {
    static let height: CGFloat = 18.compactScaled

    let title: LocalizedStringKey

    var body: some View {
        Text(title)
            .textStyle(.premiumBadge)
            .foregroundStyle(AppColor.textPrimary)
            .frame(width: Layout.width, height: Self.height)
            .background(Capsule().fill(AppGradient.brandReversed))
    }

    private enum Layout {
        static let width: CGFloat = 54.compactScaled
    }
}
