import SwiftUI

enum KeyboardMetrics {
    static let suggestionBarHeight: CGFloat = 56.keyboardScaled
    static let compactTopInset: CGFloat = 16.keyboardScaled
    static let bottomAreaHeight: CGFloat = 80.keyboardScaled
    static let systemIconCenterOffset: CGFloat = 39.5.keyboardScaled
    static let rowHeight: CGFloat = KeyboardLayout.rowHeight.keyboardScaled
    static let rowSpacing: CGFloat = KeyboardLayout.rowSpacing.keyboardScaled

    static let phoneTopInset: CGFloat = 18.keyboardScaled
    static let phoneBottomHeight: CGFloat = 74.keyboardScaled
    static let phoneRowHeight: CGFloat = KeyboardLayout.phoneRowHeight.keyboardScaled
    static let phoneRowSpacing: CGFloat = KeyboardLayout.phoneRowSpacing.keyboardScaled

    static let keyCornerRadius: CGFloat = 8.5.keyboardScaled
    static let panelTopCornerRadius: CGFloat = 27.keyboardScaled
    static let panelBottomCornerRadius: CGFloat = 62.keyboardScaled

    static let letterFontSize: CGFloat = 25.keyboardScaled
    static let letterBaselineNudge: CGFloat = -2.4.keyboardScaled
    static let symbolFontSize: CGFloat = 22.keyboardScaled
    static let symbolBaselineNudge: CGFloat = 0.7.keyboardScaled
    static let functionFontSize: CGFloat = 16.keyboardScaled
    static let shiftIconSize: CGFloat = 19.keyboardScaled
    static let deleteIconSize: CGFloat = 17.keyboardScaled
    static let returnIconSize: CGFloat = 18.keyboardScaled
    static let goIconSize: CGFloat = 18.keyboardScaled
    static let systemIconSize: CGFloat = 28.5.keyboardScaled
    static let emojiCenterX: CGFloat = 42.5.keyboardScaled
    static let micCenterX: CGFloat = 360.keyboardScaled

    static let suggestionFontSize: CGFloat = 17.5.keyboardScaled
    static let suggestionDividerHeight: CGFloat = 24.keyboardScaled

    static let phoneDigitFontSize: CGFloat = 24.keyboardScaled
    static let phoneLetterFontSize: CGFloat = 10.keyboardScaled
    static let phoneLetterTracking: CGFloat = 2.keyboardScaled
    static let phoneSymbolFontSize: CGFloat = 21.keyboardScaled
    static let phoneDeleteIconSize: CGFloat = 19.keyboardScaled
    static let phoneToggleIconSize: CGFloat = 16.keyboardScaled
    static let phoneToggleSpacing: CGFloat = 2.keyboardScaled
    static let phoneLabelNudge: CGFloat = -1.5.keyboardScaled

    static let popupExtraHeight: CGFloat = 54.keyboardScaled
    static let popupOverhang: CGFloat = 9.keyboardScaled
    static let popupNeckHeight: CGFloat = 10.keyboardScaled
    static let popupCornerRadius: CGFloat = 10.keyboardScaled
    static let popupFontSize: CGFloat = 40.keyboardScaled
    static let alternateWidth: CGFloat = 34.keyboardScaled
    static let alternateFontSize: CGFloat = 26.keyboardScaled

    static func height(for configuration: KeyboardConfiguration) -> CGFloat {
        switch configuration.type {
        case .phonePad:
            phoneTopInset + 4 * phoneRowHeight + 3 * phoneRowSpacing + phoneBottomHeight
        case .text:
            (configuration.showsSuggestions ? suggestionBarHeight : compactTopInset)
                + 4 * rowHeight + 3 * rowSpacing + bottomAreaHeight
        }
    }
}
