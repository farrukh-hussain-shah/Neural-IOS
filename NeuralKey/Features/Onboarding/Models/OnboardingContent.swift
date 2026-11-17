import SwiftUI

struct OnboardingHeadline {
    let primary: LocalizedStringKey
    let accent: LocalizedStringKey
}

struct FeatureHighlight: Identifiable {
    let id: String
    let icon: AppIcon
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
}

struct WelcomeContent {
    let headline: OnboardingHeadline
    let message: LocalizedStringKey
    let features: [FeatureHighlight]
}

struct SetupStepItem: Identifiable {
    enum Status {
        case completed
        case active
        case pending
    }

    let number: Int
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    let status: Status
    var toggleTitle: LocalizedStringKey?
    var note: LocalizedStringKey?

    var id: Int { number }
}

struct SetupContent {
    let eyebrow: LocalizedStringKey
    let headline: OnboardingHeadline
    let steps: [SetupStepItem]
}

extension WelcomeContent {
    static let standard = WelcomeContent(
        headline: OnboardingHeadline(primary: "Better replies,", accent: "one tap away."),
        message: "Neural Key is an AI keyboard for iPhone. It works inside the apps you already chat in.",
        features: [
            FeatureHighlight(
                id: "fix-grammar",
                icon: .fixGrammar,
                title: "Fix Grammar",
                subtitle: "Typos and punctuation, cleaned up"
            ),
            FeatureHighlight(
                id: "change-tone",
                icon: .changeTone,
                title: "Change Tone",
                subtitle: "Friendly, formal, persuasive and more"
            ),
            FeatureHighlight(
                id: "translate",
                icon: .translate,
                title: "Translate",
                subtitle: "Reply in another language"
            )
        ]
    )
}

extension SetupContent {
    static let addKeyboard = SetupContent(
        eyebrow: "SETUP · 1 OF 3",
        headline: OnboardingHeadline(primary: "Turn on", accent: "Neural Key"),
        steps: [
            SetupStepItem(
                number: 1,
                title: "Add the keyboard",
                detail: "Tap Open Settings, choose Keyboards, then switch Neural Key on.",
                status: .active,
                toggleTitle: "Neural Key"
            ),
            SetupStepItem(
                number: 2,
                title: "Allow Full Access",
                detail: "So the AI can rewrite your text",
                status: .pending
            )
        ]
    )

    static let allowFullAccess = SetupContent(
        eyebrow: "SETUP · 2 OF 3",
        headline: OnboardingHeadline(primary: "Allow", accent: "Full Access"),
        steps: [
            SetupStepItem(
                number: 1,
                title: "Add the keyboard",
                detail: "Neural Key is on",
                status: .completed
            ),
            SetupStepItem(
                number: 2,
                title: "Allow Full Access",
                detail: "Back in Settings, switch on Allow Full Access, then tap Allow to confirm.",
                status: .active,
                toggleTitle: "Allow Full Access",
                note: "It connects the keyboard to Neural Key’s AI. iOS still uses its own keyboard for passwords."
            )
        ]
    )
}
