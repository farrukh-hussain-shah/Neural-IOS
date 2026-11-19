import SwiftUI

/// The Improve panel, shown in place of the keys (Keyboard SVG › Default-4 to Default-11):
/// a header with Back, the tone's name and the output language; a row of tone chips; and
/// three rewritten options, or shimmering placeholders while the AI works.
struct ImprovePanel: View {
    let controller: KeyboardController

    private var session: ImproveSession {
        controller.improve
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, ImproveLayout.panelTop)
            ToneChipsRow(tones: session.tones, selected: session.tone) { tone in
                controller.selectTone(tone)
            }
            .padding(.top, ImproveLayout.headerToChips)
            ScrollView(.vertical) {
                content
                    .padding(.horizontal, ImproveLayout.edgeInset)
                    .padding(.top, ImproveLayout.chipsToCards)
                    .padding(.bottom, ImproveLayout.cardSpacing)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .accessibilityIdentifier("keyboard.improve")
    }

    private var header: some View {
        HStack(spacing: ImproveLayout.toolbarSpacing) {
            ToolbarCircleButton(symbol: "chevron.left", isAccent: false, label: "Back", identifier: "keyboard.improve.back") {
                controller.closePanel()
            }
            Text(session.tone.title)
                .font(.system(size: ImproveLayout.headerTitleSize, weight: .semibold))
                .foregroundStyle(AppColor.keyboardGlassText)
                .singleLineLabel(minimumScale: 0.7)
                .accessibilityIdentifier("keyboard.improve.title")
            Spacer(minLength: ImproveLayout.toolbarSpacing)
            Button {
                controller.showImproveLanguages()
            } label: {
                HStack(spacing: 6.keyboardScaled) {
                    Image(systemName: "translate")
                        .font(.system(size: ImproveLayout.chipFontSize, weight: .medium))
                        .foregroundStyle(AppColor.keyboardAccent)
                    Text(verbatim: session.language.shortName)
                        .font(.system(size: ImproveLayout.languageFontSize, weight: .medium))
                        .foregroundStyle(AppColor.keyboardGlassText)
                        .singleLineLabel()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10.keyboardScaled, weight: .semibold))
                        .foregroundStyle(AppColor.keyboardGlassIcon)
                }
                .padding(.horizontal, ImproveLayout.chipPadding)
                .frame(height: ImproveLayout.languageHeight)
                .background(Capsule().fill(AppColor.keyboardGlass))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("keyboard.improve.language")
        }
        .padding(.horizontal, ImproveLayout.edgeInset - 2.keyboardScaled)
    }

    @ViewBuilder
    private var content: some View {
        switch session.phase {
        case .loading:
            VStack(spacing: ImproveLayout.cardSpacing) {
                ForEach(0..<AIConfiguration.Rewrite.optionCount, id: \.self) { _ in
                    ShimmerCard()
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Improving your text"))
            .accessibilityIdentifier("keyboard.improve.loading")
        case .loaded(let options):
            VStack(spacing: ImproveLayout.cardSpacing) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    RewriteOptionCard(number: index + 1, text: option) {
                        controller.applyRewrite(option)
                    } onCopy: {
                        controller.copyRewrite(option)
                    }
                }
            }
        case .failed(let message):
            ImproveMessageCard(message: message) {
                controller.improve.retry()
            }
        }
    }
}

/// The horizontally scrolling tone chips; the selected one is blue with a check mark.
private struct ToneChipsRow: View {
    let tones: [RewriteTone]
    let selected: RewriteTone
    let onSelect: (RewriteTone) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: ImproveLayout.chipSpacing) {
                    ForEach(tones) { tone in
                        chip(tone)
                            .id(tone.id)
                    }
                }
                .padding(.horizontal, ImproveLayout.edgeInset)
            }
            .scrollIndicators(.hidden)
            .frame(height: ImproveLayout.chipHeight)
            .mask(
                LinearGradient(
                    stops: [.init(color: .black, location: 0.92), .init(color: .clear, location: 1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .onChange(of: selected) { _, tone in
                withAnimation { proxy.scrollTo(tone.id, anchor: .center) }
            }
        }
    }

    private func chip(_ tone: RewriteTone) -> some View {
        let isSelected = tone == selected
        return Button {
            onSelect(tone)
        } label: {
            HStack(spacing: 6.keyboardScaled) {
                toneIcon(tone)
                Text(tone.title)
                    .font(.system(size: ImproveLayout.chipFontSize, weight: .medium))
                    .lineLimit(1)
                    .fixedSize()
                if isSelected {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: ImproveLayout.chipFontSize, weight: .medium))
                }
            }
            .foregroundStyle(isSelected ? AppColor.keyboardAccentText : AppColor.keyboardGlassText)
            .padding(.horizontal, ImproveLayout.chipPadding)
            .frame(height: ImproveLayout.chipHeight)
            .background(
                Capsule()
                    .fill(isSelected ? AppColor.keyboardAccent : AppColor.keyboardGlass)
                    .overlay(Capsule().strokeBorder(AppColor.keyboardAccentBorder, lineWidth: 1).opacity(isSelected ? 1 : 0))
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("keyboard.improve.tone.\(tone.id)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func toneIcon(_ tone: RewriteTone) -> some View {
        switch tone.icon {
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: ImproveLayout.chipIconSize, weight: .medium))
        case .asset(let name):
            Image(name)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: ImproveLayout.chipIconSize + 2, height: ImproveLayout.chipIconSize + 2)
        }
    }
}

/// One rewritten option: tap to put it in the text field, or copy it.
private struct RewriteOptionCard: View {
    let number: Int
    let text: String
    let onApply: () -> Void
    let onCopy: () -> Void

    @State private var didCopy = false

    var body: some View {
        HStack(alignment: .center, spacing: ImproveLayout.cardPadding) {
            Button(action: onApply) {
                VStack(alignment: .leading, spacing: 2.keyboardScaled) {
                    Text("Option \(number)")
                        .font(.system(size: ImproveLayout.cardLabelSize))
                        .foregroundStyle(AppColor.keyboardGlassSecondaryText)
                    Text(verbatim: text)
                        .font(.system(size: ImproveLayout.cardTextSize))
                        .foregroundStyle(AppColor.keyboardGlassText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("keyboard.improve.option.\(number)")

            Button {
                onCopy()
                didCopy = true
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    didCopy = false
                }
            } label: {
                Image(systemName: didCopy ? "checkmark" : "square.on.square")
                    .font(.system(size: ImproveLayout.copyIconSize, weight: .medium))
                    .foregroundStyle(didCopy ? AppColor.keyboardAccent : AppColor.keyboardGlassIcon)
                    .frame(width: 28.keyboardScaled, height: 28.keyboardScaled)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Copy"))
            .accessibilityIdentifier("keyboard.improve.copy.\(number)")
        }
        .padding(.leading, ImproveLayout.cardPadding)
        .padding(.trailing, ImproveLayout.cardPadding - 4.keyboardScaled)
        .padding(.vertical, 8.keyboardScaled)
        .frame(minHeight: ImproveLayout.cardMinHeight)
        .background(RoundedRectangle(cornerRadius: ImproveLayout.cardCornerRadius, style: .continuous).fill(AppColor.keyboardGlass))
    }
}

/// A placeholder card with a light sweeping across it while the AI works.
private struct ShimmerCard: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: ImproveLayout.cardCornerRadius, style: .continuous)
        shape
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: AppColor.keyboardShimmer, location: 0),
                        .init(color: AppColor.keyboardShimmer.opacity(0.42), location: 0.48),
                        .init(color: AppColor.keyboardShimmer.opacity(0.42), location: 0.87)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                GeometryReader { proxy in
                    LinearGradient(
                        colors: [.clear, AppColor.keyboardShimmer, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: proxy.size.width * 0.45)
                    .offset(x: phase * proxy.size.width)
                }
                .clipShape(shape)
            }
            .overlay(shape.strokeBorder(AppColor.keyboardShimmer, lineWidth: 0.5))
            .frame(height: ImproveLayout.cardMinHeight)
            .onAppear {
                withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
    }
}

/// Shown instead of the options when they can't be loaded, with a way to try again.
private struct ImproveMessageCard: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10.keyboardScaled) {
            Text(verbatim: message)
                .font(.system(size: ImproveLayout.cardTextSize - 1))
                .foregroundStyle(AppColor.keyboardGlassText)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("keyboard.improve.message")
            Button(action: onRetry) {
                Text("Try Again")
                    .font(.system(size: ImproveLayout.chipFontSize, weight: .semibold))
                    .foregroundStyle(AppColor.keyboardAccentText)
                    .padding(.horizontal, ImproveLayout.chipPadding)
                    .frame(height: ImproveLayout.chipHeight - 4.keyboardScaled)
                    .background(Capsule().fill(AppColor.keyboardAccent))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("keyboard.improve.retry")
        }
        .padding(ImproveLayout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: ImproveLayout.cardCornerRadius, style: .continuous).fill(AppColor.keyboardGlass))
    }
}
