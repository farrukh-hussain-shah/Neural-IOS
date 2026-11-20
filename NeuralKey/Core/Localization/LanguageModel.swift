//
//  LanguageModel.swift
//  NeuralKey
//
//  Created by Macbook 5 on 11/20/26.
//



import Foundation

struct LanguageModel: Identifiable, Hashable {

    var id: String { shortName }

    let name: String
    let shortName: String
    let type: String
}

enum LanguageProvider {

    static let languageList: [LanguageModel] = [

        // Detection
        .init(name: "Detect", shortName: "dt", type: "Auto Detect"),

        // English
        .init(name: "English (US)", shortName: "en-US", type: "English"),
        .init(name: "English (UK)", shortName: "en-GB", type: "English"),
        .init(name: "English (Australia)", shortName: "en-AU", type: "English"),

        // Spanish
        .init(name: "Spanish (Spain)", shortName: "es-ES", type: "Spanish"),
        .init(name: "Spanish (Latin America)", shortName: "es-MX", type: "Spanish"),

        // French
        .init(name: "French (France)", shortName: "fr-FR", type: "French"),
        .init(name: "French (Canada)", shortName: "fr-CA", type: "French"),

        // Portuguese
        .init(name: "Portuguese (Portugal)", shortName: "pt-PT", type: "Portuguese"),
        .init(name: "Portuguese (Brazil)", shortName: "pt-BR", type: "Portuguese"),

        // Chinese
        .init(name: "Chinese (Simplified)", shortName: "zh-CN", type: "Chinese"),
        .init(name: "Chinese (Traditional)", shortName: "zh-TW", type: "Chinese"),

        // Arabic
        .init(name: "Arabic (Modern Standard)", shortName: "ar-SA", type: "Arabic"),
        .init(name: "Arabic (Egypt)", shortName: "ar-EG", type: "Arabic"),
        .init(name: "Arabic (UAE)", shortName: "ar-AE", type: "Arabic"),

        // South Asia
        .init(name: "Urdu", shortName: "ur-PK", type: "Urdu"),
        .init(name: "Roman Urdu", shortName: "rm-PK", type: "Roman Urdu"),
        .init(name: "Hindi", shortName: "hi-IN", type: "Hindi"),
        .init(name: "Roman Hindi", shortName: "rh-IN", type: "Roman Hindi"),
        .init(name: "Bengali", shortName: "bn-BD", type: "Bengali"),
        .init(name: "Punjabi (Indian)", shortName: "pa-IN", type: "Punjabi"),
        .init(name: "Punjabi (Pakistani)", shortName: "pa-PK", type: "Punjabi"),
        .init(name: "Saraiki", shortName: "skr-PK", type: "Saraiki"),

        // European
        .init(name: "German", shortName: "de-DE", type: "German"),
        .init(name: "Italian", shortName: "it-IT", type: "Italian"),
        .init(name: "Russian", shortName: "ru-RU", type: "Russian"),
        .init(name: "Dutch", shortName: "nl-NL", type: "Dutch"),
        .init(name: "Polish", shortName: "pl-PL", type: "Polish"),
        .init(name: "Ukrainian", shortName: "uk-UA", type: "Ukrainian"),

        // East & Southeast Asia
        .init(name: "Japanese", shortName: "ja-JP", type: "Japanese"),
        .init(name: "Korean", shortName: "ko-KR", type: "Korean"),
        .init(name: "Indonesian", shortName: "id-ID", type: "Indonesian"),
        .init(name: "Vietnamese", shortName: "vi-VN", type: "Vietnamese"),
        .init(name: "Thai", shortName: "th-TH", type: "Thai"),
        .init(name: "Filipino", shortName: "tl-PH", type: "Filipino"),

        // Middle East
        .init(name: "Turkish", shortName: "tr-TR", type: "Turkish"),
        .init(name: "Persian", shortName: "fa-IR", type: "Persian")
    ]

    static func getLanguageByCode(_ code: String) -> LanguageModel? {
        languageList.first {
            $0.shortName.caseInsensitiveCompare(code) == .orderedSame
        }
    }

    static func getLanguageByName(_ name: String) -> LanguageModel? {
        languageList.first {
            $0.name.caseInsensitiveCompare(name) == .orderedSame
        }
    }
}
