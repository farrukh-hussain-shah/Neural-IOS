import CoreText
import Foundation

enum FontRegistrar {
    private static let fontExtensions = ["ttf", "otf"]

    static func registerBundledFonts(in bundle: Bundle = .main) {
        let fontURLs = fontExtensions.flatMap { bundle.urls(forResourcesWithExtension: $0, subdirectory: nil) ?? [] }
        for url in fontURLs {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
