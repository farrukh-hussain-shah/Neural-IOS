//
//  KeyboardAiManager.swift
//  NeuralKey
//
//  Created by Macbook 5 on 11/20/26.
//



import Foundation
import FirebaseAILogic

@MainActor
final class KeyboardAiManager {

    // MARK: - Properties

    private let fallbackModelName = "gemini-2.5-flash-lite"

    private var primaryModelName: String
    private var rewriteModel: GenerativeModel
    private var translationModel: GenerativeModel

    private var config: AppConfig

    var onFallbackTriggered: ((String) -> Void)?

    private(set) var aiModel: String
    private(set) var translationModelName: String

    // MARK: - Initialization

    init(
        config: AppConfig,
        onFallbackTriggered: ((String) -> Void)? = nil
    ) {

        self.config = config

        self.primaryModelName = config.aiModelName.isEmpty
            ? "gemini-3.1-flash-lite"
            : config.aiModelName

        self.aiModel = self.primaryModelName
        self.translationModelName = self.primaryModelName

        self.onFallbackTriggered = onFallbackTriggered

        let ai = FirebaseAI.firebaseAI(backend: .googleAI())

        self.rewriteModel = ai.generativeModel(
            modelName: self.primaryModelName
        )

        self.translationModel = ai.generativeModel(
            modelName: self.primaryModelName
        )
    }

    // MARK: - Language

    private func selectedLanguage() -> String {

        let savedLanguage = UserDefaults.standard.string(
            forKey: "selectedLanguage"
        ) ?? "en-US"

        let language =
            LanguageProvider.getLanguageByCode(savedLanguage)
            ?? LanguageProvider.getLanguageByName(savedLanguage)

        guard let language,
              language.shortName != "dt" else {
            return savedLanguage
        }

        return "\(language.name) (Base: \(language.type), Locale: \(language.shortName))"
    }

    // MARK: - Rewrite Suggestions

    func fetchSuggestions(
        text: String,
        tone: String
    ) async throws -> [String] {

        let prompt = """
        You are a mobile keyboard assistant.

        Rewrite text to sound natural and human.
        Fix grammar but preserve the original meaning.

        Return a JSON array containing exactly 3 different rewritten options.

        Target language: \(selectedLanguage())
        Tone: \(tone)

        Original text:
        \(text)

        Return only valid JSON.
        Example:
        ["Option 1", "Option 2", "Option 3"]
        """

        return try await generateContent(
            prompt: prompt,
            originalText: text,
            tone: tone,
            isTranslation: false,
            maxResults: 3
        )
    }

    // MARK: - Translation

    func fetchTranslation(
        text: String,
        tone: String = "Neutral"
    ) async throws -> [String] {

        let prompt = """
        You are a mobile keyboard translation assistant.

        Translate the given text faithfully.
        Preserve its meaning and tone.

        Translate into: \(selectedLanguage())

        Do not offer alternatives.

        Return a JSON array containing exactly ONE string.

        Original text:
        \(text)

        Return only valid JSON.
        Example:
        ["Translated text here"]
        """

        return try await generateContent(
            prompt: prompt,
            originalText: text,
            tone: tone,
            isTranslation: true,
            maxResults: 1
        )
    }

    // MARK: - Generate Content

    private func generateContent(
        prompt: String,
        originalText: String,
        tone: String,
        isTranslation: Bool,
        maxResults: Int,
        isRetryAfterFallback: Bool = false
    ) async throws -> [String] {

        let model = isTranslation
            ? translationModel
            : rewriteModel

        let modelName = isTranslation
            ? translationModelName
            : aiModel

        do {

            let response = try await model.generateContent(prompt)

            let rawText = response.text?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

            let results = parseJSONResponse(
                rawText,
                maxResults: maxResults
            )

            guard !results.isEmpty else {
                throw KeyboardAIError.noSuggestions
            }

            // Log in background
            Task.detached {
                await FirestoreLogger.shared.logTrainingPair(
                    TrainingData(
                        tone: tone,
                        prompt: prompt,
                        rawResponse: rawText,
                        modelName: modelName,
                        originalPrompt: originalText,
                        structuredResponse: results,
                        timestamp: nil,
                        usage: nil,
                        language: UserDefaults.standard.string(
                            forKey: "selectedLanguage"
                        )
                    ),
                    isTranslation: isTranslation
                )
            }

            return results

        } catch {

            // Avoid retrying cancelled requests.
            if error is CancellationError {
                throw error
            }

            if !isRetryAfterFallback,
               isServiceUnavailable(error),
               modelName != fallbackModelName {

                print("Switching to fallback model: \(fallbackModelName)")

                let ai = FirebaseAI.firebaseAI(backend: .googleAI())

                if isTranslation {

                    translationModelName = fallbackModelName

                    translationModel = ai.generativeModel(
                        modelName: fallbackModelName
                    )

                } else {

                    aiModel = fallbackModelName

                    rewriteModel = ai.generativeModel(
                        modelName: fallbackModelName
                    )
                }

                onFallbackTriggered?("Please wait…")

                return try await generateContent(
                    prompt: prompt,
                    originalText: originalText,
                    tone: tone,
                    isTranslation: isTranslation,
                    maxResults: maxResults,
                    isRetryAfterFallback: true
                )
            }

            throw error
        }
    }

    // MARK: - Service Unavailable

    private func isServiceUnavailable(_ error: Error) -> Bool {

        let message = error.localizedDescription.lowercased()

        return message.contains("503")
            || message.contains("unavailable")
            || message.contains("overloaded")
            || message.contains("service unavailable")
    }

    // MARK: - JSON Parser

    private func parseJSONResponse(
        _ rawText: String,
        maxResults: Int
    ) -> [String] {

        var cleanJSON = rawText
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Handle occasional surrounding text.
        if let start = cleanJSON.firstIndex(of: "["),
           let end = cleanJSON.lastIndex(of: "]"),
           start <= end {

            cleanJSON = String(cleanJSON[start...end])
        }

        if let data = cleanJSON.data(using: .utf8),
           let array = try? JSONSerialization.jsonObject(
                with: data
           ) as? [String] {

            return array
                .filter { !$0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty }
                .prefix(maxResults)
                .map { $0 }
        }

        // Fallback parser
        return rawText
            .components(separatedBy: .newlines)
            .map {
                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .replacingOccurrences(of: #"^[-*]\s*"#,
                                      with: "",
                                      options: .regularExpression)
            }
            .filter { !$0.isEmpty }
            .prefix(maxResults)
            .map { $0 }
    }
}

// MARK: - Errors

enum KeyboardAIError: LocalizedError {

    case noSuggestions

    var errorDescription: String? {

        switch self {
        case .noSuggestions:
            return "No suggestions found"
        }
    }
}
