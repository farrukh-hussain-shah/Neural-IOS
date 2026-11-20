import SwiftUI
import Firebase

@main
struct NeuralKeyApp: App {
    
    init() {
        FirebaseApp.configure()
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
