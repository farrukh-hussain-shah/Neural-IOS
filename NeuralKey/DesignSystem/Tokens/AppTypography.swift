import CoreText
import SwiftUI
import UIKit

enum AppFontFamily {
    case brand
    case system
}

enum AppFontWeight {
    case light
    case regular
    case medium
    case semibold
    case bold

    fileprivate var axisValue: CGFloat {
        switch self {
        case .light: 300
        case .regular: 400
        case .medium: 500
        case .semibold: 600
        case .bold: 700
        }
    }

    fileprivate var systemWeight: UIFont.Weight {
        switch self {
        case .light: .light
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        }
    }
}

struct AppTextStyle {
    let family: AppFontFamily
    let weight: AppFontWeight
    let size: CGFloat
    let lineHeight: CGFloat?
    let tracking: CGFloat

    init(
        family: AppFontFamily = .brand,
        weight: AppFontWeight,
        size: CGFloat,
        lineHeight: CGFloat? = nil,
        tracking: CGFloat = 0,
        reference: AppScale.Reference = .standard
    ) {
        let scale = AppScale.scaleFactor(for: reference)
        self.family = family
        self.weight = weight
        self.size = size * scale
        self.lineHeight = lineHeight.map { $0 * scale }
        self.tracking = tracking * scale
    }

    var uiFont: UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight.systemWeight)
        switch family {
        case .brand: return BrandFont.font(weight: weight, size: size) ?? systemFont
        case .system: return systemFont
        }
    }

    var font: Font {
        Font(uiFont as CTFont)
    }
}

private enum BrandFont {
    static let postScriptName = "SpaceGrotesk-Light"
    static let weightAxisTag = 0x7767_6874

    static func font(weight: AppFontWeight, size: CGFloat) -> UIFont? {
        guard let base = UIFont(name: postScriptName, size: size) else { return nil }
        let variation = UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)
        let descriptor = base.fontDescriptor.addingAttributes([variation: [weightAxisTag: weight.axisValue]])
        return UIFont(descriptor: descriptor, size: size)
    }
}

extension AppTextStyle {

    // MARK: Splash

    static let splashTitle = AppTextStyle(weight: .bold, size: 38, tracking: -1.08)
    static let splashTagline = AppTextStyle(weight: .semibold, size: 13, tracking: 2)

    // MARK: Onboarding

    static let headline = AppTextStyle(weight: .bold, size: 34, lineHeight: 38, tracking: -0.34)
    static let eyebrow = AppTextStyle(weight: .semibold, size: 13, tracking: 1)
    static let bodyLarge = AppTextStyle(weight: .regular, size: 16, lineHeight: 24)
    static let body = AppTextStyle(weight: .regular, size: 14, lineHeight: 21)
    static let cardTitle = AppTextStyle(weight: .medium, size: 17)
    static let stepTitle = AppTextStyle(weight: .medium, size: 18)
    static let stepTitleInactive = AppTextStyle(weight: .medium, size: 17)
    static let stepNumber = AppTextStyle(weight: .semibold, size: 14)
    static let controlLabel = AppTextStyle(weight: .semibold, size: 16)
    static let note = AppTextStyle(weight: .regular, size: 13, lineHeight: 18)

    // MARK: Home

    static let brandName = AppTextStyle(weight: .bold, size: 14, reference: .narrow)
    static let homeTitle = AppTextStyle(weight: .bold, size: 25, reference: .narrow)
    static let homeSubtitle = AppTextStyle(weight: .regular, size: 14, lineHeight: 17.5, reference: .narrow)
    static let sectionLabel = AppTextStyle(weight: .medium, size: 12, tracking: -0.15, reference: .narrow)
    static let sectionLabelStrong = AppTextStyle(weight: .bold, size: 12, reference: .narrow)
    static let input = AppTextStyle(weight: .regular, size: 14, reference: .narrow)
    static let rowTitle = AppTextStyle(weight: .medium, size: 15, reference: .narrow)
    static let rowSubtitle = AppTextStyle(weight: .regular, size: 10.5, reference: .narrow)
    static let chip = AppTextStyle(weight: .medium, size: 10, reference: .narrow)
    static let chipBadge = AppTextStyle(weight: .bold, size: 5.5, reference: .narrow)

    // MARK: Premium

    static let premiumTitle = AppTextStyle(weight: .bold, size: 26, reference: .compact)
    static let premiumSubtitle = AppTextStyle(weight: .regular, size: 14, tracking: -0.6, reference: .compact)
    static let premiumAdTitle = AppTextStyle(family: .system, weight: .bold, size: 13, reference: .compact)
    static let premiumAdSubtitle = AppTextStyle(family: .system, weight: .regular, size: 8.5, reference: .compact)
    static let premiumFeature = AppTextStyle(weight: .medium, size: 10, tracking: -0.55, reference: .compact)
    static let premiumBadge = AppTextStyle(weight: .regular, size: 8, tracking: 0.3, reference: .compact)
    static let premiumPlanTitle = AppTextStyle(family: .system, weight: .semibold, size: 12, reference: .compact)
    static let premiumPlanPrice = AppTextStyle(family: .system, weight: .medium, size: 11, reference: .compact)
    static let premiumPlanPriceSelected = AppTextStyle(family: .system, weight: .semibold, size: 11, reference: .compact)
    static let premiumPlanUnit = AppTextStyle(family: .system, weight: .regular, size: 8, reference: .compact)
    static let premiumPlanSaving = AppTextStyle(family: .system, weight: .medium, size: 10, reference: .compact)
    static let premiumFinePrint = AppTextStyle(family: .system, weight: .light, size: 9.5, reference: .compact)
    static let premiumDisclaimer = AppTextStyle(weight: .regular, size: 11, lineHeight: 16, reference: .compact)
    static let premiumButton = AppTextStyle(weight: .semibold, size: 16, tracking: -0.65, reference: .compact)
    static let premiumLink = AppTextStyle(family: .system, weight: .regular, size: 10, reference: .compact)

    // MARK: Language Selection

    static let languageTitle = AppTextStyle(weight: .bold, size: 22, reference: .compact)
    static let languageSubtitle = AppTextStyle(weight: .regular, size: 12, reference: .compact)
    static let languageDone = AppTextStyle(weight: .semibold, size: 12, reference: .compact)
    static let languageOptionTitle = AppTextStyle(weight: .medium, size: 14, reference: .compact)
    static let languageOptionSubtitle = AppTextStyle(weight: .regular, size: 10, reference: .compact)

    // MARK: Settings

    static let settingsTitle = AppTextStyle(weight: .bold, size: 22.5, reference: .narrow)
    static let settingsCardTitle = AppTextStyle(weight: .bold, size: 14, reference: .narrow)
    static let settingsCardSubtitle = AppTextStyle(weight: .regular, size: 10.5, reference: .narrow)
    static let settingsPill = AppTextStyle(weight: .semibold, size: 10, reference: .narrow)
    static let settingsSection = AppTextStyle(weight: .semibold, size: 11.5, reference: .narrow)
    static let settingsRowTitle = AppTextStyle(weight: .medium, size: 14, reference: .narrow)
    static let settingsRowValue = AppTextStyle(weight: .regular, size: 12, reference: .narrow)
    static let settingsTileLabel = AppTextStyle(weight: .medium, size: 11.5, reference: .narrow)

    // MARK: AI Tones

    static let tonesTitle = AppTextStyle(weight: .bold, size: 23, reference: .narrow)
    static let tonesSubtitle = AppTextStyle(weight: .regular, size: 14, reference: .narrow)
    static let tonesSection = AppTextStyle(weight: .semibold, size: 10, reference: .narrow)
    static let toneChip = AppTextStyle(weight: .semibold, size: 11.5, reference: .narrow)
    static let tonesAction = AppTextStyle(weight: .semibold, size: 15, reference: .narrow)

    // MARK: Ads

    static let adTitle = AppTextStyle(weight: .medium, size: 16, reference: .compact)
    static let adSubtitle = AppTextStyle(weight: .regular, size: 12, reference: .compact)
    static let adBadge = AppTextStyle(weight: .semibold, size: 8, reference: .compact)
    static let adAction = AppTextStyle(weight: .semibold, size: 16, reference: .compact)

    // MARK: Shared

    static let button = AppTextStyle(weight: .semibold, size: 17)
    static let caption = AppTextStyle(weight: .regular, size: 13)
    static let captionEmphasized = AppTextStyle(weight: .semibold, size: 13)
}

private struct AppTextStyleModifier: ViewModifier {
    let style: AppTextStyle

    func body(content: Content) -> some View {
        let font = style.uiFont
        let extraLeading = (style.lineHeight ?? font.lineHeight) - font.lineHeight
        return content
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(max(extraLeading, 0))
            .padding(.vertical, extraLeading / 2)
    }
}

extension View {
    func textStyle(_ style: AppTextStyle) -> some View {
        modifier(AppTextStyleModifier(style: style))
    }
}
