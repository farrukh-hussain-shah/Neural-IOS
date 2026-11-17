enum AccessibilityID {
    static let splashBrand = "splash.brand"
    static let languageTitle = "language.title"
    static let languageDone = "language.done"
    static let onboardingPageIndicator = "onboarding.pageIndicator"
    static let onboardingPrimaryAction = "onboarding.primaryAction"
    static let homeTitle = "home.title"
    static let homePremiumButton = "home.premiumButton"
    static let homeMenuButton = "home.menuButton"
    static let homeEnableKeyboard = "home.enableKeyboard"
    static let homeAllowFullAccess = "home.allowFullAccess"
    static let homeTestField = "home.testField"
    static let settingsTitle = "settings.title"
    static let settingsUpgrade = "settings.upgrade"
    static let settingsToneAdjustment = "settings.toneAdjustment"
    static let settingsHaptics = "settings.haptics"
    static let settingsLanguage = "settings.language"
    static let tonesTitle = "tones.title"
    static let tonesBack = "tones.back"
    static let tonesUpdate = "tones.update"
    static let premiumTitle = "premium.title"
    static let premiumClose = "premium.close"
    static let premiumSubscribe = "premium.subscribe"

    static func premiumPlan(_ plan: PremiumPlan) -> String {
        "premium.plan.\(plan.rawValue)"
    }

    static func keyboardAppearance(_ appearance: KeyboardAppearance) -> String {
        "settings.appearance.\(appearance.rawValue)"
    }

    static func tone(_ tone: AITone) -> String {
        "tones.option.\(tone.rawValue)"
    }

    static func languageOption(_ language: AppLanguage) -> String {
        "language.option.\(language.rawValue)"
    }
}
