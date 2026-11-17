import SwiftUI

struct SettingsView: View {
    let store: SettingsStore
    let language: AppLanguage
    let onUpgrade: @MainActor () -> Void
    let onToneAdjustment: @MainActor () -> Void
    let onLanguage: @MainActor () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings")
                    .textStyle(.settingsTitle)
                    .foregroundStyle(AppColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier(AccessibilityID.settingsTitle)
                    .padding(.top, Layout.titleTop)

                SettingsUpgradeCard(action: onUpgrade)
                    .padding(.top, Layout.titleToUpgrade)

                sectionLabel("General")
                    .padding(.top, Layout.groupToLabel)

                SettingsGroup {
                    SettingsNavigationRow(
                        icon: .asset(.sliders),
                        title: "AI Tone Adjustment",
                        value: store.primaryTone?.title,
                        action: onToneAdjustment
                    )
                    .accessibilityIdentifier(AccessibilityID.settingsToneAdjustment)
                    SettingsDivider()
                    SettingsToggleRow(icon: .asset(.phone), title: "Haptic Feedback", isOn: hapticBinding)
                        .accessibilityIdentifier(AccessibilityID.settingsHaptics)
                    SettingsDivider()
                    SettingsNavigationRow(
                        icon: .asset(.globe),
                        title: "Change Language",
                        value: language.name,
                        action: onLanguage
                    )
                    .accessibilityIdentifier(AccessibilityID.settingsLanguage)
                }
                .padding(.top, Layout.labelToGroup)

                sectionLabel("Support & Legal")
                    .padding(.top, Layout.groupToLabel)

                SettingsGroup {
                    SettingsNavigationRow(icon: .asset(.star), title: "Rate Us", height: SettingsRowLayout.compactHeight)
                    SettingsDivider()
                    SettingsNavigationRow(icon: .asset(.share), title: "Share App", height: SettingsRowLayout.compactHeight)
                    SettingsDivider()
                    SettingsNavigationRow(icon: .asset(.shield), title: "Privacy Policy", height: SettingsRowLayout.compactHeight)
                    SettingsDivider()
                    SettingsNavigationRow(
                        icon: .symbol("headphones"),
                        title: "Help & Support",
                        height: SettingsRowLayout.compactHeight
                    )
                }
                .padding(.top, Layout.labelToGroup)

                sectionLabel("Keyboard Appearance")
                    .padding(.top, Layout.groupToLabel)

                KeyboardAppearancePicker(selection: store.keyboardAppearance) { appearance in
                    store.setKeyboardAppearance(appearance)
                }
                .padding(.horizontal, Layout.labelInset)
                .padding(.top, Layout.labelToTiles)
            }
            .padding(.horizontal, Layout.horizontalMargin)
            .padding(.bottom, Layout.bottomPadding)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .background(AppColor.homeBackground.ignoresSafeArea())
    }

    private var hapticBinding: Binding<Bool> {
        Binding(
            get: { store.isHapticFeedbackEnabled },
            set: { store.setHapticFeedback($0) }
        )
    }

    private func sectionLabel(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .textStyle(.settingsSection)
            .foregroundStyle(AppColor.settingsSectionLabel)
            .padding(.leading, Layout.labelInset)
            .accessibilityAddTraits(.isHeader)
    }

    private enum Layout {
        static let horizontalMargin: CGFloat = 11.5.narrowScaled
        static let titleTop: CGFloat = 3.narrowScaled
        static let titleToUpgrade: CGFloat = 15.2.narrowScaled
        static let groupToLabel: CGFloat = 19.4.narrowScaled
        static let labelToGroup: CGFloat = 12.1.narrowScaled
        static let labelToTiles: CGFloat = 13.6.narrowScaled
        static let labelInset: CGFloat = 8.narrowScaled
        static let bottomPadding: CGFloat = 32.narrowScaled
    }
}
