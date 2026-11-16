import SwiftUI
import UIKit

final class KeyboardViewController: UIInputViewController {
    private var keyboardController: KeyboardController?
    private var documentInput: DocumentProxyKeyboardInput?
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = KeyboardConfiguration.systemKeyboard(showsGlobeKey: needsInputModeSwitchKey)
        let controller = KeyboardController(configuration: configuration)
        let input = DocumentProxyKeyboardInput(viewController: self)
        controller.textInput = input
        controller.onNextKeyboard = { [weak self] in self?.advanceToNextInputMode() }
        keyboardController = controller
        documentInput = input

        let hosting = UIHostingController(rootView: KeyboardView(controller: controller))
        hosting.safeAreaRegions = []
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(hosting)
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)

        let height = view.heightAnchor.constraint(equalToConstant: KeyboardMetrics.height(for: configuration))
        height.priority = .defaultHigh
        height.isActive = true
        heightConstraint = height

        KeyboardSharedState.recordFullAccess(hasFullAccess)
        updateAppearance()
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
            self.updateAppearance()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KeyboardSharedState.recordFullAccess(hasFullAccess)
        updateAppearance()
        keyboardController?.textDidChange()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        updateAppearance()
        keyboardController?.textDidChange()
    }

    /// Follows the host field's keyboard appearance, like the system keyboard does.
    private func updateAppearance() {
        let isDark: Bool
        switch textDocumentProxy.keyboardAppearance ?? .default {
        case .dark:
            isDark = true
        case .light:
            isDark = false
        default:
            isDark = traitCollection.userInterfaceStyle == .dark
        }
        if keyboardController?.isDarkAppearance != isDark {
            keyboardController?.isDarkAppearance = isDark
        }
    }

    override func selectionDidChange(_ textInput: UITextInput?) {
        super.selectionDidChange(textInput)
        keyboardController?.textDidChange()
    }
}

@MainActor
final class DocumentProxyKeyboardInput: KeyboardTextInput {
    private weak var viewController: UIInputViewController?

    init(viewController: UIInputViewController) {
        self.viewController = viewController
    }

    private var proxy: UITextDocumentProxy? {
        viewController?.textDocumentProxy
    }

    var textBeforeCursor: String {
        proxy?.documentContextBeforeInput ?? ""
    }

    var hasText: Bool {
        proxy?.hasText ?? false
    }

    func insertText(_ text: String) {
        proxy?.insertText(text)
    }

    func deleteBackward() {
        proxy?.deleteBackward()
    }

    func performReturn() {
        proxy?.insertText("\n")
    }
}
