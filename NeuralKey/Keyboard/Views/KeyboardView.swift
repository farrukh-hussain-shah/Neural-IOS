import SwiftUI

struct KeyboardView: View {
    let controller: KeyboardController

    private var isPhonePad: Bool {
        controller.configuration.type == .phonePad
    }

    var body: some View {
        VStack(spacing: 0) {
            topArea
            rows
            bottomArea
        }
        .frame(width: KeyboardLayout.designWidth.keyboardScaled, height: KeyboardMetrics.height(for: controller.configuration))
        .background(panel)
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var topArea: some View {
        if isPhonePad {
            Color.clear.frame(height: KeyboardMetrics.phoneTopInset - KeyboardMetrics.phoneRowSpacing / 2)
        } else if controller.configuration.showsSuggestions {
            SuggestionBar(controller: controller)
                .frame(height: KeyboardMetrics.suggestionBarHeight - KeyboardMetrics.rowSpacing / 2)
        } else {
            Color.clear.frame(height: KeyboardMetrics.compactTopInset - KeyboardMetrics.rowSpacing / 2)
        }
    }

    private var rows: some View {
        let rowHeight = isPhonePad ? KeyboardMetrics.phoneRowHeight : KeyboardMetrics.rowHeight
        let spacing = isPhonePad ? KeyboardMetrics.phoneRowSpacing : KeyboardMetrics.rowSpacing
        let rows = controller.rows
        return VStack(spacing: 0) {
            ForEach(rows) { row in
                KeyboardRowView(row: row, rowHeight: rowHeight, verticalHitInset: spacing / 2, controller: controller)
            }
        }
    }

    @ViewBuilder
    private var bottomArea: some View {
        if isPhonePad {
            Color.clear.frame(height: KeyboardMetrics.phoneBottomHeight - KeyboardMetrics.phoneRowSpacing / 2)
        } else {
            ZStack(alignment: .topLeading) {
                Color.clear
                if controller.configuration.showsSystemRow {
                    systemIcon("face.smiling", label: "emoji", identifier: "keyboard.emoji", centerX: KeyboardMetrics.emojiCenterX, action: .emoji)
                    systemIcon("mic", label: "dictation", identifier: "keyboard.dictation", centerX: KeyboardMetrics.micCenterX, action: .dictation)
                }
            }
            .frame(height: KeyboardMetrics.bottomAreaHeight - KeyboardMetrics.rowSpacing / 2)
        }
    }

    private func systemIcon(
        _ name: String,
        label: String,
        identifier: String,
        centerX: CGFloat,
        action: KeyboardAction
    ) -> some View {
        Button {
            controller.perform(action)
        } label: {
            Image(systemName: name)
                .font(.system(size: KeyboardMetrics.systemIconSize))
                .foregroundStyle(AppColor.keyboardSystemIcon)
                .frame(width: KeyboardMetrics.systemIconSize * 1.8, height: KeyboardMetrics.systemIconSize * 1.8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
        .accessibilityIdentifier(identifier)
        .position(x: centerX, y: KeyboardMetrics.systemIconCenterOffset - KeyboardMetrics.rowSpacing / 2)
    }

    private var panel: some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: KeyboardMetrics.panelTopCornerRadius,
            bottomLeadingRadius: KeyboardMetrics.panelBottomCornerRadius,
            bottomTrailingRadius: KeyboardMetrics.panelBottomCornerRadius,
            topTrailingRadius: KeyboardMetrics.panelTopCornerRadius,
            style: .continuous
        )
        return shape
            .fill(isPhonePad ? AppColor.keyboardPhonePanel : AppColor.keyboardPanel)
            .overlay {
                if !isPhonePad {
                    shape.stroke(AppColor.keyboardPanelBorder, lineWidth: 1)
                }
            }
    }
}

private struct KeyboardRowView: View {
    let row: KeyboardRow
    let rowHeight: CGFloat
    let verticalHitInset: CGFloat
    let controller: KeyboardController

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(row.keys.enumerated()), id: \.element.id) { index, key in
                let isFirst = index == 0
                let isLast = index == row.keys.count - 1
                let previousGap = isFirst ? row.leadingInset : row.keys[index - 1].gapAfter / 2
                let nextGap = isLast ? trailingInset : key.gapAfter / 2
                KeyboardKeyView(
                    key: key,
                    size: CGSize(width: key.width.keyboardScaled, height: rowHeight),
                    edge: isFirst ? .leading : (isLast ? .trailing : .none),
                    expandsAlternatesLeading: keyCenter(at: index) > KeyboardLayout.designWidth / 2,
                    hitInsets: EdgeInsets(
                        top: verticalHitInset,
                        leading: previousGap.keyboardScaled,
                        bottom: verticalHitInset,
                        trailing: nextGap.keyboardScaled
                    ),
                    controller: controller
                )
            }
        }
        .zIndex(1)
    }

    private var trailingInset: CGFloat {
        let used = row.leadingInset + row.keys.reduce(0) { $0 + $1.width + $1.gapAfter }
        return max(KeyboardLayout.designWidth - used, 0)
    }

    private func keyCenter(at index: Int) -> CGFloat {
        let preceding = row.keys.prefix(index).reduce(row.leadingInset) { $0 + $1.width + $1.gapAfter }
        return preceding + row.keys[index].width / 2
    }
}

private struct SuggestionBar: View {
    let controller: KeyboardController

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<SuggestionProvider.slotCount, id: \.self) { index in
                if index > 0 {
                    Rectangle()
                        .fill(AppColor.keyboardDivider)
                        .frame(width: 1, height: KeyboardMetrics.suggestionDividerHeight)
                }
                slot(at: index)
            }
        }
        .padding(.top, KeyboardMetrics.rowSpacing / 2)
    }

    private func slot(at index: Int) -> some View {
        let suggestion = index < controller.suggestions.count ? controller.suggestions[index] : nil
        return Button {
            if let suggestion {
                controller.select(suggestion)
            }
        } label: {
            Text(suggestion?.displayText ?? "")
                .font(.system(size: KeyboardMetrics.suggestionFontSize))
                .foregroundStyle(AppColor.keyboardSuggestion)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(suggestion == nil)
        .accessibilityIdentifier("keyboard.suggestion.\(index)")
    }
}
