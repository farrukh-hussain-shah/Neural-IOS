import SwiftUI

enum AppColor {

    // MARK: Brand

    static let primary = Color(hex: 0x0F5BF5)
    static let primaryBright = Color(hex: 0x1462FF)
    static let accent = Color(hex: 0x2E6BFF)
    static let royal = Color(hex: 0x0D59F2)
    static let azure = Color(hex: 0x007FFF)
    static let cyan = Color(hex: 0x06B6D4)
    static let tagline = Color(hex: 0x3B76FF)
    static let highlight = Color(hex: 0x4B86FF)
    static let soft = Color(hex: 0x6B9BFF)
    static let pale = Color(hex: 0x8FB4FF)
    static let chipBorder = Color(hex: 0x1978E5, opacity: 0.4)

    // MARK: Text

    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0x94A3B8)
    static let textTertiary = Color(hex: 0x8593A8)
    static let textMuted = Color(hex: 0xB6C0CF)
    static let textSubdued = Color(hex: 0x9CA6BA)
    static let textPlaceholder = Color(hex: 0x475569)
    static let textOnAccent = Color(hex: 0xF2F2F7)

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
    static let inputSurface = Color(hex: 0x1A1A1C)
    static let inputGlow = Color(hex: 0x0D59F2, opacity: 0.25)
    static let controlSurface = Color(hex: 0x1E1F24)
    static let groupedSurface = Color.white.opacity(0.05)
    static let groupedBorder = Color.white.opacity(0.05)
    static let groupedFooter = Color(hex: 0x1A202C, opacity: 0.6)
    static let tintedTile = Color(hex: 0x06B6D4, opacity: 0.1)
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
    static let chevron = Color(hex: 0x586175)

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
}

enum AppGradient {
    static let brand = LinearGradient(
        colors: [AppColor.royal, AppColor.cyan],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let brandReversed = LinearGradient(
        colors: [AppColor.cyan, AppColor.royal],
        startPoint: .leading,
        endPoint: .trailing
    )
}

extension Color {
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
