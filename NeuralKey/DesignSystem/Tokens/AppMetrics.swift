import CoreGraphics

enum AppSpacing {
    static let s2: CGFloat = 2.scaled
    static let s4: CGFloat = 4.scaled
    static let s6: CGFloat = 6.scaled
    static let s8: CGFloat = 8.scaled
    static let s10: CGFloat = 10.scaled
    static let s12: CGFloat = 12.scaled
    static let s14: CGFloat = 14.scaled
    static let s16: CGFloat = 16.scaled
    static let s18: CGFloat = 18.scaled
    static let s20: CGFloat = 20.scaled
    static let s24: CGFloat = 24.scaled
    static let s26: CGFloat = 26.scaled
    static let s28: CGFloat = 28.scaled
    static let s32: CGFloat = 32.scaled
    static let s36: CGFloat = 36.scaled
    static let s40: CGFloat = 40.scaled

    static let screenHorizontal: CGFloat = s24
}

enum AppRadius {
    static let xs: CGFloat = 4.scaled
    static let sm: CGFloat = 8.scaled
    static let md: CGFloat = 12.scaled
    static let lg: CGFloat = 14.scaled
    static let xl: CGFloat = 16.scaled
    static let splashLogo: CGFloat = 15.scaled
}

enum AppSize {
    static let primaryButtonHeight: CGFloat = 56.scaled
    static let circleButton: CGFloat = 40.scaled
    static let headerLogo: CGFloat = 32.scaled
    static let splashLogo: CGFloat = 92.scaled
    static let featureTile: CGFloat = 44.scaled
    static let featureCardHeight: CGFloat = 74.scaled
    static let settingTile: CGFloat = 32.scaled
    static let settingRowHeight: CGFloat = 73.scaled
    static let rewritesFooterHeight: CGFloat = 64.scaled
    static let stepMarker: CGFloat = 30.scaled
    static let stepConnectorWidth: CGFloat = 2.scaled
    static let toggleCardHeight: CGFloat = 56.scaled
    static let inputHeight: CGFloat = 55.scaled
    static let chipHeight: CGFloat = 28.scaled
    static let progressBarHeight: CGFloat = 6.scaled
    static let pageIndicatorHeight: CGFloat = 5.scaled
    static let pageIndicatorActiveWidth: CGFloat = 32.scaled
    static let pageIndicatorInactiveWidth: CGFloat = 8.scaled
    static let premiumButtonHeight: CGFloat = 50.premiumScaled

    enum Icon {
        static let small: CGFloat = 16.scaled
        static let medium: CGFloat = 18.scaled
        static let regular: CGFloat = 20.scaled
        static let large: CGFloat = 22.scaled
    }
}
