import Foundation

/// The language the rewritten options are written in (the "English" button in the Improve panel).
struct RewriteLanguage: Hashable, Identifiable, Sendable {
    /// Stable id, saved as the user's choice.
    let id: String
    /// Shown in the language list ("English (UK)").
    let name: String
    /// Shown on the panel's language button ("English").
    let shortName: String
    /// How the language is named to the AI; nil means "the same language as the text".
    let promptName: String?

    var isDetect: Bool {
        promptName == nil
    }

    static let detect = RewriteLanguage(id: "detect", name: "Detect Language", shortName: "Auto", promptName: nil)
    static let englishUS = RewriteLanguage(id: "en-US", name: "English (US)", shortName: "English", promptName: "American English")

    /// In the order of the language list: the default first, then Detect, then the rest.
    static let all: [RewriteLanguage] = [
        englishUS,
        detect,
        RewriteLanguage(id: "en-GB", name: "English (UK)", shortName: "English", promptName: "British English"),
        RewriteLanguage(id: "en-AU", name: "English (Australia)", shortName: "English", promptName: "Australian English"),
        RewriteLanguage(id: "es-ES", name: "Spanish (Spain)", shortName: "Spanish", promptName: "Spanish as spoken in Spain"),
        RewriteLanguage(id: "es-419", name: "Spanish (Latin America)", shortName: "Spanish", promptName: "Latin American Spanish"),
        RewriteLanguage(id: "fr-FR", name: "French (France)", shortName: "French", promptName: "French"),
        RewriteLanguage(id: "pt-BR", name: "Portuguese (Brazil)", shortName: "Portuguese", promptName: "Brazilian Portuguese"),
        RewriteLanguage(id: "de-DE", name: "German", shortName: "German", promptName: "German"),
        RewriteLanguage(id: "it-IT", name: "Italian", shortName: "Italian", promptName: "Italian"),
        RewriteLanguage(id: "ru-RU", name: "Russian", shortName: "Russian", promptName: "Russian"),
        RewriteLanguage(id: "ar", name: "Arabic", shortName: "Arabic", promptName: "Arabic"),
        RewriteLanguage(id: "zh-Hans", name: "Chinese (Simplified)", shortName: "Chinese", promptName: "Simplified Chinese"),
        RewriteLanguage(id: "hi-IN", name: "Hindi", shortName: "Hindi", promptName: "Hindi"),
        RewriteLanguage(id: "ur-PK", name: "Urdu", shortName: "Urdu", promptName: "Urdu"),
        RewriteLanguage(id: "tr-TR", name: "Turkish", shortName: "Turkish", promptName: "Turkish"),
        RewriteLanguage(id: "ja-JP", name: "Japanese", shortName: "Japanese", promptName: "Japanese"),
        RewriteLanguage(id: "ko-KR", name: "Korean", shortName: "Korean", promptName: "Korean")
    ]

    static func with(id: String?) -> RewriteLanguage {
        all.first { $0.id == id } ?? englishUS
    }
}
