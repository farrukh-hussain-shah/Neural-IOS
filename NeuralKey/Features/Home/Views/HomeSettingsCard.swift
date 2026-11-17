import SwiftUI
import UIKit

struct HomeSettingsCard: View {
    let viewModel: HomeViewModel

    @Environment(\.openURL) private var openURL

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: RowLayout.cardCornerRadius)
    }

    var body: some View {
        VStack(spacing: 0) {
            HomeToggleRow(
                icon: .toggle,
                title: "Enable Keyboard",
                subtitle: viewModel.isKeyboardEnabled ? "Keyboard Enabled ✓" : "Keyboard Disabled",
                isOn: settingsBinding(viewModel.isKeyboardEnabled)
            )
            .accessibilityIdentifier(AccessibilityID.homeEnableKeyboard)
            HomeRowDivider()
            HomeToggleRow(
                icon: .shield,
                title: "Allow Full Access",
                subtitle: viewModel.hasFullAccess ? "Full Access Allowed ✓" : "Full Access Not Allowed",
                isOn: settingsBinding(viewModel.hasFullAccess)
            )
            .accessibilityIdentifier(AccessibilityID.homeAllowFullAccess)
            HomeRowDivider()
            HomeNavigationRow(
                icon: .globe,
                title: "Switch Keyboard",
                subtitle: "Switch Current Input Method"
            )
            HomeRowDivider()
            RewritesFooter(count: viewModel.rewritesLeft)
        }
        .background(AppColor.groupedSurface)
        .clipShape(cardShape)
        .overlay(cardShape.strokeBorder(AppColor.groupedBorder, lineWidth: RowLayout.borderWidth))
    }

    /// Both switches show what is set in the Settings app, where only the user can change them,
    /// so flipping one opens NeuralKey's Settings page (Keyboards → NeuralKey, Allow Full Access).
    private func settingsBinding(_ value: Bool) -> Binding<Bool> {
        Binding(
            get: { value },
            set: { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                openURL(url)
            }
        )
    }
}

private struct HomeRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColor.groupedDivider)
            .frame(height: RowLayout.dividerThickness)
            .accessibilityHidden(true)
    }
}

private struct HomeRowLabel: View {
    let icon: AppIcon
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        HStack(spacing: RowLayout.iconToText) {
            IconTile(icon: icon, style: .setting)
            VStack(alignment: .leading, spacing: RowLayout.titleToSubtitle) {
                Text(title)
                    .textStyle(.rowTitle)
                    .foregroundStyle(AppColor.textPrimary)
                Text(subtitle)
                    .textStyle(.rowSubtitle)
                    .foregroundStyle(AppColor.textSubdued)
                    .contentTransition(.opacity)
            }
        }
    }
}

private struct HomeToggleRow: View {
    let icon: AppIcon
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HomeRowLabel(icon: icon, title: title, subtitle: subtitle)
        }
        .toggleStyle(.appSwitch(.compact))
        .homeRowLayout(height: AppSize.settingRowHeight)
    }
}

private struct HomeNavigationRow: View {
    let icon: AppIcon
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    var action: @MainActor () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: RowLayout.iconToText) {
                HomeRowLabel(icon: icon, title: title, subtitle: subtitle)
                Spacer(minLength: 0)
                Image(.chevronRight)
                    .resizable()
                    .frame(width: RowLayout.chevronSize, height: RowLayout.chevronSize)
                    .foregroundStyle(AppColor.chevron)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
        .homeRowLayout(height: AppSize.settingRowHeight)
    }
}

private struct RewritesFooter: View {
    let count: Int
    var onGetMore: @MainActor () -> Void = {}

    var body: some View {
        HStack(spacing: RowLayout.iconToText) {
            IconTile(icon: .bolt, style: .setting)

            (Text("Rewrites left: ") + Text(count, format: .number).foregroundStyle(AppColor.royal))
                .textStyle(.rowTitle)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: RowLayout.iconToText)

            Button(action: onGetMore) {
                HStack(spacing: RowLayout.chipTextToBadge) {
                    Text("Get More")
                        .textStyle(.chip)
                        .singleLineLabel()
                    AdMark()
                }
                .foregroundStyle(AppColor.textPrimary)
                .padding(.leading, RowLayout.chipLeadingPadding)
                .padding(.trailing, RowLayout.chipTrailingPadding)
                .frame(height: AppSize.chipHeight)
                .background(Capsule().fill(AppColor.royal))
            }
            .buttonStyle(.pressable)
        }
        .homeRowLayout(height: AppSize.rewritesFooterHeight)
        .background(AppColor.groupedFooter)
    }
}

private struct AdMark: View {
    var body: some View {
        Text("AD")
            .textStyle(.chipBadge)
            .frame(width: RowLayout.adMarkSize.width, height: RowLayout.adMarkSize.height)
            .overlay(
                RoundedRectangle(cornerRadius: RowLayout.adMarkCornerRadius)
                    .strokeBorder(AppColor.textPrimary, lineWidth: RowLayout.adMarkBorder)
            )
            .accessibilityLabel(Text("Ad"))
    }
}

private enum RowLayout {
    static let cardCornerRadius: CGFloat = 12.narrowScaled
    static let borderWidth: CGFloat = 1
    static let dividerThickness: CGFloat = 1
    static let leadingPadding: CGFloat = 12.narrowScaled
    static let trailingPadding: CGFloat = 12.narrowScaled
    static let iconToText: CGFloat = 10.narrowScaled
    static let titleToSubtitle: CGFloat = 0.6.narrowScaled
    static let chevronSize: CGFloat = 15.narrowScaled
    static let chipLeadingPadding: CGFloat = 8.5.narrowScaled
    static let chipTrailingPadding: CGFloat = 8.narrowScaled
    static let chipTextToBadge: CGFloat = 4.narrowScaled
    static let adMarkSize = CGSize(width: 11.5.narrowScaled, height: 9.5.narrowScaled)
    static let adMarkCornerRadius: CGFloat = 2.narrowScaled
    static let adMarkBorder: CGFloat = 0.8.narrowScaled
}

private extension View {
    func homeRowLayout(height: CGFloat) -> some View {
        padding(.leading, RowLayout.leadingPadding)
            .padding(.trailing, RowLayout.trailingPadding)
            .frame(height: height)
    }
}
