import SwiftUI

struct AppShadow {
    let color: Color
    let radius: CGFloat
    var x: CGFloat = 0
    var y: CGFloat = 0
    var spread: CGFloat = 0
}

extension AppShadow {
    static let primaryButton = AppShadow(color: AppColor.primary.opacity(0.6), radius: 16, y: 12, spread: -8)
    static let splashLogoDepth = AppShadow(color: .black.opacity(0.7), radius: 12, y: 10)
    static let splashLogoGlow = AppShadow(color: AppColor.primary.opacity(0.55), radius: 22, y: 18)
    static let headerLogoGlow = AppShadow(color: AppColor.royal.opacity(0.5), radius: 10)
    static let inputDepth = AppShadow(color: .black.opacity(0.1), radius: 12.5, y: 20)
}

extension View {
    func appShadow(_ shadow: AppShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    func appShadow<S: Shape>(_ shadow: AppShadow, in shape: S) -> some View {
        background {
            shape
                .fill(shadow.color)
                .padding(-shadow.spread)
                .offset(x: shadow.x, y: shadow.y)
                .blur(radius: shadow.radius)
        }
    }
}
