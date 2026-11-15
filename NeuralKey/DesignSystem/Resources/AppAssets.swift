import SwiftUI

enum AppIcon: String {
    case fixGrammar = "IconFixGrammar"
    case changeTone = "IconChangeTone"
    case translate = "IconTranslate"
    case arrowRight = "IconArrowRight"
    case externalLink = "IconExternalLink"
    case check = "IconCheck"
    case lock = "IconLock"
    case crown = "IconCrown"
    case menu = "IconMenu"
    case toggle = "IconToggle"
    case keyboard = "IconKeyboard"
    case globe = "IconGlobe"
    case chevronRight = "IconChevronRight"
    case bolt = "IconBolt"
}

enum AppImage: String {
    case logo = "AppLogo"
}

extension Image {
    init(_ icon: AppIcon) {
        self.init(icon.rawValue)
    }

    init(_ image: AppImage) {
        self.init(image.rawValue)
    }
}
