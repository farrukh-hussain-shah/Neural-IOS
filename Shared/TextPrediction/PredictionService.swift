import Foundation

extension Notification.Name {
    /// Posted on the main thread when newly loaded word lists can give better suggestions.
    static let predictionDictionariesDidLoad = Notification.Name("NKPredictionDictionariesDidLoad")
}

/// The one place the keyboard asks for suggestions and reports finished words.
///
/// Each process (the app with its in-app keyboard, and the keyboard extension) has one shared
/// service. It:
/// - loads the downloaded word lists off the main thread, and loads them again after the app
///   downloads newer ones (`prepare()`);
/// - answers suggestion requests at once from memory;
/// - saves learned words shortly after they change, and on demand (`saveNow()`).
@MainActor
final class PredictionService {
    static let shared = PredictionService()

    private let storage: PredictionStorage
    private let engine: TextPredictionEngine
    private var loadedSignature: String?
    private var loadingSignature: String?
    private var saveTask: Task<Void, Never>?

    init(storage: PredictionStorage = .shared) {
        self.storage = storage
        let userDictionary = storage.userDictionaryFile.map(UserDictionary.load(from:)) ?? UserDictionary()
        engine = TextPredictionEngine(userDictionary: userDictionary)
    }

    /// Whether the downloaded word lists are loaded (suggestions are limited until they are).
    var hasDictionaries: Bool {
        engine.lexicon != nil
    }

    /// Loads the downloaded word lists in the background if they are new or changed since the
    /// last load. Call it whenever the keyboard appears; it does nothing when nothing changed.
    func prepare() {
        guard let signature = storage.dictionarySignature(),
              signature != loadedSignature,
              signature != loadingSignature,
              let wordsFile = storage.existingFile(for: .words) else { return }
        let bigramsFile = storage.existingFile(for: .bigrams) ?? wordsFile.deletingLastPathComponent()
            .appendingPathComponent(DictionaryResource.bigrams.fileName)
        loadingSignature = signature

        Task { [weak self] in
            let started = Date()
            let lexicon = await Task.detached(priority: .userInitiated) {
                try? Lexicon.load(wordsFile: wordsFile, bigramsFile: bigramsFile)
            }.value
            guard let self, self.loadingSignature == signature else { return }
            self.loadingSignature = nil
            guard let lexicon else { return }
            self.engine.lexicon = lexicon
            self.loadedSignature = signature
            print("[TextPrediction] Loaded \(lexicon.wordCount) words in \(Int(Date().timeIntervalSince(started) * 1000)) ms")
            NotificationCenter.default.post(name: .predictionDictionariesDidLoad, object: self)
        }
    }

    func predictions(for context: TextContext, limit: Int) -> [Prediction] {
        engine.predictions(for: context, limit: limit)
    }

    /// Reports a finished word so the keyboard learns from it.
    func learn(_ word: String, context: TextContext, source: LearningSource) {
        let before = engine.userDictionary
        engine.learn(word, context: context, source: source)
        if engine.userDictionary != before {
            scheduleSave()
        }
    }

    /// Writes learned words now, e.g. when the keyboard is dismissed.
    func saveNow() {
        guard saveTask != nil else { return }
        saveTask?.cancel()
        saveTask = nil
        write(engine.userDictionary)
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(TextPredictionConfiguration.Learning.saveDelay))
            guard !Task.isCancelled, let self else { return }
            self.saveTask = nil
            self.write(self.engine.userDictionary)
        }
    }

    private func write(_ dictionary: UserDictionary) {
        guard let file = storage.userDictionaryFile else { return }
        Task.detached(priority: .utility) {
            do {
                try dictionary.save(to: file)
            } catch {
                print("[TextPrediction] Saving learned words failed: \(error)")
            }
        }
    }
}
