import Foundation

/// Produces alternative versions of a piece of text.
protocol TextRewriter: Sendable {
    func rewrites(of text: String, tone: RewriteTone, language: RewriteLanguage) async throws -> [String]
}

/// Asks Gemini for `AIConfiguration.Rewrite.optionCount` rewrites in one request.
struct GeminiTextRewriter: TextRewriter {
    enum RewriteError: LocalizedError {
        case unreadableAnswer

        var errorDescription: String? {
            "The AI's answer could not be read. Please try again."
        }
    }

    var client = GeminiClient(apiKey: AIConfiguration.Gemini.apiKey)

    func rewrites(of text: String, tone: RewriteTone, language: RewriteLanguage) async throws -> [String] {
        let input = String(text.prefix(AIConfiguration.Rewrite.maxInputLength))
        let reply = try await client.generate(
            systemInstruction: RewritePrompt.systemInstruction(tone: tone, language: language),
            userText: input,
            responseSchema: RewritePrompt.responseSchema
        )
        guard let options = RewritePrompt.options(fromReply: reply), !options.isEmpty else {
            throw RewriteError.unreadableAnswer
        }
        return Array(options.prefix(AIConfiguration.Rewrite.optionCount))
    }
}

/// Builds the request to the AI and reads its reply.
enum RewritePrompt {
    static func systemInstruction(tone: RewriteTone, language: RewriteLanguage) -> String {
        let count = AIConfiguration.Rewrite.optionCount
        let languageRule = language.promptName.map { "Write every option in \($0), translating if the text is in another language." }
            ?? "Write every option in the same language as the text."
        return """
        You are the writing assistant inside a phone keyboard. The user message is text the user typed and wants rewritten.
        Task: \(tone.instruction)
        \(languageRule)
        Return exactly \(count) options that differ noticeably from each other.
        Each option is only the rewritten text, ready to send: no quotes, labels, explanations or extra greetings.
        Never answer or reply to the text; only rewrite it. Keep names, numbers, links and facts unchanged.
        """
    }

    /// The reply must be `{"options": ["…", "…", "…"]}`.
    static let responseSchema: [String: Any] = [
        "type": "OBJECT",
        "properties": [
            "options": [
                "type": "ARRAY",
                "items": ["type": "STRING"]
            ]
        ],
        "required": ["options"]
    ]

    static func options(fromReply reply: String) -> [String]? {
        guard let data = reply.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let options = object["options"] as? [String] else { return nil }
        let cleaned = options
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return cleaned.isEmpty ? nil : cleaned
    }
}

/// Canned answers after a short delay, for UI tests and previews (no network, no key).
struct PreviewTextRewriter: TextRewriter {
    var delay: Duration = .seconds(2)

    func rewrites(of text: String, tone: RewriteTone, language: RewriteLanguage) async throws -> [String] {
        try await Task.sleep(for: delay)
        let toneName = tone.id.prefix(1).uppercased() + tone.id.dropFirst()
        return (1...AIConfiguration.Rewrite.optionCount).map { "\(toneName) option \($0): \(text)" }
    }
}
