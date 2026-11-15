import SwiftUI

struct KeyboardKeyView: View {
    let key: KeyboardKey
    let size: CGSize
    let edge: KeyEdge
    let expandsAlternatesLeading: Bool
    let hitInsets: EdgeInsets
    let controller: KeyboardController

    @State private var isPressed = false
    @State private var alternates: [String] = []
    @State private var selectedAlternate = 0
    @State private var longPressTask: Task<Void, Never>?

    private var isPhonePad: Bool {
        controller.layer == .phoneDigits || controller.layer == .phoneSymbols
    }

    private var characterValue: String? {
        if case .character(let value) = key.action { return value }
        return nil
    }

    private var displayedCharacter: String? {
        guard let value = characterValue else { return nil }
        return controller.layer == .letters && controller.isUppercase ? value.uppercased() : value
    }

    private var isHighlighted: Bool {
        isPressed || controller.configuration.previewKeyID == key.id
    }

    private var showsPopup: Bool {
        isHighlighted && displayedCharacter != nil && !isPhonePad && alternates.isEmpty
    }

    var body: some View {
        keyFace
            .frame(width: size.width, height: size.height)
            .overlay(alignment: .bottomLeading) {
                if showsPopup, let displayedCharacter {
                    KeyPopup(label: displayedCharacter, keySize: size, edge: edge)
                } else if isPressed, !alternates.isEmpty {
                    KeyAlternatesPopup(
                        alternates: alternates,
                        selectedIndex: selectedAlternate,
                        keySize: size,
                        expandsLeading: expandsAlternatesLeading
                    )
                }
            }
            .padding(hitInsets)
            .contentShape(Rectangle())
            .gesture(pressGesture)
            .zIndex(isHighlighted ? 1 : 0)
            .accessibilityElement()
            .accessibilityLabel(Text(accessibilityLabel))
            .accessibilityAddTraits(.isKeyboardKey)
            .accessibilityIdentifier("keyboard.\(key.id)")
    }

    @ViewBuilder
    private var keyFace: some View {
        let shape = RoundedRectangle(cornerRadius: KeyboardMetrics.keyCornerRadius, style: .continuous)
        switch key.style {
        case .transparent:
            label
                .background(shape.fill(isHighlighted ? AppColor.keyboardKeyPressed : .clear))
        case .primary:
            label
                .background(shape.fill(isHighlighted ? AppColor.keyboardPrimaryPressed : AppColor.keyboardPrimary))
        case .function:
            label
                .background(shape.fill(isHighlighted ? AppColor.keyboardKeyPressed : AppColor.keyboardKey))
        case .character:
            label
                .background(shape.fill(isHighlighted && isPhonePad ? AppColor.keyboardKeyPressed : AppColor.keyboardKey))
        }
    }

    @ViewBuilder
    private var label: some View {
        switch key.action {
        case .character:
            if isPhonePad {
                phoneLabel
            } else {
                Text(displayedCharacter ?? "")
                    .font(.system(
                        size: controller.layer == .letters ? KeyboardMetrics.letterFontSize : KeyboardMetrics.symbolFontSize
                    ))
                    .foregroundStyle(AppColor.keyboardLabel)
                    .offset(y: controller.layer == .letters ? KeyboardMetrics.letterBaselineNudge : KeyboardMetrics.symbolBaselineNudge)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(showsPopup ? 0 : 1)
            }
        case .shift:
            symbol(shiftSymbol, size: KeyboardMetrics.shiftIconSize, weight: .medium, color: AppColor.keyboardLabel)
        case .backspace:
            symbol("delete.left", size: isPhonePad ? KeyboardMetrics.phoneDeleteIconSize : KeyboardMetrics.deleteIconSize, color: AppColor.keyboardLabel)
        case .returnKey:
            if key.style == .primary {
                symbol("arrow.right", size: KeyboardMetrics.goIconSize, weight: .medium, color: .white)
            } else {
                symbol("return.left", size: KeyboardMetrics.returnIconSize, color: AppColor.keyboardLabel)
            }
        case .layer where isPhonePad && key.subtitle == "+*#":
            HStack(spacing: KeyboardMetrics.phoneToggleSpacing) {
                ForEach(["plus", "asterisk", "number"], id: \.self) { name in
                    Image(systemName: name)
                        .font(.system(size: KeyboardMetrics.phoneToggleIconSize, weight: .light))
                }
            }
            .foregroundStyle(AppColor.keyboardLabel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .layer:
            Text(key.subtitle ?? "")
                .font(.system(
                    size: isPhonePad ? KeyboardMetrics.phoneSymbolFontSize : KeyboardMetrics.functionFontSize,
                    weight: isPhonePad ? .light : .regular
                ))
                .tracking(isPhonePad ? KeyboardMetrics.phoneLetterTracking : 0)
                .foregroundStyle(AppColor.keyboardLabel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .space, .emoji, .dictation:
            Color.clear
        }
    }

    private var phoneLabel: some View {
        VStack(spacing: 0) {
            Text(characterValue ?? "")
                .font(.system(size: KeyboardMetrics.phoneDigitFontSize))
            if let subtitle = key.subtitle {
                Text(subtitle)
                    .font(.system(size: KeyboardMetrics.phoneLetterFontSize, weight: .semibold))
                    .tracking(KeyboardMetrics.phoneLetterTracking)
                    .frame(minHeight: KeyboardMetrics.phoneLetterFontSize)
            }
        }
        .foregroundStyle(AppColor.keyboardLabel)
        .offset(y: KeyboardMetrics.phoneLabelNudge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func symbol(_ name: String, size: CGFloat, weight: Font.Weight = .regular, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: size, weight: weight))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var shiftSymbol: String {
        switch controller.shift {
        case .off: "shift"
        case .on: "shift.fill"
        case .capsLock: "capslock.fill"
        }
    }

    private var accessibilityLabel: String {
        switch key.action {
        case .character: displayedCharacter ?? ""
        case .shift: "shift"
        case .backspace: "delete"
        case .space: "space"
        case .returnKey: key.style == .primary ? "go" : "return"
        case .layer: key.subtitle ?? ""
        case .emoji: "emoji"
        case .dictation: "dictation"
        }
    }

    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                if !isPressed {
                    isPressed = true
                    controller.keyDown(key)
                    scheduleAlternates()
                }
                if !alternates.isEmpty {
                    selectedAlternate = KeyAlternatesPopup.index(
                        forOffset: value.location.x - hitInsets.leading,
                        count: alternates.count,
                        expandsLeading: expandsAlternatesLeading,
                        keyWidth: size.width
                    )
                }
            }
            .onEnded { _ in
                longPressTask?.cancel()
                longPressTask = nil
                if alternates.isEmpty {
                    controller.keyUp(key)
                } else {
                    controller.insertAlternate(alternates[selectedAlternate])
                }
                isPressed = false
                alternates = []
            }
    }

    private func scheduleAlternates() {
        guard !isPhonePad, let value = characterValue,
              let options = KeyboardLayout.alternates[value], !options.isEmpty else { return }
        let uppercase = controller.layer == .letters && controller.isUppercase
        longPressTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.45))
            guard !Task.isCancelled, isPressed else { return }
            alternates = uppercase ? options.map { $0.uppercased() } : options
            selectedAlternate = expandsAlternatesLeading ? alternates.count - 1 : 0
        }
    }
}
