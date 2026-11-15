import SwiftUI

struct PremiumBackground: View {
    let topInsetDelta: CGFloat

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                AppColor.premiumBackground

                ForEach(Glow.all) { glow in
                    Ellipse()
                        .fill(AppColor.premiumGlow)
                        .frame(width: glow.size.width, height: glow.size.height)
                        .blur(radius: glow.blur)
                        .opacity(glow.opacity)
                        .position(
                            x: proxy.size.width / 2 + glow.center.x - Layout.designCenterX,
                            y: glow.center.y + topInsetDelta
                        )
                }

                Image(AppImage.premiumNetwork)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: Layout.networkHeight)
                    .clipped()
                    .offset(x: Layout.networkOrigin.x, y: Layout.networkOrigin.y + topInsetDelta)

                scrim
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private var scrim: some View {
        VStack(spacing: 0) {
            AppColor.premiumBackground
                .opacity(Layout.scrimBaseOpacity)
                .frame(height: max(Layout.scrimFadeStart + topInsetDelta, 0))
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
        static let networkOrigin = CGPoint(x: -2, y: 4)
        static let networkHeight: CGFloat = 375
        static let scrimBaseOpacity: Double = 0.6
        static let scrimFadeStart: CGFloat = 351.8
        static let scrimFadeLength: CGFloat = 103.5
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
