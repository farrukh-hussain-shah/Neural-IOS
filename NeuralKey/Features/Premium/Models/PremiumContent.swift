import SwiftUI

struct PremiumFeature: Identifiable {
    let id: String
    let title: LocalizedStringKey
}

struct PremiumContent {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let rewardedAdTitle: LocalizedStringKey
    let rewardedAdSubtitle: LocalizedStringKey
    let features: [PremiumFeature]
    let plans: [PremiumPlanOption]
    let renewalNote: LocalizedStringKey
    let trialDisclaimer: LocalizedStringKey
    let subscribeTitle: LocalizedStringKey
    let restoreTitle: LocalizedStringKey
    let termsTitle: LocalizedStringKey
    let privacyTitle: LocalizedStringKey
}

extension PremiumContent {
    static let standard = PremiumContent(
        title: "Upgrade to Premium",
        subtitle: "Unlock All Features",
        rewardedAdTitle: "Watch Ad to Unlock",
        rewardedAdSubtitle: "to get Premium for 7 days (0/5)",
        features: [
            PremiumFeature(id: "ai-rewrites", title: "Unlimited AI Rewrites"),
            PremiumFeature(id: "voice-transcribe", title: "Unlimited Voice Transcribe"),
            PremiumFeature(id: "translation", title: "Unlimited Translation"),
            PremiumFeature(id: "ad-free", title: "100% Ad Free")
        ],
        plans: [
            PremiumPlanOption(plan: .weekly, title: "Weekly", price: "20$", billingUnit: "/ week", savings: "30%"),
            PremiumPlanOption(
                plan: .monthly,
                title: "Monthly",
                price: "40$",
                billingUnit: "/ week",
                savings: "10%",
                badge: "50%OFF"
            ),
            PremiumPlanOption(plan: .yearly, title: "Yearly", price: "90$", billingUnit: "/ week", savings: "30%")
        ],
        renewalNote: "Auto renewal, Cancel anytime",
        trialDisclaimer: "Free premium for 3 days! After that, Rs 280.00/Week,\nCancel anytime before trial ends to avoid changes.",
        subscribeTitle: "Subscribe Now",
        restoreTitle: "Restore",
        termsTitle: "Terms of Use",
        privacyTitle: "Privacy Policy"
    )
}
