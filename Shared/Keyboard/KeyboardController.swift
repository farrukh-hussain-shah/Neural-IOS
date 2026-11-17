import Observation
import UIKit

@MainActor
@Observable
final class KeyboardController {
    let configuration: KeyboardConfiguration

    private(set) var layer: KeyboardLayer
    private(set) var shift: ShiftState = .off
    private(set) var suggestions: [KeyboardSuggestion] = []
    /// Light keeps the designed look; the extension switches to dark to match the host app.
    var isDarkAppearance = false
    /// False when the host field asks for no autocapitalization (UITextAutocapitalizationType.none).
    @ObservationIgnored var hostAllowsAutoCapitalization = true {
        didSet {
            if !hostAllowsAutoCapitalization, shift == .on {
                shift = .off
            }
        }
    }

    @ObservationIgnored weak var textInput: (any KeyboardTextInput)?
    @ObservationIgnored var onInputClick: (() -> Void)?
    @ObservationIgnored var onNextKeyboard: (() -> Void)?
    @ObservationIgnored var playsHaptics: Bool

    @ObservationIgnored private var lastShiftTap: Date?
    @ObservationIgnored private var lastSpaceInsert: Date?
    @ObservationIgnored private var backspaceTask: Task<Void, Never>?
    @ObservationIgnored private var dictionaryObserver: NSObjectProtocol?
    private let prediction: PredictionService
    private let haptics = UIImpactFeedbackGenerator(style: .light)

    init(configuration: KeyboardConfiguration, prediction: PredictionService = .shared) {
        self.configuration = configuration
        self.prediction = prediction
        playsHaptics = configuration.playsHaptics
        layer = configuration.type == .phonePad ? .phoneDigits : .letters
        guard configuration.showsSuggestions else { return }
        prediction.prepare()
        dictionaryObserver = NotificationCenter.default.addObserver(
            forName: .predictionDictionariesDidLoad,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.updateSuggestions()
            }
        }
    }

    deinit {
        if let dictionaryObserver {
            NotificationCenter.default.removeObserver(dictionaryObserver)
        }
    }

    var rows: [KeyboardRow] {
        KeyboardLayout.rows(for: layer, configuration: configuration)
    }

    var isUppercase: Bool {
        shift != .off
    }

    func textDidChange() {
        updateAutoCapitalization()
        updateSuggestions()
    }

    func keyDown(_ key: KeyboardKey) {
        feedback()
        if key.action == .backspace {
            beginBackspace()
        }
    }

    func keyUp(_ key: KeyboardKey) {
        if key.action == .backspace {
            endBackspace()
        } else {
            perform(key.action)
        }
    }

    func insertAlternate(_ value: String) {
        insertCharacter(value)
    }

    func select(_ suggestion: KeyboardSuggestion) {
        guard let textInput else { return }
        feedback()
        let context = TextContext(textBeforeCursor: textInput.textBeforeCursor)
        context.currentWord.forEach { _ in textInput.deleteBackward() }
        textInput.insertText(suggestion.text + " ")
        learn(suggestion.text, in: context, source: suggestion.kind == .verbatim ? .keptTypedWord : .selectedSuggestion)
        textDidChange()
    }

    func perform(_ action: KeyboardAction) {
        switch action {
        case .character(let value):
            insertCharacter(value)
        case .backspace:
            textInput?.deleteBackward()
            textDidChange()
        case .space:
            insertSpace()
        case .shift:
            toggleShift()
        case .layer(let target):
            layer = target
            if target == .letters {
                updateAutoCapitalization()
            }
        case .returnKey:
            learnTypedWord()
            textInput?.performReturn()
            textDidChange()
        case .nextKeyboard:
            onNextKeyboard?()
        case .emoji, .dictation:
            break
        }
    }

    private func insertCharacter(_ value: String) {
        guard let textInput else { return }
        let text = layer == .letters && isUppercase ? value.uppercased() : value
        if Self.wordEndingPunctuation.contains(value) {
            learnTypedWord()
        }
        textInput.insertText(text)
        if shift == .on {
            shift = .off
        }
        if value == "'" && (layer == .numbers || layer == .symbols) {
            layer = .letters
        }
        lastSpaceInsert = nil
        textDidChange()
    }

    private func insertSpace() {
        guard let textInput else { return }
        learnTypedWord()
        let before = textInput.textBeforeCursor
        if let lastSpaceInsert,
           Date().timeIntervalSince(lastSpaceInsert) < Timing.doubleSpaceInterval,
           before.hasSuffix(" "),
           before.dropLast().last.map({ $0.isLetter || $0.isNumber }) == true {
            textInput.deleteBackward()
            textInput.insertText(". ")
            self.lastSpaceInsert = nil
        } else {
            textInput.insertText(" ")
            lastSpaceInsert = Date()
        }
        if layer == .numbers || layer == .symbols {
            layer = .letters
        }
        textDidChange()
    }

    private func toggleShift() {
        let now = Date()
        defer { lastShiftTap = now }
        if shift == .capsLock {
            shift = .off
            return
        }
        if let lastShiftTap, now.timeIntervalSince(lastShiftTap) < Timing.doubleTapInterval {
            shift = .capsLock
            return
        }
        shift = shift == .off ? .on : .off
    }

    private func updateAutoCapitalization() {
        guard configuration.autoCapitalizes, hostAllowsAutoCapitalization, layer == .letters, shift != .capsLock,
              let textInput else { return }
        shift = Self.startsSentence(textInput.textBeforeCursor) ? .on : .off
    }

    private func updateSuggestions() {
        guard configuration.showsSuggestions, let textInput else {
            suggestions = []
            return
        }
        suggestions = SuggestionProvider.suggestions(forTextBeforeCursor: textInput.textBeforeCursor, service: prediction)
    }

    /// Teaches the keyboard the word just finished by a space, return or punctuation.
    private func learnTypedWord() {
        guard let textInput else { return }
        let context = TextContext(textBeforeCursor: textInput.textBeforeCursor)
        guard !context.currentWord.isEmpty else { return }
        learn(context.currentWord, in: context, source: .typed)
    }

    private func learn(_ word: String, in context: TextContext, source: LearningSource) {
        guard configuration.showsSuggestions else { return }
        prediction.learn(word, context: context, source: source)
    }

    private func beginBackspace() {
        perform(.backspace)
        backspaceTask?.cancel()
        backspaceTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Timing.repeatDelay))
            var repeats = 0
            while !Task.isCancelled {
                guard let self else { return }
                if repeats < Timing.characterRepeatsBeforeWords {
                    self.perform(.backspace)
                    try? await Task.sleep(for: .seconds(Timing.characterRepeatInterval))
                } else {
                    self.deleteWord()
                    try? await Task.sleep(for: .seconds(Timing.wordRepeatInterval))
                }
                repeats += 1
            }
        }
    }

    private func endBackspace() {
        backspaceTask?.cancel()
        backspaceTask = nil
    }

    private func deleteWord() {
        guard let textInput, textInput.hasText else { return }
        let before = textInput.textBeforeCursor
        let trailingSpaces = before.reversed().prefix { $0 == " " }.count
        let word = SuggestionProvider.currentWord(in: String(before.dropLast(trailingSpaces)))
        let count = max(trailingSpaces + max(word.count, 1), 1)
        (0..<count).forEach { _ in textInput.deleteBackward() }
        textDidChange()
    }

    private func feedback() {
        onInputClick?()
        if playsHaptics {
            haptics.impactOccurred()
        }
    }

    /// Punctuation that ends the word before it, so that word is learned.
    private static let wordEndingPunctuation: Set<String> = [".", ",", "!", "?", ";", ":"]

    static func startsSentence(_ text: String) -> Bool {
        let trimmed = text.replacingOccurrences(of: " ", with: "")
        guard let last = trimmed.last else { return true }
        guard text.last == " " || text.last == "\n" || text.isEmpty else { return false }
        return [".", "!", "?", "\n"].contains(last)
    }

    private enum Timing {
        static let doubleTapInterval: TimeInterval = 0.35
        static let doubleSpaceInterval: TimeInterval = 0.4
        static let repeatDelay: TimeInterval = 0.45
        static let characterRepeatInterval: TimeInterval = 0.09
        static let characterRepeatsBeforeWords = 18
        static let wordRepeatInterval: TimeInterval = 0.25
    }
}
