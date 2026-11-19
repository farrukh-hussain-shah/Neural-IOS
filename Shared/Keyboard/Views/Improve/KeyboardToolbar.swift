import SwiftUI

/// The row above the keys when nothing is being typed (Keyboard SVG › Default):
/// Improve, Translate, Voice and Clipboard on the left, Settings on the right.
struct KeyboardToolbar: View {
    let controller: KeyboardController

    var body: some View {
        HStack(spacing: ImproveLayout.toolbarSpacing) {
            Button {
                controller.openImprove()
            } label: {
                HStack(spacing: ImproveLayout.improveIconToText) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: ImproveLayout.toolbarIconSize, weight: .semibold))
                    Text("Improve")
                        .font(.system(size: ImproveLayout.improveFontSize, weight: .semibold))
                        .singleLineLabel()
                }
                .foregroundStyle(AppColor.keyboardAccentText)
                .padding(.horizontal, ImproveLayout.improvePadding)
                .frame(minWidth: ImproveLayout.improveWidth, minHeight: ImproveLayout.circle, maxHeight: ImproveLayout.circle)
                .background(Capsule().fill(AppColor.keyboardAccent))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("keyboard.toolbar.improve")

            ToolbarCircleButton(symbol: "translate", isAccent: true, label: "Translate", identifier: "keyboard.toolbar.translate") {}
            ToolbarCircleButton(symbol: "mic", isAccent: true, label: "Voice", identifier: "keyboard.toolbar.mic") {}
            ToolbarCircleButton(symbol: "doc.on.clipboard", isAccent: false, label: "Clipboard", identifier: "keyboard.toolbar.clipboard") {}

            Spacer(minLength: 0)

            ToolbarCircleButton(symbol: "gearshape", isAccent: false, label: "Settings", identifier: "keyboard.toolbar.settings") {}
        }
        .padding(.horizontal, ImproveLayout.edgeInset)
        .frame(maxHeight: .infinity)
    }
}

/// A 36 pt round button: blue for the AI features, glass for the others.
struct ToolbarCircleButton: View {
    let symbol: String
    let isAccent: Bool
    let label: LocalizedStringKey
    let identifier: String
    let action: @MainActor () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: ImproveLayout.toolbarIconSize, weight: .medium))
                .foregroundStyle(isAccent ? AppColor.keyboardAccentText : AppColor.keyboardGlassIcon)
                .frame(width: ImproveLayout.circle, height: ImproveLayout.circle)
                .background(Circle().fill(isAccent ? AppColor.keyboardAccent : AppColor.keyboardGlass))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
        .accessibilityIdentifier(identifier)
    }
}

/// Sizes from Neural Key IOS Keyboard SVG (402 pt wide), scaled to the screen.
enum ImproveLayout {
    static let edgeInset: CGFloat = 8.keyboardScaled
    static let toolbarSpacing: CGFloat = 8.keyboardScaled
    static let circle: CGFloat = 36.keyboardScaled
    static let toolbarIconSize: CGFloat = 16.keyboardScaled
    static let improveWidth: CGFloat = 102.keyboardScaled
    static let improvePadding: CGFloat = 13.keyboardScaled
    static let improveIconToText: CGFloat = 6.keyboardScaled
    static let improveFontSize: CGFloat = 15.keyboardScaled

    static let panelTop: CGFloat = 10.keyboardScaled
    static let headerTitleSize: CGFloat = 19.keyboardScaled
    static let headerToChips: CGFloat = 12.keyboardScaled
    static let languageHeight: CGFloat = 34.keyboardScaled
    static let languageFontSize: CGFloat = 15.keyboardScaled

    static let chipHeight: CGFloat = 34.keyboardScaled
    static let chipSpacing: CGFloat = 8.keyboardScaled
    static let chipPadding: CGFloat = 14.keyboardScaled
    static let chipIconSize: CGFloat = 12.keyboardScaled
    static let chipFontSize: CGFloat = 13.5.keyboardScaled

    static let chipsToCards: CGFloat = 10.keyboardScaled
    static let cardSpacing: CGFloat = 6.keyboardScaled
    static let cardMinHeight: CGFloat = 54.keyboardScaled
    static let cardCornerRadius: CGFloat = 16.keyboardScaled
    static let cardPadding: CGFloat = 12.keyboardScaled
    static let cardLabelSize: CGFloat = 11.keyboardScaled
    static let cardTextSize: CGFloat = 15.5.keyboardScaled
    static let copyIconSize: CGFloat = 14.keyboardScaled

    static let listRowHeight: CGFloat = 43.6.keyboardScaled
    static let listInset: CGFloat = 12.keyboardScaled
    static let listCornerRadius: CGFloat = 22.keyboardScaled
    static let listFontSize: CGFloat = 16.5.keyboardScaled
}
