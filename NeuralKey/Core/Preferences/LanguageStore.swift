import Foundation
import Observation

@MainActor
@Observable
final class LanguageStore {
    private static let storageKey = "NKSelectedLanguage"

    private(set) var selectedLanguage: AppLanguage

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        selectedLanguage = defaults.string(forKey: Self.storageKey)
            .flatMap(AppLanguage.init(rawValue:)) ?? .defaultLanguage
    }

    func select(_ language: AppLanguage) {
        selectedLanguage = language
        defaults.set(language.rawValue, forKey: Self.storageKey)
    }
}
