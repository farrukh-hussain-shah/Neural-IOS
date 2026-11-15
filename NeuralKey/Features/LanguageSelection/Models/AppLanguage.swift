import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case spanish
    case portuguese
    case russian
    case arabic
    case chinese
    case hindi

    static let defaultLanguage: AppLanguage = .english

    var id: String { rawValue }

    var name: LocalizedStringKey {
        switch self {
        case .english: "English"
        case .spanish: "Spanish"
        case .portuguese: "Portuguese"
        case .russian: "Russian"
        case .arabic: "Arabic"
        case .chinese: "Chinese"
        case .hindi: "Hindi"
        }
    }

    var selectionHint: LocalizedStringKey {
        switch self {
        case .english: "Select English"
        case .spanish: "Select Spanish"
        case .portuguese: "Select Portuguese"
        case .russian: "Select Russian"
        case .arabic: "Select Arabic"
        case .chinese: "Select Chinese"
        case .hindi: "Select Hindi"
        }
    }

    var flag: AppImage {
        switch self {
        case .english: .flagEnglish
        case .spanish: .flagSpanish
        case .portuguese: .flagPortuguese
        case .russian: .flagRussian
        case .arabic: .flagArabic
        case .chinese: .flagChinese
        case .hindi: .flagHindi
        }
    }
}
