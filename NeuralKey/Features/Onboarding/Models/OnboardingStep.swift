import SwiftUI

enum OnboardingStep: Int, CaseIterable, Hashable {
    case welcome
    case addKeyboard
    case allowFullAccess

    static let first: OnboardingStep = .welcome

    var next: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }

    var pageIndex: Int { rawValue }

    var opensKeyboardSettings: Bool {
        self != .welcome
    }

    var primaryAction: OnboardingAction {
        switch self {
        case .welcome: .setUpKeyboard
        case .addKeyboard, .allowFullAccess: .openSettings
        }
    }

    var footnote: OnboardingFootnote {
        switch self {
        case .welcome: .message("Setup takes three short steps")
        case .addKeyboard: .legalConsent
        case .allowFullAccess: .message("You can turn this off any time in Settings")
        }
    }
}

struct OnboardingAction {
    let title: LocalizedStringKey
    let icon: AppIcon

    static let setUpKeyboard = OnboardingAction(title: "Set Up Keyboard", icon: .arrowRight)
    static let openSettings = OnboardingAction(title: "Open Settings", icon: .externalLink)
}

enum OnboardingFootnote {
    case message(LocalizedStringKey)
    case legalConsent
}
