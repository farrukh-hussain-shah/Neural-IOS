import Foundation

/// Every tunable value of the AI features (Improve now; Translate and Transcribe later).
enum AIConfiguration {
    enum Gemini {
        static let model = "gemini-2.5-flash-lite"
        static let endpoint = URL(
            string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent"
        )!
        static let requestTimeout: TimeInterval = 30
        /// Higher gives more varied options; 0.9 keeps the three options clearly different.
        static let temperature = 0.9

        /// The API key: the `GEMINI_API_KEY` build setting if one is set (it reaches the
        /// `NKGeminiAPIKey` Info.plist entry, see Config/Base.xcconfig), else the built-in key.
        static var apiKey: String? {
            let value = (Bundle.main.object(forInfoDictionaryKey: "NKGeminiAPIKey") as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let value, !value.isEmpty, !value.hasPrefix("$(") {
                return value
            }
            return GeminiAPIKey.builtIn.isEmpty ? nil : GeminiAPIKey.builtIn
        }
    }

    enum Rewrite {
        /// How many alternatives Improve shows.
        static let optionCount = 3
        /// Longer text is cut to this many characters before it is sent.
        static let maxInputLength = 2_000
    }
}
