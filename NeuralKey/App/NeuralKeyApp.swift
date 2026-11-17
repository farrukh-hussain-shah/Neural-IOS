import SwiftUI

@main
struct NeuralKeyApp: App {
    init() {
        FontRegistrar.registerBundledFonts()
        DictionarySync.start()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
