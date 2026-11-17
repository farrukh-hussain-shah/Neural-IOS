import UIKit

/// Starts the word-list download as soon as the app launches (while the splash screen shows),
/// in the background so nothing waits for it.
///
/// The lists are too large to ship in the app, so they are downloaded once and refreshed weekly
/// (see `DictionaryDownloader`). They are saved in the App Group container, where the keyboard
/// extension reads them. If the user leaves the app mid-download, iOS is asked for extra time
/// to finish it.
@MainActor
enum DictionarySync {
    private static var isRunning = false

    static func start() {
        guard !isRunning else { return }
        isRunning = true
        let application = UIApplication.shared
        var backgroundTask = UIBackgroundTaskIdentifier.invalid
        backgroundTask = application.beginBackgroundTask(withName: "DownloadDictionaries") {
            application.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }

        PredictionService.shared.prepare()
        Task {
            let changed = await DictionaryDownloader.shared.refreshIfNeeded()
            if changed {
                PredictionService.shared.prepare()
            }
            isRunning = false
            if backgroundTask != .invalid {
                application.endBackgroundTask(backgroundTask)
                backgroundTask = .invalid
            }
        }
    }
}
