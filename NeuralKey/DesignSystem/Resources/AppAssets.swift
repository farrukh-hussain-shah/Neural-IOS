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
    case close = "IconClose"
    case adBadge = "IconAdBadge"
}

enum AppImage: String {
    case logo = "AppLogo"
    case premiumNetwork = "PremiumNetwork"
    case premiumSparkles = "PremiumSparkles"
    case premiumFeatureBullet = "PremiumFeatureBullet"
    case ditherNoise = "DitherNoise"
    case flagEnglish = "FlagEnglish"
    case flagSpanish = "FlagSpanish"
    case flagPortuguese = "FlagPortuguese"
    case flagRussian = "FlagRussian"
    case flagArabic = "FlagArabic"
    case flagChinese = "FlagChinese"
    case flagHindi = "FlagHindi"
    case adSampleLogo = "AdSampleLogo"
}

extension Image {
    init(_ icon: AppIcon) {
        self.init(icon.rawValue)
    }

    init(_ image: AppImage) {
        self.init(image.rawValue)
    }
}
