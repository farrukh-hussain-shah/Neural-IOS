import UIKit

enum AppScale {
    enum Reference {
        case standard
        case premium

        var width: CGFloat {
            switch self {
            case .standard: 390
            case .premium: 375
            }
        }
    }

    static let designStatusBarHeight: CGFloat = 47

    static let screenWidth: CGFloat = MainActor.assumeIsolated {
        let bounds = UIScreen.main.bounds
        return min(bounds.width, bounds.height)
    }

    static let factor = scaleFactor(for: .standard)
    static let premiumFactor = scaleFactor(for: .premium)

    static func scaleFactor(for reference: Reference) -> CGFloat {
        screenWidth / reference.width
    }

    static func safeAreaAlignedTop(_ designTop: CGFloat, safeAreaTop: CGFloat, reference: Reference = .standard) -> CGFloat {
        max(designTop * scaleFactor(for: reference) - safeAreaTop, 0)
    }
}

extension BinaryInteger {
    var scaled: CGFloat { CGFloat(self) * AppScale.factor }
    var premiumScaled: CGFloat { CGFloat(self) * AppScale.premiumFactor }
}

extension BinaryFloatingPoint {
    var scaled: CGFloat { CGFloat(self) * AppScale.factor }
    var premiumScaled: CGFloat { CGFloat(self) * AppScale.premiumFactor }
}
