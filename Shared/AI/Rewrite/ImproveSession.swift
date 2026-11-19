import Foundation
import Observation

/// The state of the keyboard's Improve panel: which tone and language are picked, and the
/// rewritten options for the user's text.
///
/// Picking a tone (or language) starts a new request at once and cancels the previous one, so
/// only the latest choice is ever shown. Answers are cached, so going back to a tone that was
/// already loaded for the same text shows its options instantly.
@MainActor
@Observable
final class ImproveSession {
    enum Phase: Equatable {
        /// Waiting for the AI; the panel shows shimmering placeholder cards.
        case loading
        case loaded([String])
        case failed(String)
    }

    private(set) var text = ""
    private(set) var tones: [RewriteTone] = [.improve]
    private(set) var tone: RewriteTone = .improve
    private(set) var language: RewriteLanguage
    private(set) var phase: Phase = .loading

    private let rewriter: any TextRewriter
    private let preferences: ImprovePreferences
    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private var cache: [CacheKey: [String]] = [:]

    private struct CacheKey: Hashable {
        let text: String
        let tone: RewriteTone
        let language: RewriteLanguage
    }

    init(rewriter: any TextRewriter, preferences: ImprovePreferences = ImprovePreferences()) {
        self.rewriter = rewriter
        self.preferences = preferences
        language = preferences.language
    }

    /// Opens the panel for `text`, with the user's tones, starting on Improve.
    func start(text: String, selectedTones: Set<AITone>) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed != self.text {
            cache.removeAll()
        }
        self.text = trimmed
        tones = RewriteTone.available(selectedTones: selectedTones)
        tone = .improve
        load()
    }

    func select(_ tone: RewriteTone) {
        guard tone != self.tone || phase.isFailure else { return }
        self.tone = tone
        load()
    }

    func select(_ language: RewriteLanguage) {
        guard language != self.language else { return }
        self.language = language
        preferences.language = language
        load()
    }

    func retry() {
        load()
    }

    /// Shows `message` instead of options (for example when the keyboard has no network access).
    func showMessage(_ message: String) {
        task?.cancel()
        phase = .failed(message)
    }

    /// Stops any request in flight (the panel was closed).
    func stop() {
        task?.cancel()
        task = nil
    }

    private func load() {
        task?.cancel()
        guard !text.isEmpty else {
            phase = .failed(String(localized: "Type something first, then tap Improve."))
            return
        }
        let key = CacheKey(text: text, tone: tone, language: language)
        if let cached = cache[key] {
            phase = .loaded(cached)
            return
        }

        phase = .loading
        let rewriter = rewriter
        task = Task { [weak self] in
            do {
                let options = try await rewriter.rewrites(of: key.text, tone: key.tone, language: key.language)
                guard !Task.isCancelled, let self else { return }
                self.cache[key] = options
                self.phase = .loaded(options)
            } catch {
                guard !Task.isCancelled, !(error is CancellationError), let self else { return }
                self.phase = .failed(Self.message(for: error))
            }
        }
    }

    private static func message(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                return String(localized: "No internet connection. Check your connection and try again.")
            case .timedOut:
                return String(localized: "The AI took too long to answer. Please try again.")
            default:
                break
            }
        }
        return (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }
}

extension ImproveSession.Phase {
    var isFailure: Bool {
        if case .failed = self { return true }
        return false
    }
}

/// Improve choices that are kept between uses, shared by the app and the keyboard.
struct ImprovePreferences {
    private static let languageKey = "NKImproveLanguage"

    var defaults: UserDefaults? = UserDefaults(suiteName: KeyboardSharedState.appGroupIdentifier)

    var language: RewriteLanguage {
        get { RewriteLanguage.with(id: defaults?.string(forKey: Self.languageKey)) }
        nonmutating set { defaults?.set(newValue.id, forKey: Self.languageKey) }
    }
}
