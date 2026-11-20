//
//  VoiceTrainingData.swift
//  NeuralKey
//
//  Created by Macbook 5 on 11/20/26.
//



import Foundation
import FirebaseFirestore

struct VoiceTrainingData: Codable {

    var id: String = ""

    var language: String?
    var voiceUrl: String?
    var voicePath: String?

    var response: String = ""
    var prompt: String = ""

    @ServerTimestamp var timestamp: Timestamp?
}
