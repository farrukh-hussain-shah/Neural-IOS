import SwiftUI

struct KeyboardTestField: View {
    @Binding var text: String

    @Environment(SettingsStore.self) private var settings: SettingsStore?
    @Environment(InAppKeyboardPresenter.self) private var keyboardPresenter: InAppKeyboardPresenter?

    private var fieldShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Layout.cornerRadius)
    }

    var body: some View {
        NeuralKeyboardTextField(
            text: $text,
            placeholder: String(localized: "Type something..."),
            configuration: keyboardConfiguration,
            presenter: keyboardPresenter,
            accessibilityIdentifier: AccessibilityID.homeTestField,
            usesSystemKeyboard: usesSystemKeyboard,
            systemKeyboardAppearance: systemKeyboardAppearance
        )
        .padding(.horizontal, Layout.horizontalPadding)
        .frame(height: AppSize.inputHeight)
        .background {
            fieldShape
                .stroke(AppGradient.brand, lineWidth: Layout.glowWidth)
                .blur(radius: Layout.glowBlur)
                .opacity(Layout.glowOpacity)
        }
        .background(fieldShape.fill(AppColor.inputSurface))
        .overlay {
            fieldShape
                .strokeBorder(AppGradient.brand, lineWidth: Layout.borderWidth)
                .opacity(Layout.borderOpacity)
        }
    }

    private var usesSystemKeyboard: Bool {
        #if DEBUG
        LaunchOverrides.usesSystemKeyboard
        #else
        false
        #endif
    }

    private var systemKeyboardAppearance: UIKeyboardAppearance {
        #if DEBUG
        LaunchOverrides.systemKeyboardAppearance
        #else
        .dark
        #endif
    }

    private var keyboardConfiguration: KeyboardConfiguration {
        var configuration = KeyboardConfiguration.standard
        configuration.playsHaptics = settings?.isHapticFeedbackEnabled ?? false
        #if DEBUG
        configuration = LaunchOverrides.keyboardConfiguration(base: configuration)
        #endif
        return configuration
    }

    private enum Layout {
        static let cornerRadius: CGFloat = 12.narrowScaled
        static let horizontalPadding: CGFloat = 13.5.narrowScaled
        static let borderWidth: CGFloat = 1.5.narrowScaled
        static let borderOpacity: Double = 0.6
        static let glowWidth: CGFloat = 3.narrowScaled
        static let glowBlur: CGFloat = 4.narrowScaled
        static let glowOpacity: Double = 0.55
    }
}
