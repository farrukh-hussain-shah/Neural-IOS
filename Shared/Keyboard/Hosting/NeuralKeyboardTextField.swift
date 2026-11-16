import SwiftUI
import UIKit

struct NeuralKeyboardTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let configuration: KeyboardConfiguration
    let presenter: InAppKeyboardPresenter?
    var accessibilityIdentifier: String?
    /// Uses the keyboard iOS picks (for example the NeuralKey extension) instead of the in-app one.
    var usesSystemKeyboard = false
    var systemKeyboardAppearance: UIKeyboardAppearance = .dark
    var systemKeyboardAutocapitalization: UITextAutocapitalizationType = .sentences

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.font = AppTextStyle.input.uiFont
        field.textColor = .white
        field.tintColor = UIColor(AppColor.royal)
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(AppColor.textPlaceholder),
                .font: AppTextStyle.input.uiFont
            ]
        )
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.smartQuotesType = .no
        field.inputAssistantItem.leadingBarButtonGroups = []
        field.inputAssistantItem.trailingBarButtonGroups = []
        field.accessibilityIdentifier = accessibilityIdentifier
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.delegate = context.coordinator
        field.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)

        let controller = KeyboardController(configuration: configuration)
        let input = TextFieldKeyboardInput(textField: field) { [weak coordinator = context.coordinator, weak field] in
            guard let field else { return }
            coordinator?.textDidChange(in: field)
        }
        controller.textInput = input
        controller.onInputClick = { UIDevice.current.playInputClick() }
        context.coordinator.controller = controller
        context.coordinator.input = input
        context.coordinator.presenter = usesSystemKeyboard ? nil : presenter
        if usesSystemKeyboard {
            field.keyboardAppearance = systemKeyboardAppearance
            field.autocapitalizationType = systemKeyboardAutocapitalization
        } else {
            field.inputView = KeyboardInputView()
        }
        field.text = text
        return field
    }

    func updateUIView(_ field: UITextField, context: Context) {
        context.coordinator.text = $text
        context.coordinator.controller?.playsHaptics = configuration.playsHaptics
        context.coordinator.presenter = usesSystemKeyboard ? nil : presenter
        if field.text != text {
            field.text = text
        }
    }

    @MainActor
    final class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var controller: KeyboardController?
        var input: TextFieldKeyboardInput?
        weak var presenter: InAppKeyboardPresenter?

        init(text: Binding<String>) {
            self.text = text
        }

        @objc func editingChanged(_ field: UITextField) {
            textDidChange(in: field)
        }

        func textDidChange(in field: UITextField) {
            let value = field.text ?? ""
            if text.wrappedValue != value {
                text.wrappedValue = value
            }
            controller?.textDidChange()
        }

        func textFieldDidBeginEditing(_ field: UITextField) {
            guard let controller else { return }
            controller.textDidChange()
            presenter?.show(controller)
        }

        func textFieldDidEndEditing(_ field: UITextField) {
            guard let controller else { return }
            presenter?.hide(controller)
        }

        func textFieldDidChangeSelection(_ field: UITextField) {
            controller?.textDidChange()
        }

        func textFieldShouldReturn(_ field: UITextField) -> Bool {
            field.resignFirstResponder()
            return true
        }
    }
}

@MainActor
final class TextFieldKeyboardInput: KeyboardTextInput {
    private weak var textField: UITextField?
    private let onChange: () -> Void

    init(textField: UITextField, onChange: @escaping () -> Void) {
        self.textField = textField
        self.onChange = onChange
    }

    var textBeforeCursor: String {
        guard let field = textField else { return "" }
        guard let selection = field.selectedTextRange,
              let range = field.textRange(from: field.beginningOfDocument, to: selection.start) else {
            return field.text ?? ""
        }
        return field.text(in: range) ?? ""
    }

    var hasText: Bool {
        textField?.hasText ?? false
    }

    func insertText(_ text: String) {
        textField?.insertText(text)
        onChange()
    }

    func deleteBackward() {
        textField?.deleteBackward()
        onChange()
    }

    func performReturn() {
        guard let field = textField else { return }
        if field.delegate?.textFieldShouldReturn?(field) ?? true {
            field.resignFirstResponder()
        }
    }
}
