import SwiftUI

struct SettingsGroup<Content: View>: View {
    @ViewBuilder let content: Content

    private var groupShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: SettingsRowLayout.groupCornerRadius)
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(groupShape.fill(AppColor.settingsSurface))
        .clipShape(groupShape)
        .overlay(groupShape.strokeBorder(AppColor.settingsBorder, lineWidth: 1))
    }
}

struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColor.settingsBorder)
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

enum SettingsRowIcon {
    case asset(AppIcon)
    case symbol(String)
}

struct SettingsNavigationRow: View {
    let icon: SettingsRowIcon
    let title: LocalizedStringKey
    var value: LocalizedStringKey?
    var height: CGFloat = SettingsRowLayout.height
    var action: @MainActor () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                SettingsRowLabel(icon: icon, title: title)
                Spacer(minLength: SettingsRowLayout.minimumGap)
                if let value {
                    Text(value)
                        .textStyle(.settingsRowValue)
                        .foregroundStyle(AppColor.settingsValue)
                        .lineLimit(1)
                        .padding(.trailing, SettingsRowLayout.valueToChevron)
                }
                Image(.chevronRight)
                    .resizable()
                    .frame(width: SettingsRowLayout.chevronSize, height: SettingsRowLayout.chevronSize)
                    .foregroundStyle(AppColor.settingsValue)
            }
            .settingsRowLayout(height: height)
            .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
    }
}

struct SettingsToggleRow: View {
    let icon: SettingsRowIcon
    let title: LocalizedStringKey
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            SettingsRowLabel(icon: icon, title: title)
        }
        .toggleStyle(.appSwitch(.compact))
        .settingsRowLayout(height: SettingsRowLayout.height)
    }
}

private struct SettingsRowLabel: View {
    let icon: SettingsRowIcon
    let title: LocalizedStringKey

    var body: some View {
        HStack(spacing: SettingsRowLayout.iconToTitle) {
            iconView
                .foregroundStyle(AppColor.royal)
                .frame(width: SettingsRowLayout.iconSize, height: SettingsRowLayout.iconSize)
                .accessibilityHidden(true)
            Text(title)
                .textStyle(.settingsRowTitle)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .asset(let asset):
            Image(asset)
                .resizable()
                .scaledToFit()
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: SettingsRowLayout.symbolSize))
        }
    }
}

enum SettingsRowLayout {
    static let height: CGFloat = 52.narrowScaled
    static let compactHeight: CGFloat = 51.narrowScaled
    static let groupCornerRadius: CGFloat = 16.narrowScaled
    static let leadingPadding: CGFloat = 12.5.narrowScaled
    static let trailingPadding: CGFloat = 13.narrowScaled
    static let iconSize: CGFloat = 20.narrowScaled
    static let symbolSize: CGFloat = 14.narrowScaled
    static let iconToTitle: CGFloat = 10.narrowScaled
    static let minimumGap: CGFloat = 8.narrowScaled
    static let valueToChevron: CGFloat = 5.narrowScaled
    static let chevronSize: CGFloat = 14.narrowScaled
}

private extension View {
    func settingsRowLayout(height: CGFloat) -> some View {
        padding(.leading, SettingsRowLayout.leadingPadding)
            .padding(.trailing, SettingsRowLayout.trailingPadding)
            .frame(height: height)
    }
}
