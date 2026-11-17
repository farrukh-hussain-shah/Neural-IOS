import SwiftUI

struct SettingsDrawer: View {
    let store: SettingsStore
    let languageStore: LanguageStore
    let onUpgrade: @MainActor () -> Void
    let onClose: @MainActor () -> Void

    /// A page opened from Settings, sliding in over it from the right.
    private enum Page {
        case tones
        case language
    }

    @State private var page: Page?
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                SettingsView(
                    store: store,
                    language: languageStore.selectedLanguage,
                    onUpgrade: onUpgrade,
                    onToneAdjustment: { open(.tones) },
                    onLanguage: { open(.language) }
                )
                .offset(x: page != nil ? 0 : dragOffset)

                switch page {
                case .tones:
                    AIToneSelectionView(store: store, onClose: closePage)
                        .offset(x: dragOffset)
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                case .language:
                    // Picking a language changes the whole app at once; Done returns to Settings.
                    LanguageSelectionView(store: languageStore, onDone: closePage)
                        .offset(x: dragOffset)
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                case nil:
                    EmptyView()
                }
            }
            .simultaneousGesture(swipeToGoBack(width: proxy.size.width))
        }
    }

    private func open(_ page: Page) {
        withAnimation(AppAnimation.drawer) { self.page = page }
    }

    private func closePage() {
        withAnimation(AppAnimation.drawer) { page = nil }
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
                        if page != nil {
                            page = nil
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
