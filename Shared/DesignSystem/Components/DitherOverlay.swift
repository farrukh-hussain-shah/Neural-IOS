import SwiftUI

struct DitherOverlay: View {
    var body: some View {
        Image(AppImage.ditherNoise)
            .resizable(resizingMode: .tile)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

extension View {
    func dithered() -> some View {
        overlay { DitherOverlay() }
    }
}
