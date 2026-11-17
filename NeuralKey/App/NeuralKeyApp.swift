import SwiftUI

@main
struct NeuralKeyApp: App {
    init() {
        FontRegistrar.registerBundledFonts()
        AppLocalization.configureLayoutDirection()
        DictionarySync.start()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
