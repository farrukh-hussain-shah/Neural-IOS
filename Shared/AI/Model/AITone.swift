import SwiftUI

enum AITone: String, CaseIterable, Identifiable {
    case humanize
    case translate
    case fixGrammar
    case shorten
    case expand
    case simplify
    case bullets
    case emojify
    case professional
    case email
    case formal
    case diplomatic
    case persuasive
    case assertive
    case urgent
    case casual
    case funny
    case friendly
    case witty
    case sarcastic
    case genZ
    case empathetic
    case polite
    case poetic
    case excited
    case confident
    case romantic
    case dramatic
    case flirty
    case apologetic
    case storyteller
    case oldEnglish
    case robot

    static let minimumSelection = 5

    static let defaultSelection: Set<AITone> = [
        .humanize, .fixGrammar, .simplify, .emojify,
        .professional, .formal,
        .funny,
        .confident, .romantic, .dramatic
    ]

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .humanize: "Humanize"
        case .translate: "Translate"
        case .fixGrammar: "Fix Grammar"
        case .shorten: "Shorten"
        case .expand: "Expand"
        case .simplify: "Simplify"
        case .bullets: "Bullets"
        case .emojify: "Emojify"
        case .professional: "Professional"
        case .email: "Email"
        case .formal: "Formal"
        case .diplomatic: "Diplomatic"
        case .persuasive: "Persuasive"
        case .assertive: "Assertive"
        case .urgent: "Urgent"
        case .casual: "Casual"
        case .funny: "Funny"
        case .friendly: "Friendly"
        case .witty: "Witty"
        case .sarcastic: "Sarcastic"
        case .genZ: "Gen Z"
        case .empathetic: "Empathetic"
        case .polite: "Polite"
        case .poetic: "Poetic"
        case .excited: "Excited"
        case .confident: "Confident"
        case .romantic: "Romantic"
        case .dramatic: "Dramatic"
        case .flirty: "Flirty"
        case .apologetic: "Apologetic"
        case .storyteller: "Storyteller"
        case .oldEnglish: "Old English"
        case .robot: "Robot"
        }
    }

    var iconName: String {
        let source = self == .emojify ? AITone.friendly.rawValue : rawValue
        return "Tone" + source.prefix(1).uppercased() + source.dropFirst()
    }
}

enum AIToneCategory: CaseIterable, Identifiable {
    case essentials
    case professional
    case social
    case emotionalCreative

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .essentials: "Essentials"
        case .professional: "Professional"
        case .social: "Social"
        case .emotionalCreative: "Emotional & Creative"
        }
    }

    var tones: [AITone] {
        switch self {
        case .essentials:
            [.humanize, .translate, .fixGrammar, .shorten, .expand, .simplify, .bullets, .emojify]
        case .professional:
            [.professional, .email, .formal, .diplomatic, .persuasive, .assertive, .urgent]
        case .social:
            [.casual, .funny, .friendly, .witty, .sarcastic, .genZ]
        case .emotionalCreative:
            [
                .empathetic, .polite, .poetic, .excited, .confident, .romantic,
                .dramatic, .flirty, .apologetic, .storyteller, .oldEnglish, .robot
            ]
        }
    }
}
