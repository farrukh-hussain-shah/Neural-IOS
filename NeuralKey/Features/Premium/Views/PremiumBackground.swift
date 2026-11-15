import SwiftUI

struct PremiumBackground: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                AppColor.premiumBackground

                ForEach(Glow.all) { glow in
                    Ellipse()
                        .fill(AppColor.premiumGlow)
                        .frame(width: glow.size.width.compactScaled, height: glow.size.height.compactScaled)
                        .blur(radius: glow.blur.compactScaled)
                        .opacity(glow.opacity)
                        .position(
                            x: proxy.size.width / 2 + (glow.center.x - Layout.designCenterX).compactScaled,
                            y: glow.center.y.compactScaled
                        )
                }

                Image(AppImage.premiumNetwork)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Layout.networkSide, height: Layout.networkSide)
                    .clipped()
                    .offset(x: Layout.networkOrigin.x, y: Layout.networkOrigin.y)

                scrim
            }
            .dithered()
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private var scrim: some View {
        VStack(spacing: 0) {
            AppColor.premiumBackground
                .opacity(Layout.scrimBaseOpacity)
                .frame(height: Layout.scrimFadeStart)
            LinearGradient(
                stops: [
                    .init(color: AppColor.premiumBackground.opacity(Layout.scrimBaseOpacity), location: 0),
                    .init(color: AppColor.premiumBackground.opacity(Layout.scrimBaseOpacity), location: 0.4386),
                    .init(color: AppColor.premiumBackground.opacity(0.825), location: 0.671),
                    .init(color: AppColor.premiumBackground, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Layout.scrimFadeLength)
            AppColor.premiumBackground
        }
    }

    private enum Layout {
        static let designCenterX: CGFloat = 187.5
        static let networkOrigin = CGPoint(x: (-2).compactScaled, y: 4.compactScaled)
        static let networkSide: CGFloat = 375.compactScaled
        static let scrimBaseOpacity: Double = 0.6
        static let scrimFadeStart: CGFloat = 351.8.compactScaled
        static let scrimFadeLength: CGFloat = 103.5.compactScaled
    }

    private struct Glow: Identifiable {
        let id: Int
        let center: CGPoint
        let size: CGSize
        let opacity: Double
        let blur: CGFloat

        static let all = [
            Glow(id: 0, center: CGPoint(x: 178.5, y: 124.5), size: CGSize(width: 343, height: 233), opacity: 0.1, blur: 100),
            Glow(id: 1, center: CGPoint(x: 185, y: 385), size: CGSize(width: 352, height: 352), opacity: 0.3, blur: 100),
            Glow(id: 2, center: CGPoint(x: 187, y: 583), size: CGSize(width: 266, height: 266), opacity: 0.3, blur: 125),
            Glow(id: 3, center: CGPoint(x: 187, y: 890), size: CGSize(width: 378, height: 378), opacity: 0.3, blur: 125)
        ]
    }
}
