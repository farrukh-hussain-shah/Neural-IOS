import Foundation

/// Calls Google's Gemini `generateContent` API and returns the model's text.
///
/// Only the parts NeuralKey uses are modelled: a system instruction, one user message and a
/// JSON response schema, so the model answers with JSON that matches the schema.
struct GeminiClient: Sendable {
    enum GeminiError: LocalizedError {
        case missingAPIKey
        case badStatus(Int, message: String?)
        case emptyResponse
        case blocked(reason: String)

        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "The AI is not configured (no Gemini API key)."
            case .badStatus(let status, let message):
                return message ?? "The AI service returned an error (\(status))."
            case .emptyResponse:
                return "The AI returned no answer."
            case .blocked(let reason):
                return "The AI could not answer this text (\(reason))."
            }
        }
    }

    let apiKey: String?
    var model = AIConfiguration.Gemini.model
    var session: URLSession = .shared

    /// Sends `userText` with `systemInstruction` and returns the model's reply, which follows
    /// `responseSchema` (an OpenAPI-style schema, see the Gemini docs on structured output).
    func generate(systemInstruction: String, userText: String, responseSchema: [String: Any]) async throws -> String {
        guard let apiKey else { throw GeminiError.missingAPIKey }

        var request = URLRequest(url: AIConfiguration.Gemini.endpoint, timeoutInterval: AIConfiguration.Gemini.requestTimeout)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // The key goes in a header, never in the URL, so it doesn't end up in logs.
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "systemInstruction": ["parts": [["text": systemInstruction]]],
            "contents": [["role": "user", "parts": [["text": userText]]]],
            "generationConfig": [
                "temperature": AIConfiguration.Gemini.temperature,
                "responseMimeType": "application/json",
                "responseSchema": responseSchema
            ]
        ])

        let (data, response) = try await session.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            let message = (try? JSONDecoder().decode(ErrorResponse.self, from: data))?.error.message
            throw GeminiError.badStatus(status, message: message)
        }

        let decoded = try JSONDecoder().decode(GenerateResponse.self, from: data)
        if let reason = decoded.promptFeedback?.blockReason {
            throw GeminiError.blocked(reason: reason)
        }
        let text = decoded.candidates?.first?.content?.parts?.compactMap(\.text).joined() ?? ""
        guard !text.isEmpty else { throw GeminiError.emptyResponse }
        return text
    }

    private struct GenerateResponse: Decodable {
        struct Candidate: Decodable {
            struct Content: Decodable {
                struct Part: Decodable {
                    let text: String?
                }

                let parts: [Part]?
            }

            let content: Content?
        }

        struct PromptFeedback: Decodable {
            let blockReason: String?
        }

        let candidates: [Candidate]?
        let promptFeedback: PromptFeedback?
    }

    private struct ErrorResponse: Decodable {
        struct Body: Decodable {
            let message: String?
        }

        let error: Body
    }
}
