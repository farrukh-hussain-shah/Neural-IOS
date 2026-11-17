import Observation
import SwiftUI

@MainActor
@Observable
final class InAppKeyboardPresenter {
    private(set) var controller: KeyboardController?

    var isVisible: Bool {
        controller != nil
    }

    func show(_ controller: KeyboardController) {
        self.controller = controller
    }

    func hide(_ controller: KeyboardController) {
        if self.controller === controller {
            self.controller = nil
        }
    }
}

private struct InAppKeyboardHost: ViewModifier {
    let presenter: InAppKeyboardPresenter

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack(alignment: .bottom) {
                    Color.clear
                        .allowsHitTesting(false)
                    if let controller = presenter.controller {
                        KeyboardView(controller: controller)
                            .transition(.move(edge: .bottom))
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .animation(.spring(response: 0.38, dampingFraction: 1), value: presenter.isVisible)
            .environment(presenter)
    }
}

extension View {
    func inAppKeyboardHost(_ presenter: InAppKeyboardPresenter) -> some View {
        modifier(InAppKeyboardHost(presenter: presenter))
    }
}
