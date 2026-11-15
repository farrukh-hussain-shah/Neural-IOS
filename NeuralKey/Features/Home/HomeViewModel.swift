import Observation

@MainActor
@Observable
final class HomeViewModel {
    var testText = ""
    var isKeyboardEnabled = true
    var isKeyboardSelected = true
    let rewritesLeft = 18
}
