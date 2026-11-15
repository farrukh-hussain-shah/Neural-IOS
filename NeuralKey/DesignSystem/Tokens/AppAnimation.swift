import SwiftUI

enum AppAnimation {
    static let pageIndicator = Animation.spring(response: 0.45, dampingFraction: 0.82)
    static let onboardingContent = Animation.spring(response: 0.5, dampingFraction: 0.9)
    static let selection = Animation.spring(response: 0.38, dampingFraction: 0.8)

    static let onboardingPage = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )
}
