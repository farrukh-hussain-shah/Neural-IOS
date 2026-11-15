import SwiftUI

struct AppShadow {
    let color: Color
    let radius: CGFloat
    var x: CGFloat = 0
    var y: CGFloat = 0
}

extension AppShadow {
    static let inputDepth = AppShadow(color: .black.opacity(0.1), radius: 12.5, y: 20)
}

extension View {
    func appShadow(_ shadow: AppShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
