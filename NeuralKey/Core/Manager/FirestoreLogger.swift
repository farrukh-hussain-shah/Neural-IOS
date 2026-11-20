//
//  FirestoreLogger.swift
//  NeuralKey
//
//  Created by Macbook 5 on 11/20/26.
//



import Foundation
import FirebaseFirestore

actor FirestoreLogger {

    static let shared = FirestoreLogger()

    private let db = Firestore.firestore()

    private init() {}

    func logTrainingPair(
        _ data: TrainingData,
        isTranslation: Bool,
        collection: String = "training_data_set"
    ) async {

        var document: [String: Any] = [
            "tone": data.tone,
            "prompt": data.prompt,
            "rawResponse": data.rawResponse,
            "modelName": data.modelName,
            "structuredResponse": data.structuredResponse ?? [],
            "timestamp": FieldValue.serverTimestamp()
        ]

        if let originalPrompt = data.originalPrompt {
            document["originalPrompt"] = originalPrompt
        }

        if let language = data.language {
            document["language"] = language
        }

        if let usage = data.usage {
            document["usage"] = [
                "promptTokenCount": usage.promptTokenCount ?? 0,
                "candidatesTokenCount": usage.candidatesTokenCount ?? 0,
                "totalTokenCount": usage.totalTokenCount ?? 0
            ]
        }

        do {
            try await db.collection(collection)
                .addDocument(data: document)

            print("Training data logged successfully")

        } catch {
            print("Firestore logging error:", error.localizedDescription)
        }
    }

    func logVoiceTrainingData(
        _ data: VoiceTrainingData,
        collection: String = "voice_training_data"
    ) async {

        var document: [String: Any] = [
            "id": data.id,
            "response": data.response,
            "prompt": data.prompt,
            "timestamp": FieldValue.serverTimestamp()
        ]

        if let language = data.language {
            document["language"] = language
        }

        if let voiceUrl = data.voiceUrl {
            document["voiceUrl"] = voiceUrl
        }

        if let voicePath = data.voicePath {
            document["voicePath"] = voicePath
        }

        do {
            try await db.collection(collection)
                .addDocument(data: document)

            print("Voice training data logged successfully")

        } catch {
            print("Voice Firestore error:", error.localizedDescription)
        }
    }
}
