import SwiftUI

struct PremiumFooterLinks: View {
    let restoreTitle: LocalizedStringKey
    let termsTitle: LocalizedStringKey
    let privacyTitle: LocalizedStringKey
    var onRestore: @MainActor () -> Void = {}
    var onTerms: @MainActor () -> Void = {}
    var onPrivacy: @MainActor () -> Void = {}

    var body: some View {
        HStack(spacing: 0) {
            link(restoreTitle, action: onRestore)
            separator
                .padding(.leading, Layout.firstSeparatorLeading)
                .padding(.trailing, Layout.firstSeparatorTrailing)
            link(termsTitle, action: onTerms)
            separator
                .padding(.leading, Layout.secondSeparatorLeading)
                .padding(.trailing, Layout.secondSeparatorTrailing)
            link(privacyTitle, action: onPrivacy)
        }
    }

    private func link(_ title: LocalizedStringKey, action: @escaping @MainActor () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .underline()
                .textStyle(.premiumLink)
                .foregroundStyle(AppColor.premiumTextSecondary)
        }
        .buttonStyle(.pressable)
    }

    private var separator: some View {
        Rectangle()
            .fill(AppColor.premiumLinkSeparator)
            .frame(width: Layout.separatorSize.width, height: Layout.separatorSize.height)
            .offset(y: Layout.separatorNudge)
            .accessibilityHidden(true)
    }

    private enum Layout {
        static let separatorSize = CGSize(width: 1.compactScaled, height: 7.compactScaled)
        static let separatorNudge: CGFloat = 1.1.compactScaled
        static let firstSeparatorLeading: CGFloat = 6.compactScaled
        static let firstSeparatorTrailing: CGFloat = 1.4.compactScaled
        static let secondSeparatorLeading: CGFloat = 5.4.compactScaled
        static let secondSeparatorTrailing: CGFloat = 3.compactScaled
    }
}
