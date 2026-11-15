import SwiftUI

struct HomeSettingsCard: View {
    @Bindable var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HomeToggleRow(
                icon: .toggle,
                title: "Enable Keyboard",
                subtitle: "Allow full access in settings",
                isOn: $viewModel.isKeyboardEnabled
            )
            HomeRowDivider()
            HomeToggleRow(
                icon: .keyboard,
                title: "Allow Full Access",
                subtitle: "Allow full access in settings",
                isOn: $viewModel.isFullAccessAllowed
            )
            HomeRowDivider()
            HomeNavigationRow(
                icon: .globe,
                title: "Select Keyboard",
                subtitle: "Allow full access in settings"
            )
            RewritesFooter(count: viewModel.availableRewrites)
        }
        .background(AppColor.groupedSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.md).strokeBorder(AppColor.groupedBorder, lineWidth: 1))
    }
}

private struct HomeRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColor.groupedDivider)
            .frame(height: RowLayout.dividerThickness)
            .padding(.horizontal, RowLayout.horizontalPadding)
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
            VStack(alignment: .leading, spacing: AppSpacing.s2) {
                Text(title)
                    .textStyle(.rowTitle)
                    .foregroundStyle(AppColor.textPrimary)
                Text(subtitle)
                    .textStyle(.rowSubtitle)
                    .foregroundStyle(AppColor.textSubdued)
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
        .homeRowLayout()
    }
}

private struct HomeNavigationRow: View {
    let icon: AppIcon
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    var action: @MainActor () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.s12) {
                HomeRowLabel(icon: icon, title: title, subtitle: subtitle)
                Spacer(minLength: 0)
                Image(.chevronRight)
                    .resizable()
                    .frame(width: AppSize.Icon.regular, height: AppSize.Icon.regular)
                    .foregroundStyle(AppColor.chevron)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
        .homeRowLayout()
    }
}

private struct RewritesFooter: View {
    let count: Int
    var onGetMore: @MainActor () -> Void = {}

    var body: some View {
        HStack(spacing: AppSpacing.s12) {
            IconTile(icon: .bolt, style: .setting)

            (Text("Available Rewrites: ") + Text(count, format: .number).foregroundStyle(AppColor.royal))
                .textStyle(.rewritesLabel)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: AppSpacing.s8)

            Button(action: onGetMore) {
                Text("GET MORE")
                    .textStyle(.chip)
                    .foregroundStyle(AppColor.textOnAccent)
                    .padding(.horizontal, RowLayout.chipHorizontalPadding)
                    .frame(height: AppSize.chipHeight)
                    .background(Capsule().fill(AppColor.royal))
                    .overlay(Capsule().strokeBorder(AppColor.chipBorder, lineWidth: 1))
            }
            .buttonStyle(.pressable)
        }
        .padding(.horizontal, AppSpacing.s16)
        .frame(height: AppSize.rewritesFooterHeight)
        .background(AppColor.groupedFooter)
    }
}

private enum RowLayout {
    static let horizontalPadding: CGFloat = 15.scaled
    static let iconToText: CGFloat = 12.scaled
    static let chipHorizontalPadding: CGFloat = 17.6.scaled
    static let dividerThickness: CGFloat = 0.5
}

private extension View {
    func homeRowLayout() -> some View {
        padding(.horizontal, RowLayout.horizontalPadding)
            .frame(height: AppSize.settingRowHeight)
    }
}
