import SwiftUI
import UIKit

/// The app shows its text in the language picked on the language screen, not the iPhone's
/// language, and switches the moment a language is picked.
///
/// How it works:
/// - Every string is in `Localizable.xcstrings`, translated into each `AppLanguage`.
/// - `appLanguage(_:)` puts the language's locale in the SwiftUI environment at the root, so
///   every `Text` with a localized key re-renders in that language.
/// - Layout always stays left to right, also in Arabic, so no screen is mirrored.
/// - The few UIKit strings (a text field's placeholder) use `AppLocalization.string(_:locale:)`.
enum AppLocalization {
    /// Forces left-to-right layout for UIKit views too, even when the iPhone itself is set to a
    /// right-to-left language. Called once at launch.
    static func configureLayoutDirection() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
    }

    /// `key` translated into `locale`'s language, or `key` itself when there is no translation.
    static func string(_ key: String, locale: Locale) -> String {
        let bundle = bundle(for: locale) ?? .main
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }

    private static func bundle(for locale: Locale) -> Bundle? {
        let identifier = locale.identifier.replacingOccurrences(of: "_", with: "-")
        let candidates = [identifier, locale.language.languageCode?.identifier].compactMap { $0 }
        for code in candidates {
            if let path = Bundle.main.path(forResource: code, ofType: "lproj"), let bundle = Bundle(path: path) {
                return bundle
            }
        }
        return nil
    }
}

extension View {
    /// Shows this view's text in `language`, laid out left to right.
    func appLanguage(_ language: AppLanguage) -> some View {
        environment(\.locale, language.locale)
            .environment(\.layoutDirection, .leftToRight)
    }
}
