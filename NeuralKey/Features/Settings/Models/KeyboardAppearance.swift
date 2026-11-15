import SwiftUI

enum KeyboardAppearance: String, CaseIterable, Identifiable {
    case system
    case dark
    case light

    static let defaultAppearance: KeyboardAppearance = .system

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .dark: "Dark"
        case .light: "Light"
        }
    }
}
