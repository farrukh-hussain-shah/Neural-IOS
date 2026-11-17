import Foundation

/// Downloads the word lists in the background and keeps them up to date.
///
/// The app calls `refreshIfNeeded()` on every launch (see `DictionarySync` in the app). It:
/// - downloads a list that is missing;
/// - asks the server for a newer copy of a list older than `refreshInterval`, sending
///   `If-Modified-Since`, so an unchanged list costs one small request;
/// - checks a download is a real word list before it replaces the current file, so a failed or
///   cut-off download never breaks suggestions.
///
/// It is an actor, so overlapping calls (the app and a quick relaunch) never download the same
/// list twice at once.
actor DictionaryDownloader {
    static let shared = DictionaryDownloader()

    private typealias Remote = TextPredictionConfiguration.Remote

    enum DownloadError: Error {
        case noWritableFolder
        case badResponse(statusCode: Int)
        case invalidContent(validLines: Int)
    }

    /// What the last download of each list returned, so the next check can be conditional.
    private struct DownloadState: Codable {
        struct Entry: Codable {
            var lastModified: String?
            var lastChecked: Date
        }

        var entries: [DictionaryResource: Entry] = [:]
    }

    private let storage: PredictionStorage
    private let session: URLSession
    private var isRefreshing = false

    init(storage: PredictionStorage = .shared, session: URLSession = .shared) {
        self.storage = storage
        self.session = session
    }

    /// Downloads missing lists and refreshes stale ones. Returns true if any file changed.
    /// Cheap to call on every launch: it returns at once when nothing is due.
    @discardableResult
    func refreshIfNeeded(force: Bool = false) async -> Bool {
        guard !isRefreshing else { return false }
        isRefreshing = true
        defer { isRefreshing = false }

        var state = loadState()
        var changed = false
        for resource in DictionaryResource.allCases {
            do {
                changed = try await refresh(resource, state: &state, force: force) || changed
            } catch {
                print("[TextPrediction] Downloading \(resource.fileName) failed: \(error)")
            }
        }
        saveState(state)
        return changed
    }

    private func refresh(_ resource: DictionaryResource, state: inout DownloadState, force: Bool) async throws -> Bool {
        guard let destination = storage.destinationFile(for: resource) else {
            throw DownloadError.noWritableFolder
        }
        let fileExists = FileManager.default.fileExists(atPath: destination.path)
        let previous = state.entries[resource]
        if fileExists, !force, let previous, Date().timeIntervalSince(previous.lastChecked) < Remote.refreshInterval {
            return false
        }

        var request = URLRequest(url: resource.remoteURL, timeoutInterval: Remote.requestTimeout)
        if fileExists, let lastModified = previous?.lastModified {
            request.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
        }

        let (downloadedFile, response) = try await session.download(for: request)
        defer { try? FileManager.default.removeItem(at: downloadedFile) }
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

        if statusCode == 304 {
            state.entries[resource] = .init(lastModified: previous?.lastModified, lastChecked: Date())
            return false
        }
        guard (200..<300).contains(statusCode) else {
            throw DownloadError.badResponse(statusCode: statusCode)
        }

        let text = try String(contentsOf: downloadedFile, encoding: .utf8)
        let validLines = FrequencyListParser.validLineCount(in: text, resource: resource)
        guard validLines >= Remote.minimumValidLines else {
            throw DownloadError.invalidContent(validLines: validLines)
        }

        try Self.replace(destination, with: downloadedFile)
        let lastModified = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Last-Modified")
        state.entries[resource] = .init(lastModified: lastModified, lastChecked: Date())
        print("[TextPrediction] Downloaded \(resource.fileName): \(validLines) entries")
        return true
    }

    /// Swaps in the new file in one step, so a reader never sees a half-written list.
    private static func replace(_ destination: URL, with newFile: URL) throws {
        let fileManager = FileManager.default
        let staged = destination.deletingLastPathComponent()
            .appendingPathComponent(".\(destination.lastPathComponent).\(UUID().uuidString)")
        try fileManager.copyItem(at: newFile, to: staged)
        if fileManager.fileExists(atPath: destination.path) {
            _ = try fileManager.replaceItemAt(destination, withItemAt: staged)
        } else {
            try fileManager.moveItem(at: staged, to: destination)
        }
    }

    private func loadState() -> DownloadState {
        guard let file = storage.downloadStateFile,
              let data = try? Data(contentsOf: file),
              let state = try? JSONDecoder().decode(DownloadState.self, from: data) else {
            return DownloadState()
        }
        return state
    }

    private func saveState(_ state: DownloadState) {
        guard let file = storage.downloadStateFile, let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: file, options: .atomic)
    }
}
