import SwiftUI
import UIKit

final class KeyboardInputView: UIInputView, UIInputViewAudioFeedback {
    private let hostingController: UIHostingController<KeyboardView>

    var enableInputClicksWhenVisible: Bool { true }

    init(controller: KeyboardController) {
        let height = KeyboardMetrics.height(for: controller.configuration)
        let hosting = UIHostingController(rootView: KeyboardView(controller: controller))
        hosting.safeAreaRegions = []
        hostingController = hosting
        super.init(
            frame: CGRect(x: 0, y: 0, width: AppScale.screenWidth, height: height),
            inputViewStyle: .default
        )
        allowsSelfSizing = true
        backgroundColor = .clear
        clipsToBounds = false

        let hostedView: UIView = hostingController.view
        hostedView.backgroundColor = .clear
        hostedView.clipsToBounds = false
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostedView)
        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostedView.topAnchor.constraint(equalTo: topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: height)
        ])

        controller.onInputClick = { UIDevice.current.playInputClick() }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}
