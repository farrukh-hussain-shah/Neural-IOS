import Observation

@MainActor
@Observable
final class HomeViewModel {
    var testText = ""
    let rewritesLeft = 18
    /// Whether NeuralKey is added in Settings and has Full Access; refreshed when the app returns
    /// to the foreground, since both are switched on in the Settings app.
    private(set) var setupState: KeyboardSetupState = KeyboardSetupStatus.current

    var isKeyboardEnabled: Bool {
        setupState != .notAdded
    }

    var hasFullAccess: Bool {
        setupState == .fullAccess
    }

    func refreshSetupStatus() {
        setupState = KeyboardSetupStatus.current
    }
}
