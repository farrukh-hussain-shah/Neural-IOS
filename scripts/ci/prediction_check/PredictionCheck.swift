import Foundation

// Checks the text prediction engine (Shared/TextPrediction) against the real downloaded word
// lists, on the CI Mac, without a simulator. Built and run by scripts/ci/check_prediction.sh.
//
// It downloads the lists with `DictionaryDownloader` into a temporary folder, then checks
// SymSpell against a brute-force search, corrections, completions, next words, learning and
// saving, and prints timings.

@main
struct PredictionCheck {
    static func main() async throws {
        var failures = 0

        func check(_ condition: Bool, _ message: String) {
            if condition {
                print("  ok    \(message)")
            } else {
                failures += 1
                print("  FAIL  \(message)")
            }
        }

        func milliseconds(since start: Date) -> Int {
            Int(Date().timeIntervalSince(start) * 1000)
        }

        let root = FileManager.default.temporaryDirectory.appendingPathComponent("prediction-check-\(UUID().uuidString)")
        let storage = PredictionStorage(roots: [root])

        print("Downloading word lists")
        let downloader = DictionaryDownloader(storage: storage)
        let downloaded = await downloader.refreshIfNeeded()
        check(downloaded, "both lists download")
        check(storage.existingFile(for: .words) != nil && storage.existingFile(for: .bigrams) != nil, "both lists are saved")
        let downloadedAgain = await downloader.refreshIfNeeded()
        check(!downloadedAgain, "a second launch doesn't download again")
        let signature = storage.dictionarySignature()
        _ = await downloader.refreshIfNeeded(force: true)
        check(storage.dictionarySignature() != nil, "a forced refresh keeps a valid list (\(signature != nil ? "had one" : "none"))")

        print("Loading")
        var start = Date()
        guard let wordsFile = storage.existingFile(for: .words), let bigramsFile = storage.existingFile(for: .bigrams),
              let lexicon = try? Lexicon.load(wordsFile: wordsFile, bigramsFile: bigramsFile) else {
            print("FAIL  could not load the lexicon")
            exit(1)
        }
        print("  loaded \(lexicon.wordCount) words in \(milliseconds(since: start)) ms")
        check(lexicon.wordCount > 30_000, "the word list has over 30,000 words")
        check(lexicon.word(forKey: "air")?.display == "air", "case variants merge to the lowercase spelling")
        check(lexicon.word(forKey: "aaron")?.display == "Aaron", "names keep their capital")

        print("SymSpell matches a brute-force search")
        let wordsText = try String(contentsOf: wordsFile, encoding: .utf8)
        let allKeys = Array(Set(FrequencyListParser.words(in: wordsText).map { WordNormalizer.key(for: $0.word) })).sorted()
        let index = SymSpellIndex(words: allKeys)
        var generator = SystemRandomNumberGenerator()
        var mismatches = 0
        var lookups = 0
        var lookupTime: TimeInterval = 0
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        for _ in 0..<300 {
            var typo = Array(allKeys.randomElement(using: &generator)!)
            for _ in 0..<Int.random(in: 1...2, using: &generator) where typo.count > 1 {
                let position = Int.random(in: 0..<typo.count, using: &generator)
                switch Int.random(in: 0..<3, using: &generator) {
                case 0: typo.remove(at: position)
                case 1: typo.insert(letters.randomElement(using: &generator)!, at: position)
                default: typo[position] = letters.randomElement(using: &generator)!
                }
            }
            let term = String(typo)
            let lookupStart = Date()
            let found = Set(index.lookup(term, maxDistance: 2).map { allKeys[$0.wordIndex] })
            lookupTime += Date().timeIntervalSince(lookupStart)
            lookups += 1
            let termLetters = WordNormalizer.scalars(of: term)
            let expected = Set(allKeys.filter {
                EditDistance.damerauLevenshtein(termLetters, WordNormalizer.scalars(of: $0), maxDistance: 2) != nil
            })
            if found != expected {
                mismatches += 1
                print("  mismatch for \(term): missing \(expected.subtracting(found).sorted()), extra \(found.subtracting(expected).sorted())")
            }
        }
        check(mismatches == 0, "300 random typos: SymSpell finds exactly the words within 2 edits")
        print("  average lookup \(String(format: "%.2f", lookupTime / Double(lookups) * 1000)) ms")

        print("Edit distance")
        func distance(_ a: String, _ b: String) -> Int? {
            EditDistance.damerauLevenshtein(WordNormalizer.scalars(of: a), WordNormalizer.scalars(of: b), maxDistance: 3)
        }
        check(distance("teh", "the") == 1, "a swap is one edit")
        check(distance("helo", "hello") == 1, "a missing letter is one edit")
        check(distance("kitten", "sitting") == 3, "kitten → sitting is three edits")
        check(distance("abc", "xyzw") == nil, "too far returns nil")

        print("Suggestions while typing")
        let engine = TextPredictionEngine(lexicon: lexicon)
        func suggestions(_ text: String, limit: Int = 2) -> [String] {
            engine.predictions(for: TextContext(textBeforeCursor: text), limit: limit).map(\.text)
        }
        let expectations: [(text: String, expected: String)] = [
            ("helo", "hello"), ("teh", "the"), ("recieve", "receive"), ("becuase", "because"),
            ("tomorow", "tomorrow"), ("realy", "really"), ("waht", "what"), ("definately", "definitely"),
            ("helllo", "hello"), ("pleas", "please"), ("good mor", "morning"), ("happy bir", "birthday"),
            ("Helo", "Hello"), ("HELO", "HELLO")
        ]
        for (text, expected) in expectations {
            let result = suggestions(text)
            check(result.contains(expected), "\"\(text)\" suggests \"\(expected)\" (got \(result))")
        }
        check(!suggestions("cat").contains("can"), "a real word isn't corrected (\"cat\" → \(suggestions("cat")))")

        print("Next words")
        check(suggestions("good ", limit: 3).contains("morning"), "\"good \" predicts \"morning\" (got \(suggestions("good ", limit: 3)))")
        check(suggestions("thank ", limit: 3).first == "you", "\"thank \" predicts \"you\" first")
        check(suggestions("", limit: 3) == ["I", "The", "I’m"], "an empty field offers sentence starters")
        check(suggestions("Hi. ", limit: 3).allSatisfy { $0.first?.isUppercase == true }, "a new sentence is capitalized")

        print("Context")
        let context = TextContext(textBeforeCursor: "I love coff")
        check(context.currentWord == "coff" && context.previousWord == "love" && !context.isSentenceStart, "current and previous word")
        let afterStop = TextContext(textBeforeCursor: "Thanks. ")
        check(afterStop.currentWord.isEmpty && afterStop.previousWord == nil && afterStop.isSentenceStart, "punctuation ends the context")

        print("Learning")
        let name = "Farrukh"
        check(!suggestions("farr").contains(name), "an unknown name isn't suggested before it's learned")
        engine.learn(name, context: TextContext(textBeforeCursor: "with "), source: .typed)
        check(!suggestions("farr").contains(name), "one typed use isn't enough (it could be a typo)")
        engine.learn(name, context: TextContext(textBeforeCursor: "with "), source: .typed)
        check(suggestions("farr").contains(name), "two typed uses teach the name, capital kept (got \(suggestions("farr")))")
        check(suggestions("farukh").contains(name), "learned words are used for corrections (got \(suggestions("farukh")))")

        engine.learn("Zubair", context: TextContext(textBeforeCursor: "and "), source: .keptTypedWord)
        check(suggestions("zuba").contains("Zubair"), "keeping the typed word teaches it at once")

        let before = engine.frequency(ofKey: "hello") ?? 0
        engine.learn("hello", context: TextContext(textBeforeCursor: ""), source: .selectedSuggestion)
        let after = engine.frequency(ofKey: "hello") ?? 0
        check(after == before + TextPredictionConfiguration.Learning.usageWeight, "picking a word raises its frequency (\(before) → \(after))")

        for _ in 0..<10 {
            engine.learn("Farrukh", context: TextContext(textBeforeCursor: "Hello "), source: .selectedSuggestion)
        }
        check(suggestions("Hello ", limit: 3).contains(name), "a pair used often becomes a next-word prediction (got \(suggestions("Hello ", limit: 3)))")
        check(!engine.userDictionary.words.keys.contains("12"), "numbers aren't learned")
        engine.learn("https://x.y", context: TextContext(textBeforeCursor: ""), source: .typed)
        check(engine.userDictionary.learnedWord(forKey: "https://x.y") == nil, "links aren't learned")

        print("Saving")
        let saved = root.appendingPathComponent("user_dictionary.json")
        try engine.userDictionary.save(to: saved)
        check(UserDictionary.load(from: saved) == engine.userDictionary, "learned words survive a save and load")
        check(UserDictionary.load(from: root.appendingPathComponent("missing.json")) == UserDictionary(), "a missing file loads empty")

        print("Speed")
        start = Date()
        var count = 0
        for text in ["h", "he", "hel", "hell", "hello", "helo", "good ", "good m", "definately", "Farr"] {
            for _ in 0..<20 {
                count += engine.predictions(for: TextContext(textBeforeCursor: text), limit: 2).count
            }
        }
        let average = Double(milliseconds(since: start)) / 200
        print("  average \(String(format: "%.2f", average)) ms per keystroke")
        check(average < 30, "suggestions take under 30 ms per keystroke")

        try? FileManager.default.removeItem(at: root)
        print(failures == 0 ? "All prediction checks passed" : "\(failures) prediction check(s) failed")
        exit(failures == 0 ? 0 : 1)
    }
}
