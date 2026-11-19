import SwiftUI

/// One chip in the Improve panel: how the text should be rewritten.
///
/// Improve and Rephrase are always offered first; after them come the AI tones the user picked
/// in the app (Settings › AI Tone Adjustment).
enum RewriteTone: Hashable, Identifiable, Sendable {
    case improve
    case rephrase
    case tone(AITone)

    enum Icon {
        case symbol(String)
        case asset(String)
    }

    var id: String {
        switch self {
        case .improve: "improve"
        case .rephrase: "rephrase"
        case .tone(let tone): tone.rawValue
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .improve: "Improve"
        case .rephrase: "Rephrase"
        case .tone(let tone): tone.title
        }
    }

    var icon: Icon {
        switch self {
        case .improve: .symbol("sparkles")
        case .rephrase: .symbol("bolt")
        case .tone(let tone): .asset(tone.iconName)
        }
    }

    /// The chips to show, in order.
    static func available(selectedTones: Set<AITone>) -> [RewriteTone] {
        // Translate has its own feature on the keyboard, so it isn't a rewrite style here.
        let tones = AITone.allCases.filter { selectedTones.contains($0) && $0 != .translate }
        return [.improve, .rephrase] + tones.map(RewriteTone.tone)
    }

    /// What the AI is asked to do for this tone.
    var instruction: String {
        switch self {
        case .improve:
            return "Improve the text: fix grammar, spelling and punctuation, and make it clearer and more natural while keeping the meaning and the writer's voice."
        case .rephrase:
            return "Rephrase the text with different wording and sentence structure, keeping the same meaning and a similar length."
        case .tone(let tone):
            return Self.instructions[tone] ?? "Rewrite the text in a \(tone.rawValue) tone."
        }
    }

    private static let instructions: [AITone: String] = [
        .humanize: "Make the text sound natural and human, like a real person typed it: relaxed wording, no robotic or overly formal phrasing.",
        .translate: "Rewrite the text faithfully, changing only what is needed for the target language.",
        .fixGrammar: "Fix only grammar, spelling and punctuation mistakes. Keep the wording otherwise unchanged.",
        .shorten: "Make the text shorter and more concise while keeping its key meaning.",
        .expand: "Expand the text with a little more detail and context, without inventing facts.",
        .simplify: "Simplify the text: short sentences and everyday words that anyone can understand.",
        .bullets: "Turn the text into a short bulleted list (use \"• \" bullets on separate lines).",
        .emojify: "Keep the text and add fitting emojis to make it expressive.",
        .professional: "Make the text professional and polished, suitable for work.",
        .email: "Rewrite the text as a short, well-formed email message body.",
        .formal: "Make the text formal and respectful.",
        .diplomatic: "Make the text diplomatic and tactful, softening anything that could offend.",
        .persuasive: "Make the text persuasive and convincing.",
        .assertive: "Make the text assertive and direct, confident without being rude.",
        .urgent: "Make the text convey urgency clearly and politely.",
        .casual: "Make the text casual and relaxed, like chatting with a friend.",
        .funny: "Make the text funny and light-hearted while keeping the message.",
        .friendly: "Make the text warm and friendly.",
        .witty: "Make the text witty and clever.",
        .sarcastic: "Make the text playfully sarcastic, never mean.",
        .genZ: "Rewrite the text in Gen Z style, with current casual slang.",
        .empathetic: "Make the text empathetic and caring, showing understanding.",
        .polite: "Make the text polite and courteous.",
        .poetic: "Make the text poetic and lyrical.",
        .excited: "Make the text excited and enthusiastic.",
        .confident: "Make the text confident and self-assured.",
        .romantic: "Make the text romantic and affectionate.",
        .dramatic: "Make the text dramatic and expressive.",
        .flirty: "Make the text playful and flirty, keeping it tasteful.",
        .apologetic: "Make the text apologetic and sincere.",
        .storyteller: "Retell the text as a short, engaging little story.",
        .oldEnglish: "Rewrite the text in an old-fashioned, Shakespearean English style.",
        .robot: "Rewrite the text as a robot would say it: precise, mechanical and playful."
    ]
}
