import Foundation

/// Judges how likely a one-edit correction is as a real typo.
///
/// Edit distance alone treats every edit the same, but people mostly mistype in a few ways:
/// skipping a letter ("helo" → "hello"), swapping two letters ("teh" → "the"), hitting a key
/// next to the right one ("helo" → "help": o and p are neighbours) or doubling a letter
/// ("helllo" → "hello"). Corrections that fit one of these get a bonus, so "hello" is offered
/// for "helo" even though "halo" and "held" are more frequent words.
enum TypoModel {
    enum Kind: Equatable {
        /// The typed word is missing one letter of the correction.
        case missingLetter
        /// Two neighbouring letters are swapped.
        case swappedLetters
        /// One letter was typed twice.
        case doubledLetter
        /// One letter is replaced by a key next to it on the keyboard.
        case neighbouringKey
        /// Any other edit, or more than one.
        case other
    }

    static func kind(typed: [UInt32], correction: [UInt32]) -> Kind {
        if correction.count == typed.count + 1, isMissingOneLetter(typed, from: correction) {
            return .missingLetter
        }
        if typed.count == correction.count + 1, let extra = extraLetterPosition(typed, comparedTo: correction) {
            let letter = typed[extra]
            let repeatsNeighbour = (extra > 0 && typed[extra - 1] == letter)
                || (extra + 1 < typed.count && typed[extra + 1] == letter)
            return repeatsNeighbour ? .doubledLetter : .other
        }
        guard typed.count == correction.count else { return .other }
        let differences = typed.indices.filter { typed[$0] != correction[$0] }
        if differences.count == 2, differences[1] == differences[0] + 1,
           typed[differences[0]] == correction[differences[1]], typed[differences[1]] == correction[differences[0]] {
            return .swappedLetters
        }
        if differences.count == 1, areNeighbouringKeys(typed[differences[0]], correction[differences[0]]) {
            return .neighbouringKey
        }
        return .other
    }

    /// The score bonus for a correction of this kind.
    static func bonus(for kind: Kind) -> Int {
        switch kind {
        case .missingLetter, .swappedLetters, .doubledLetter:
            return TextPredictionConfiguration.Ranking.likelyTypoBonus
        case .neighbouringKey:
            return TextPredictionConfiguration.Ranking.neighbouringKeyBonus
        case .other:
            return 0
        }
    }

    private static func isMissingOneLetter(_ shorter: [UInt32], from longer: [UInt32]) -> Bool {
        extraLetterPosition(longer, comparedTo: shorter) != nil
    }

    /// The position of the one letter in `longer` that, removed, leaves `shorter`.
    private static func extraLetterPosition(_ longer: [UInt32], comparedTo shorter: [UInt32]) -> Int? {
        var position = 0
        while position < shorter.count, longer[position] == shorter[position] {
            position += 1
        }
        return longer[(position + 1)...].elementsEqual(shorter[position...]) ? position : nil
    }

    // MARK: - Keyboard geometry

    /// The letter rows of the QWERTY layout and how far each row is shifted right, in keys.
    private static let rows: [(letters: String, offset: Double)] = [
        ("qwertyuiop", 0),
        ("asdfghjkl", 0.5),
        ("zxcvbnm", 1.5)
    ]

    private static let positions: [UInt32: (x: Double, y: Double)] = {
        var positions: [UInt32: (x: Double, y: Double)] = [:]
        for (row, line) in rows.enumerated() {
            for (column, letter) in line.letters.unicodeScalars.enumerated() {
                positions[letter.value] = (Double(column) + line.offset, Double(row))
            }
        }
        return positions
    }()

    private static func areNeighbouringKeys(_ a: UInt32, _ b: UInt32) -> Bool {
        guard let first = positions[a], let second = positions[b] else { return false }
        let dx = abs(first.x - second.x)
        let dy = abs(first.y - second.y)
        return (dy == 0 && dx == 1) || (dy == 1 && dx <= 0.5)
    }
}
