import SwiftUI

struct SettingsDrawer: View {
    let store: SettingsStore
    let onUpgrade: @MainActor () -> Void
    let onClose: @MainActor () -> Void

    @State private var isShowingTones = false
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                SettingsView(store: store, onUpgrade: onUpgrade) {
                    withAnimation(AppAnimation.drawer) { isShowingTones = true }
                }
                .offset(x: isShowingTones ? 0 : dragOffset)

                if isShowingTones {
                    AIToneSelectionView(store: store) {
                        withAnimation(AppAnimation.drawer) { isShowingTones = false }
                    }
                    .offset(x: dragOffset)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                }
            }
            .simultaneousGesture(swipeToGoBack(width: proxy.size.width))
        }
    }

    private func swipeToGoBack(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: Layout.minimumDragDistance, coordinateSpace: .global)
            .onChanged { value in
                let horizontal = value.translation.width
                guard horizontal > 0, horizontal > abs(value.translation.height) else { return }
                dragOffset = horizontal
            }
            .onEnded { value in
                let didDragHorizontally = dragOffset > 0
                let shouldGoBack = didDragHorizontally
                    && (dragOffset > width * Layout.dismissDistanceRatio
                        || value.predictedEndTranslation.width > width * Layout.dismissPredictedRatio)
                withAnimation(AppAnimation.drawer) {
                    dragOffset = 0
                    if shouldGoBack {
                        if isShowingTones {
                            isShowingTones = false
                        } else {
                            onClose()
                        }
                    }
                }
            }
    }

    private enum Layout {
        static let minimumDragDistance: CGFloat = 16
        static let dismissDistanceRatio: CGFloat = 0.3
        static let dismissPredictedRatio: CGFloat = 0.5
    }
}
