import Foundation

/// The word lists the keyboard downloads.
enum DictionaryResource: String, CaseIterable, Codable, Sendable {
    /// Single words with frequencies, for correction and completion.
    case words
    /// Word pairs with frequencies, for next-word prediction.
    case bigrams

    var remoteURL: URL {
        switch self {
        case .words:
            return TextPredictionConfiguration.Remote.wordsURL
        case .bigrams:
            return TextPredictionConfiguration.Remote.bigramsURL
        }
    }

    var fileName: String {
        switch self {
        case .words:
            return "frequency_dictionary.txt"
        case .bigrams:
            return "bigram_frequency_dictionary.txt"
        }
    }
}

/// Where prediction data lives on disk.
///
/// The app and the keyboard extension share the App Group container, so the lists the app
/// downloads are what the keyboard reads, and words learned in one are known to the other.
/// When a root can't be written (the keyboard without Full Access can't write to the shared
/// container), the next one is used: the process's own Application Support folder.
///
///     <root>/TextPrediction/Dictionaries/frequency_dictionary.txt
///     <root>/TextPrediction/Dictionaries/bigram_frequency_dictionary.txt
///     <root>/TextPrediction/Dictionaries/download_state.json
///     <root>/TextPrediction/user_dictionary.json
struct PredictionStorage: Sendable {
    private static let folderName = "TextPrediction"
    private static let dictionariesFolderName = "Dictionaries"
    private static let userDictionaryFileName = "user_dictionary.json"
    private static let downloadStateFileName = "download_state.json"

    /// Folders searched in order: lists are read from the first that has them, and new files
    /// are written to the first that can be written.
    let roots: [URL]

    init(roots: [URL]) {
        self.roots = roots
    }

    /// The shared App Group container first, then this process's Application Support folder.
    static let shared: PredictionStorage = {
        let fileManager = FileManager.default
        let shared = fileManager
            .containerURL(forSecurityApplicationGroupIdentifier: KeyboardSharedState.appGroupIdentifier)?
            .appendingPathComponent("Library/Application Support", isDirectory: true)
        let local = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        return PredictionStorage(roots: [shared, local].compactMap { $0?.appendingPathComponent(PredictionStorage.folderName, isDirectory: true) })
    }()

    /// The first root that can be written, created if needed.
    var writableRoot: URL? {
        roots.first { root in
            let folder = root.appendingPathComponent(Self.dictionariesFolderName, isDirectory: true)
            guard (try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)) != nil else {
                return false
            }
            return FileManager.default.isWritableFile(atPath: folder.path)
        }
    }

    /// The downloaded list to read, or nil if it hasn't been downloaded yet.
    func existingFile(for resource: DictionaryResource) -> URL? {
        roots
            .map { Self.dictionaryFile(for: resource, in: $0) }
            .first { FileManager.default.fileExists(atPath: $0.path) }
    }

    /// Where a new download of `resource` is saved.
    func destinationFile(for resource: DictionaryResource) -> URL? {
        writableRoot.map { Self.dictionaryFile(for: resource, in: $0) }
    }

    var downloadStateFile: URL? {
        writableRoot?
            .appendingPathComponent(Self.dictionariesFolderName, isDirectory: true)
            .appendingPathComponent(Self.downloadStateFileName)
    }

    var userDictionaryFile: URL? {
        writableRoot?.appendingPathComponent(Self.userDictionaryFileName)
    }

    var hasDownloadedDictionaries: Bool {
        existingFile(for: .words) != nil
    }

    /// Changes whenever a list is downloaded again, so a running keyboard knows to reload.
    /// Nil while the word list is missing.
    func dictionarySignature() -> String? {
        guard hasDownloadedDictionaries else { return nil }
        return DictionaryResource.allCases.compactMap { resource in
            guard let file = existingFile(for: resource),
                  let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) else { return nil }
            let modified = (attributes[.modificationDate] as? Date)?.timeIntervalSince1970 ?? 0
            let size = (attributes[.size] as? NSNumber)?.intValue ?? 0
            return "\(file.path)|\(modified)|\(size)"
        }
        .joined(separator: ";")
    }

    private static func dictionaryFile(for resource: DictionaryResource, in root: URL) -> URL {
        root
            .appendingPathComponent(dictionariesFolderName, isDirectory: true)
            .appendingPathComponent(resource.fileName)
    }
}
