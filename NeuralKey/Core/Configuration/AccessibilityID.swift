enum AccessibilityID {
    static let splashBrand = "splash.brand"
    static let languageTitle = "language.title"
    static let languageDone = "language.done"
    static let onboardingPageIndicator = "onboarding.pageIndicator"
    static let onboardingPrimaryAction = "onboarding.primaryAction"
    static let homeTitle = "home.title"
    static let homePremiumButton = "home.premiumButton"
    static let premiumTitle = "premium.title"
    static let premiumClose = "premium.close"
    static let premiumSubscribe = "premium.subscribe"

    static func premiumPlan(_ plan: PremiumPlan) -> String {
        "premium.plan.\(plan.rawValue)"
    }

    static func languageOption(_ language: AppLanguage) -> String {
        "language.option.\(language.rawValue)"
    }
}
