//
//  TrainingUsage.swift
//  NeuralKey
//
//  Created by Macbook 5 on 11/20/26.
//



import Foundation
import FirebaseFirestore

struct TrainingUsage: Codable {
    var promptTokenCount: Int?
    var candidatesTokenCount: Int?
    var totalTokenCount: Int?
}

struct TrainingData: Codable {

    let tone: String
    let prompt: String
    let rawResponse: String

    var modelName: String = "gemini-2.5-flash-lite"

    var originalPrompt: String?
    var structuredResponse: [String]?

    @ServerTimestamp var timestamp: Timestamp?

    var usage: TrainingUsage?
    var language: String?
}
