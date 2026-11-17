import SwiftUI

extension View {
    /// Keeps a button title on one line in every language: it shrinks slightly first, and if it
    /// still doesn't fit it ends in "…" instead of wrapping onto a second line.
    func singleLineLabel(minimumScale: CGFloat = 0.85) -> some View {
        lineLimit(1)
            .minimumScaleFactor(minimumScale)
            .truncationMode(.tail)
    }
}
