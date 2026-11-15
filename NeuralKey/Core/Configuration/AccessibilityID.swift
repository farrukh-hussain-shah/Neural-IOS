enum AccessibilityID {
    static let splashBrand = "splash.brand"
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
}
