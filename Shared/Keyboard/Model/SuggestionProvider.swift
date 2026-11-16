import Foundation

struct KeyboardSuggestion: Identifiable, Equatable {
    enum Kind: Equatable {
        case verbatim
        case completion
    }

    let id: Int
    let text: String
    let kind: Kind

    var displayText: String {
        kind == .verbatim ? "“\(text)”" : text
    }
}

enum SuggestionProvider {
    static let slotCount = 3

    static func suggestions(forTextBeforeCursor text: String) -> [KeyboardSuggestion] {
        let word = currentWord(in: text)
        guard !word.isEmpty else {
            let previous = lastWord(in: text)?.lowercased()
            let next = previous.flatMap { nextWords[$0] } ?? startWords
            return next.prefix(slotCount).enumerated().map { KeyboardSuggestion(id: $0, text: $1, kind: .completion) }
        }

        let lowercased = word.lowercased()
        let candidates = (dictionary[String(lowercased.prefix(1))] ?? [])
            .filter { $0.lowercased().hasPrefix(lowercased) && $0.lowercased() != lowercased }
            .map { matchCase(of: word, $0) }
        let completions = candidates.prefix(slotCount - 1)
        var result = [KeyboardSuggestion(id: 0, text: word, kind: .verbatim)]
        result += completions.enumerated().map { KeyboardSuggestion(id: $0 + 1, text: $1, kind: .completion) }
        return result
    }

    static func currentWord(in text: String) -> String {
        String(text.reversed().prefix { $0.isLetter || $0 == "'" }.reversed())
    }

    private static func lastWord(in text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard trimmed.count < text.count else { return nil }
        let word = currentWord(in: trimmed)
        return word.isEmpty ? nil : word
    }

    private static func matchCase(of typed: String, _ word: String) -> String {
        guard let first = typed.first, first.isUppercase else { return word }
        return word.prefix(1).uppercased() + word.dropFirst()
    }

    private static let startWords = ["I", "The", "I’m"]

    private static let nextWords: [String: [String]] = [
        "i": ["am", "have", "will"],
        "the": ["best", "same", "first"],
        "i’m": ["going", "not", "so"],
        "hello": ["there", "how", "and"],
        "thank": ["you", "God", "goodness"],
        "how": ["are", "is", "about"],
        "good": ["morning", "night", "luck"]
    ]

    private static let dictionary: [String: [String]] = [
        "a": ["about", "after", "again", "all", "also", "always", "am", "an", "and", "any", "are", "around", "as", "ask", "at", "away", "able", "actually", "already", "amazing"],
        "b": ["back", "be", "because", "been", "before", "being", "best", "better", "between", "big", "both", "busy", "but", "by", "bring", "brother", "book", "beautiful", "birthday", "break"],
        "c": ["call", "came", "can", "can’t", "care", "case", "change", "check", "city", "class", "close", "come", "coming", "could", "course", "cool", "coffee", "chat", "chance", "clear"],
        "d": ["day", "did", "didn’t", "different", "do", "does", "doing", "done", "don’t", "down", "during", "dinner", "dear", "deal", "dream", "drive", "draft", "detail", "decide", "definitely"],
        "e": ["each", "early", "easy", "eat", "else", "email", "end", "enough", "even", "evening", "ever", "every", "everyone", "everything", "exactly", "excited", "expect", "explain", "extra", "eye"],
        "f": ["family", "fast", "feel", "few", "fine", "first", "follow", "food", "for", "forget", "free", "friend", "friends", "from", "fun", "funny", "future", "find", "finish", "favorite"],
        "g": ["game", "get", "getting", "give", "glad", "go", "going", "gone", "good", "got", "great", "group", "guess", "guys", "gift", "goal", "grab", "green", "grow", "guide"],
        "h": ["had", "half", "happy", "hard", "has", "have", "he", "hear", "hello", "help", "her", "here", "hey", "him", "his", "home", "hope", "hour", "how", "hungry"],
        "i": ["idea", "if", "important", "in", "info", "inside", "instead", "interesting", "into", "invite", "is", "isn’t", "it", "it’s", "item", "its", "itself", "ignore", "image", "include"],
        "j": ["job", "join", "joke", "journey", "joy", "judge", "juice", "jump", "just", "July", "June", "January", "jacket", "jam", "jeans", "jet", "jog", "jolly", "journal", "junior"],
        "k": ["keep", "key", "kid", "kids", "kind", "kinda", "kitchen", "knew", "know", "known", "knows", "keen", "kept", "kick", "kill", "king", "kiss", "knee", "knock", "kudos"],
        "l": ["last", "late", "later", "laugh", "learn", "least", "leave", "left", "less", "let", "let’s", "life", "like", "line", "list", "little", "live", "long", "look", "love"],
        "m": ["made", "make", "many", "maybe", "me", "mean", "meet", "meeting", "message", "might", "mind", "minute", "miss", "moment", "money", "more", "morning", "most", "much", "my"],
        "n": ["name", "need", "never", "new", "news", "next", "nice", "night", "no", "nothing", "not", "now", "number", "near", "nearly", "neat", "nope", "normal", "note", "notice"],
        "o": ["of", "off", "office", "often", "oh", "ok", "okay", "old", "on", "once", "one", "only", "open", "or", "order", "other", "our", "out", "over", "own"],
        "p": ["page", "part", "party", "people", "perfect", "person", "phone", "pick", "place", "plan", "play", "please", "point", "possible", "post", "pretty", "probably", "problem", "put", "proud"],
        "q": ["quality", "quarter", "queen", "query", "question", "questions", "quick", "quickly", "quiet", "quite", "quit", "quote", "quiz", "queue", "quest", "quirky", "quotes", "quietly", "qualify", "quantity"],
        "r": ["ran", "rather", "read", "ready", "real", "really", "reason", "remember", "reply", "rest", "right", "room", "run", "round", "rain", "reach", "real", "relax", "report", "review"],
        "s": ["said", "same", "saw", "say", "school", "see", "seems", "send", "sent", "should", "show", "since", "so", "some", "something", "soon", "sorry", "still", "sure", "sweet"],
        "t": ["take", "talk", "tell", "than", "thank", "thanks", "that", "the", "their", "them", "then", "there", "they", "thing", "think", "this", "time", "to", "today", "tomorrow"],
        "u": ["under", "understand", "until", "up", "update", "upon", "us", "use", "used", "usually", "ugly", "ultimate", "umbrella", "uncle", "unique", "unless", "unlock", "upset", "urgent", "useful"],
        "v": ["very", "video", "visit", "voice", "vacation", "value", "various", "version", "view", "vibe", "village", "visible", "vision", "vital", "vivid", "volume", "vote", "voyage", "valid", "venue"],
        "w": ["wait", "want", "was", "watch", "way", "we", "week", "weekend", "well", "went", "were", "what", "when", "where", "which", "while", "who", "why", "will", "with"],
        "x": ["xylophone", "xenon", "xerox", "xmas", "x-ray", "xbox", "xl", "xoxo", "xenial", "xeric", "xylem", "xanthic", "xebec", "xenia", "xeriscape", "xiphoid", "xu", "xylitol", "xyst", "xr"],
        "y": ["yeah", "year", "years", "yellow", "yes", "yesterday", "yet", "you", "you’re", "young", "your", "yours", "yourself", "yummy", "yay", "yard", "yawn", "yell", "yield", "youth"],
        "z": ["zero", "zone", "zoom", "zip", "zoo", "zeal", "zebra", "zen", "zest", "zigzag", "zinc", "zipper", "zodiac", "zombie", "zones", "zoning", "zucchini", "zany", "zealous", "zesty"]
    ]
}
