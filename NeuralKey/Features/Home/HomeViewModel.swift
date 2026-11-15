import Observation

@MainActor
@Observable
final class HomeViewModel {
    var testText = ""
    var isKeyboardEnabled = true
    var isFullAccessAllowed = false
    let availableRewrites = 38
}
