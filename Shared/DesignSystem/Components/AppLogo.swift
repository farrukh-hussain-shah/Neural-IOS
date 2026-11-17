import SwiftUI

struct AppLogo: View {
    let size: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        Image(AppImage.logo)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .accessibilityHidden(true)
    }
}
