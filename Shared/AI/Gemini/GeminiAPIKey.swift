import Foundation

/// The Gemini API key built into the app and the keyboard.
///
/// A `GEMINI_API_KEY` build setting (Config/Secrets.xcconfig or a CI secret) takes precedence;
/// this value is used when none is set. Anyone with the app binary can read a built-in key, so
/// before release, route AI requests through a server that holds the key instead.
enum GeminiAPIKey {
    static let builtIn = "AQ.Ab8RN6KTka0gzGnQZm2qMPCJRJZRV6eCApV7gS7HFlh0ede0zg"
}
