import SwiftUI

struct RadialGlowBackground: View {
    struct Glow {
        let center: UnitPoint
        let radiusRatio: CGFloat
        var fadeEnd: CGFloat = 0.75

        static let onboarding = Glow(center: UnitPoint(x: 331.5 / 390, y: 0), radiusRatio: 351 / 390)
        static let languageSelection = Glow(center: UnitPoint(x: 331.5 / 375, y: 0), radiusRatio: 351 / 375)
    }

    let glow: Glow

    var body: some View {
        GeometryReader { proxy in
            RadialGradient(
                stops: AppGradient.smoothFalloff(AppColor.onboardingGlow, peakOpacity: 1, endLocation: glow.fadeEnd),
                center: glow.center,
                startRadius: 0,
                endRadius: proxy.size.width * glow.radiusRatio
            )
        }
        .background(AppColor.onboardingBackground)
        .dithered()
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
