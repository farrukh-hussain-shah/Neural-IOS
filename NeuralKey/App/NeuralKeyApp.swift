import SwiftUI

@main
struct NeuralKeyApp: App {
    init() {
        FontRegistrar.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
