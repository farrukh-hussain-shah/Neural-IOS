import Foundation

enum KeyboardLayer: Equatable {
    case letters
    case numbers
    case symbols
    case phoneDigits
    case phoneSymbols
}

enum ShiftState: Equatable {
    case off
    case on
    case capsLock
}

enum KeyboardAction: Equatable {
    case character(String)
    case backspace
    case space
    case shift
    case layer(KeyboardLayer)
    case returnKey
    case emoji
    case dictation
}

struct KeyboardKey: Identifiable, Equatable {
    enum Style: Equatable {
        case character
        case function
        case primary
        case transparent
    }

    let id: String
    let action: KeyboardAction
    let width: CGFloat
    var gapAfter: CGFloat
    var style: Style = .character
    var subtitle: String?

    static func character(_ value: String, width: CGFloat, gapAfter: CGFloat, subtitle: String? = nil) -> KeyboardKey {
        KeyboardKey(id: "key.\(value)", action: .character(value), width: width, gapAfter: gapAfter, subtitle: subtitle)
    }
}

struct KeyboardRow: Identifiable, Equatable {
    let id: Int
    let leadingInset: CGFloat
    let keys: [KeyboardKey]
}

enum KeyboardLayout {
    static let designWidth: CGFloat = 402
    static let rowHeight: CGFloat = 45
    static let rowSpacing: CGFloat = 10
    static let phoneRowHeight: CGFloat = 50
    static let phoneRowSpacing: CGFloat = 6

    static func rows(for layer: KeyboardLayer, configuration: KeyboardConfiguration) -> [KeyboardRow] {
        switch layer {
        case .letters:
            letterRows + [bottomRow(switchTo: .numbers, label: "123", configuration: configuration)]
        case .numbers:
            numberRows + [bottomRow(switchTo: .letters, label: "ABC", configuration: configuration)]
        case .symbols:
            symbolRows + [bottomRow(switchTo: .letters, label: "ABC", configuration: configuration)]
        case .phoneDigits:
            phoneRows(phoneDigitKeys, toggleTo: .phoneSymbols, toggleLabel: "+*#")
        case .phoneSymbols:
            phoneRows(phoneSymbolKeys, toggleTo: .phoneDigits, toggleLabel: "123")
        }
    }

    static let alternates: [String: [String]] = [
        "a": ["à", "á", "â", "ä", "æ", "ã", "å", "ā"],
        "c": ["ç", "ć", "č"],
        "e": ["è", "é", "ê", "ë", "ē", "ė", "ę"],
        "i": ["î", "ï", "í", "ī", "į", "ì"],
        "l": ["ł"],
        "n": ["ñ", "ń"],
        "o": ["ô", "ö", "ò", "ó", "œ", "ø", "ō", "õ"],
        "s": ["ß", "ś", "š"],
        "u": ["û", "ü", "ù", "ú", "ū"],
        "y": ["ÿ"],
        "z": ["ž", "ź", "ż"],
        "0": ["°"],
        "-": ["–", "—", "•"],
        "/": ["\\"],
        "€": ["$", "£", "¥", "₩", "₽", "¢"],
        "&": ["§"],
        ".": ["…"],
        "?": ["¿"],
        "!": ["¡"],
        "'": ["‘", "’", "`"],
        "\"": ["„", "“", "”", "«", "»"]
    ]

    private static func characterRow(_ id: Int, _ characters: [String], inset: CGFloat, width: CGFloat, gap: CGFloat) -> KeyboardRow {
        let keys = characters.enumerated().map { index, value in
            KeyboardKey.character(value, width: width, gapAfter: index == characters.count - 1 ? 0 : gap)
        }
        return KeyboardRow(id: id, leadingInset: inset, keys: keys)
    }

    private static let letterRows: [KeyboardRow] = [
        characterRow(0, ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"], inset: 4, width: 34, gap: 6),
        characterRow(1, ["a", "s", "d", "f", "g", "h", "j", "k", "l"], inset: 20, width: 34.889, gap: 6),
        KeyboardRow(
            id: 2,
            leadingInset: 4,
            keys: [KeyboardKey(id: "key.shift", action: .shift, width: 42, gapAfter: 14, style: .function)]
                + characterRow(2, ["z", "x", "c", "v", "b", "n", "m"], inset: 0, width: 35.143, gap: 6).keys.withLastGap(14)
                + [backspaceKey]
        )
    ]

    private static let numberRows: [KeyboardRow] = [
        characterRow(0, ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"], inset: 4, width: 33.1, gap: 7),
        characterRow(1, ["-", "/", ":", ";", "(", ")", "€", "&", "@", "\""], inset: 4, width: 33.1, gap: 7),
        punctuationRow(switchTo: .symbols, label: "#+=")
    ]

    private static let symbolRows: [KeyboardRow] = [
        characterRow(0, ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="], inset: 4, width: 33.1, gap: 7),
        characterRow(1, ["_", "\\", "|", "~", "<", ">", "$", "£", "¥", "•"], inset: 4, width: 33.1, gap: 7),
        punctuationRow(switchTo: .numbers, label: "123")
    ]

    private static let backspaceKey = KeyboardKey(id: "key.delete", action: .backspace, width: 42, gapAfter: 0, style: .function)

    private static func punctuationRow(switchTo layer: KeyboardLayer, label: String) -> KeyboardRow {
        KeyboardRow(
            id: 2,
            leadingInset: 4,
            keys: [KeyboardKey(id: "key.layer.\(label)", action: .layer(layer), width: 45, gapAfter: 14, style: .function, subtitle: label)]
                + characterRow(2, [".", ",", "?", "!", "'"], inset: 0, width: 50.2, gap: 7).keys.withLastGap(14)
                + [backspaceKey]
        )
    }

    private static func bottomRow(switchTo layer: KeyboardLayer, label: String, configuration: KeyboardConfiguration) -> KeyboardRow {
        let layerKey = KeyboardKey(id: "key.layer.\(label)", action: .layer(layer), width: 91, gapAfter: 6, style: .function, subtitle: label)
        switch configuration.returnKey {
        case .return:
            return KeyboardRow(id: 3, leadingInset: 4, keys: [
                layerKey,
                KeyboardKey(id: "key.space", action: .space, width: 200, gapAfter: 6, style: .function),
                KeyboardKey(id: "key.return", action: .returnKey, width: 91, gapAfter: 0, style: .function)
            ])
        case .go:
            return KeyboardRow(id: 3, leadingInset: 4, keys: [
                layerKey,
                KeyboardKey(id: "key.space", action: .space, width: 177, gapAfter: 6, style: .function),
                KeyboardKey.character(".", width: 44, gapAfter: 6),
                KeyboardKey(id: "key.return", action: .returnKey, width: 64, gapAfter: 0, style: .primary)
            ])
        }
    }

    private static let phoneDigitKeys: [(String, String?)] = [
        ("1", nil), ("2", "ABC"), ("3", "DEF"),
        ("4", "GHI"), ("5", "JKL"), ("6", "MNO"),
        ("7", "PQRS"), ("8", "TUV"), ("9", "WXYZ")
    ]

    private static let phoneSymbolKeys: [(String, String?)] = [
        ("+", nil), ("*", nil), ("#", nil),
        ("(", nil), (")", nil), ("/", nil),
        (",", nil), (";", nil), ("-", nil)
    ]

    private static func phoneRows(_ keys: [(String, String?)], toggleTo layer: KeyboardLayer, toggleLabel: String) -> [KeyboardRow] {
        let width: CGFloat = 123
        let gap: CGFloat = 6
        var rows: [KeyboardRow] = stride(from: 0, to: keys.count, by: 3).map { start in
            let rowKeys = keys[start..<start + 3].enumerated().map { offset, key in
                KeyboardKey.character(key.0, width: width, gapAfter: offset == 2 ? 0 : gap, subtitle: key.1)
            }
            return KeyboardRow(id: start / 3, leadingInset: 10.5, keys: rowKeys)
        }
        rows.append(KeyboardRow(id: 3, leadingInset: 10.5, keys: [
            KeyboardKey(id: "key.layer.\(toggleLabel)", action: .layer(layer), width: width, gapAfter: gap, style: .transparent, subtitle: toggleLabel),
            KeyboardKey.character("0", width: width, gapAfter: gap, subtitle: ""),
            KeyboardKey(id: "key.delete", action: .backspace, width: width, gapAfter: 0, style: .transparent)
        ]))
        return rows
    }
}

private extension Array where Element == KeyboardKey {
    func withLastGap(_ gap: CGFloat) -> [KeyboardKey] {
        guard var last = self.last else { return self }
        last.gapAfter = gap
        return Array(dropLast()) + [last]
    }
}
