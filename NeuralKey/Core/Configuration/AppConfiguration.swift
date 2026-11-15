import Foundation

enum AppConfiguration {
    static let displayName = "NeuralKey"

    enum Splash {
        static let loadingDuration: TimeInterval = 2.0
        static let progressSteps = 50
        static let completionDelay: TimeInterval = 0.3
    }

    enum Transition {
        static let duration: TimeInterval = 0.35
    }
}
