import SwiftUI
import UIKit

enum AppColor {

    // MARK: Brand

    static let primary = Color(hex: 0x0F5BF5)
    static let primaryBright = Color(hex: 0x1462FF)
    static let accent = Color(hex: 0x2E6BFF)
    static let royal = Color(hex: 0x0D59F2)
    static let cyan = Color(hex: 0x06B6D4)
    static let tagline = Color(hex: 0x3B76FF)
    static let highlight = Color(hex: 0x4B86FF)
    static let soft = Color(hex: 0x6B9BFF)
    static let pale = Color(hex: 0x8FB4FF)

    // MARK: Text

    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0x94A3B8)
    static let textTertiary = Color(hex: 0x8593A8)
    static let homeTextSecondary = Color(hex: 0xA9B2C2)
    static let textMuted = Color(hex: 0xB6C0CF)
    static let textSubdued = Color(hex: 0xA6ADB9)
    static let textPlaceholder = Color(hex: 0x8E8E93)

    // MARK: Backgrounds

    static let splashBackground = Color(hex: 0x0D121C)
    static let onboardingBackground = Color(hex: 0x06080D)
    static let onboardingGlow = Color(hex: 0x071833)
    static let homeBackground = Color(hex: 0x050505)

    // MARK: Surfaces

    static let cardSurface = Color(hex: 0x121519)
    static let cardBorder = Color(hex: 0x23272E)
    static let iconTile = Color(hex: 0x1C2331)
    static let selectedSurface = Color(hex: 0x131C2E)
    static let inputSurface = Color(hex: 0x1B1B1B)
    static let controlSurface = Color(hex: 0x1E1E24)
    static let groupedSurface = Color(hex: 0x15181E)
    static let groupedBorder = Color(hex: 0x212124)
    static let groupedDivider = Color(hex: 0x24272D)
    static let groupedFooter = Color(hex: 0x181B24)
    static let tintedTile = Color(hex: 0x152034)
    static let progressTrack = Color(hex: 0x1C2331)

    // MARK: Indicators & Controls

    static let indicatorInactive = Color(hex: 0x2A3344)
    static let stepConnector = Color(hex: 0x232C3B)
    static let stepConnectorCompleted = Color(hex: 0x1F3F8A)
    static let stepCompleted = Color(hex: 0x12244A)
    static let stepPendingBorder = Color(hex: 0x2F394A)
    static let switchTrackOff = Color(hex: 0x282E39)
    static let switchKnob = Color.white
    static let switchKnobBorder = Color(hex: 0xD1D5DB)
    static let chevron = Color(hex: 0x5E606D)

    // MARK: Premium

    static let premiumBackground = Color(hex: 0x050505)
    static let premiumGlow = Color(hex: 0x0D59F2)
    static let premiumSurface = Color.white.opacity(0.1)
    static let premiumDivider = Color.white.opacity(0.2)
    static let premiumTextSecondary = Color.white.opacity(0.7)
    static let premiumLinkSeparator = Color.white.opacity(0.5)
    static let premiumFinePrint = Color(hex: 0x666666)
    static let premiumRadio = Color(hex: 0x0D59F2, opacity: 0.3)
    static let premiumRadioSelected = Color.white.opacity(0.3)
    static let premiumPillSelected = Color.white
    static let premiumPriceSelected = Color.black

    // MARK: Language Selection

    static let optionSurface = Color(hex: 0x111113)
    static let optionBorder = Color(hex: 0x232329)
    static let optionSurfaceSelected = Color(hex: 0x101C32)
    static let optionTile = Color(hex: 0x202125)
    static let optionSubtitle = Color(hex: 0xA3A7B0)
    static let optionSubtitleSelected = Color(hex: 0xB4C7EC)
    static let radioBorder = Color(hex: 0x656973)

    // MARK: Settings

    static let settingsSurface = Color(hex: 0x161920)
    static let settingsBorder = Color.white.opacity(0.05)
    static let settingsUpgradeBorder = Color.white.opacity(0.1)
    static let settingsPill = Color.white.opacity(0.1)
    static let settingsSectionLabel = Color.white.opacity(0.6)
    static let settingsSecondary = Color.white.opacity(0.5)
    static let settingsValue = Color.white.opacity(0.4)
    static let appearanceSystemTop = Color(hex: 0x1D293D)
    static let appearanceSystemInner = Color(hex: 0x1D293D, opacity: 0.8)
    static let appearanceSystemCore = Color(hex: 0x45556C, opacity: 0.5)
    static let appearanceDark = Color(hex: 0x1C1C1E)
    static let appearanceLight = Color(hex: 0xE6E5EA)
    static let appearanceMoon = Color(hex: 0x90A1B9)
    static let appearanceSun = Color(hex: 0x62748E)
    static let appearanceTileBorder = Color.white.opacity(0.1)

    // MARK: AI Tones

    static let tonesBackground = Color(hex: 0x050507)
    static let tonesSubtitle = Color(hex: 0xDBEAFE, opacity: 0.6)
    static let toneAccent = Color(hex: 0x60A5FA)
    static let toneSectionLabel = Color(hex: 0x60A5FA, opacity: 0.8)
    static let toneChipSurface = Color(hex: 0x141419, opacity: 0.6)
    static let toneChipBorder = Color(hex: 0x007FFF, opacity: 0.2)
    static let toneChipBorderSelected = Color(hex: 0x007FFF, opacity: 0.8)
    static let toneChipText = Color.white.opacity(0.9)
    static let toneChipIcon = Color.white.opacity(0.5)
    static let toneGlowBlue = Color(hex: 0x007FFF)
    static let toneGlowRoyal = Color(hex: 0x2563EB)
    static let toneGlowViolet = Color(hex: 0xA855F7)
    static let backButtonSurface = Color.white.opacity(0.05)
    static let backButtonBorder = Color.white.opacity(0.1)
    static let backButtonIcon = Color.white.opacity(0.7)

    // MARK: Keyboard
    // Light values follow the keyboard design (Keyboard Designs/*.svg); dark values follow
    // the iOS dark keyboard, whose background (#2C2C2C) is the strip iOS draws below it.

    static let keyboardPanel = Color(light: 0xE3E3E3, dark: 0x2C2C2C)
    static let keyboardPhonePanel = Color(light: 0xE0E0E0, dark: 0x2C2C2C)
    static let keyboardPanelBorder = Color(light: 0xFFFFFF, lightOpacity: 0.7, dark: 0xFFFFFF, darkOpacity: 0.12)
    static let keyboardPanelHighlight = Color(light: 0xFFFFFF, lightOpacity: 1, dark: 0xFFFFFF, darkOpacity: 0.08)
    static let keyboardKey = Color(light: 0xFCFCFC, dark: 0x6B6B6B)
    static let keyboardKeyPressed = Color(light: 0xC9C9CE, dark: 0x474747)
    static let keyboardLabel = Color(light: 0x565656, dark: 0xFFFFFF)
    static let keyboardPopupLabel = Color(light: 0x000000, dark: 0xFFFFFF)
    static let keyboardPrimary = Color(hex: 0x0088FF)
    static let keyboardPrimaryPressed = Color(hex: 0x0070D6)
    static let keyboardSuggestion = Color(light: 0x000000, dark: 0xFFFFFF)
    static let keyboardDivider = Color(light: 0x000000, lightOpacity: 0.18, dark: 0xFFFFFF, darkOpacity: 0.18)

    // Keyboard glass (toolbar, Improve panel): translucent surfaces over iOS's keyboard glass,
    // from Neural Key IOS Keyboard SVG (light: white 50% on #DADADA, dark: white 13% on #181818).
    static let keyboardGlass = Color(light: 0xFFFFFF, lightOpacity: 0.5, dark: 0xFFFFFF, darkOpacity: 0.13)
    static let keyboardGlassText = Color(light: 0x000000, dark: 0xE6E6E6)
    static let keyboardGlassSecondaryText = Color(light: 0x3C3C43, lightOpacity: 0.62, dark: 0x949494)
    static let keyboardGlassIcon = Color(light: 0x3C3C43, dark: 0xE6E6E6)
    static let keyboardGlassDivider = Color(light: 0x000000, lightOpacity: 0.1, dark: 0xFFFFFF, darkOpacity: 0.1)
    static let keyboardShimmer = Color(light: 0xFFFFFF, lightOpacity: 0.6, dark: 0xFFFFFF, darkOpacity: 0.2)
    static let keyboardAccent = Color(light: 0x0D59F2, dark: 0x0D59F2)
    static let keyboardAccentText = Color(light: 0xF6F6F6, dark: 0xF6F6F6)
    static let keyboardAccentBorder = Color(light: 0x5E8FF7, dark: 0x5E8FF7)
    static let keyboardSystemIcon = Color(light: 0x000000, lightOpacity: 0.5, dark: 0xFFFFFF, darkOpacity: 0.6)
    static let keyboardPopupShadow = Color(light: 0x000000, lightOpacity: 0.22, dark: 0x000000, darkOpacity: 0.5)
    static let keyboardPopupBorder = Color(light: 0x000000, lightOpacity: 0.08, dark: 0xFFFFFF, darkOpacity: 0.08)

    // MARK: Ads

    static let adSurface = Color(hex: 0x111113)
    static let adBorder = Color(hex: 0x12C0C0, opacity: 0.1)
    static let adIconTile = Color(hex: 0x222222)
    static let adBadge = Color(hex: 0xFEA613)
    static let adBadgeText = Color(hex: 0x0D0D0D)
}

enum AppGradient {
    static let brand = LinearGradient(
        colors: [AppColor.royal, AppColor.cyan],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let toneSelected = LinearGradient(
        colors: [Color(hex: 0x007FFF, opacity: 0.25), Color(hex: 0x007FFF, opacity: 0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let appearanceSystem = LinearGradient(
        colors: [AppColor.appearanceSystemTop, .black],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let upgradeCard = LinearGradient(
        colors: [Color.white.opacity(0.08), Color.white.opacity(0)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let brandReversed = LinearGradient(
        colors: [AppColor.cyan, AppColor.royal],
        startPoint: .leading,
        endPoint: .trailing
    )

    static func smoothFalloff(
        _ color: Color,
        peakOpacity: Double,
        endLocation: CGFloat,
        steps: Int = 16
    ) -> [Gradient.Stop] {
        (0...steps).map { step in
            let progress = Double(step) / Double(steps)
            let falloff = (1 - progress) * (1 - progress) * (1 + 2 * progress)
            return Gradient.Stop(
                color: color.opacity(peakOpacity * falloff),
                location: endLocation * CGFloat(progress)
            )
        }
    }
}

extension Color {
    /// A colour that follows the light or dark colour scheme of the view showing it.
    init(light: UInt32, lightOpacity: Double = 1, dark: UInt32, darkOpacity: Double = 1) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark, alpha: darkOpacity)
                : UIColor(hex: light, alpha: lightOpacity)
        })
    }

    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

private extension UIColor {
    convenience init(hex: UInt32, alpha: Double) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
