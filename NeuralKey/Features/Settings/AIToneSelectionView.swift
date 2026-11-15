import SwiftUI

struct AIToneSelectionView: View {
    let store: SettingsStore
    let onClose: @MainActor () -> Void

    @State private var draft: Set<AITone>
    @State private var hasAppeared = false

    init(store: SettingsStore, onClose: @escaping @MainActor () -> Void) {
        self.store = store
        self.onClose = onClose
        _draft = State(initialValue: store.selectedTones)
    }

    private var canUpdate: Bool {
        draft != store.selectedTones && draft.count >= AITone.minimumSelection
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                ScrollView {
                    content
                        .padding(.bottom, Layout.updateHeight + Layout.listBottomInset)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)

                updateBar(safeAreaBottom: proxy.safeAreaInsets.bottom)
            }
        }
        .background { TonesBackground() }
        .onAppear { hasAppeared = true }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.top, Layout.backTop)

            VStack(alignment: .leading, spacing: Layout.titleLineSpacing) {
                Text("Select your")
                    .foregroundStyle(AppColor.textPrimary)
                Text("AI Tones")
                    .foregroundStyle(AppColor.primary)
            }
            .textStyle(.tonesTitle)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(AccessibilityID.tonesTitle)
            .padding(.top, Layout.backToTitle)

            Text("Build your cloud. Select at least 5 tones.")
                .textStyle(.tonesSubtitle)
                .foregroundStyle(AppColor.tonesSubtitle)
                .padding(.top, Layout.titleToSubtitle)

            ForEach(Array(AIToneCategory.allCases.enumerated()), id: \.element) { index, category in
                section(category)
                    .padding(.top, index == 0 ? Layout.subtitleToSection : Layout.sectionSpacing)
            }
        }
        .padding(.horizontal, Layout.horizontalMargin)
    }

    private var backButton: some View {
        Button(action: onClose) {
            Image(.arrowLeft)
                .resizable()
                .frame(width: Layout.backIconSize, height: Layout.backIconSize)
                .foregroundStyle(AppColor.backButtonIcon)
                .frame(width: Layout.backSize, height: Layout.backSize)
                .background(Circle().fill(AppColor.backButtonSurface))
                .overlay(Circle().strokeBorder(AppColor.backButtonBorder, lineWidth: 1))
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(Text("Back"))
        .accessibilityIdentifier(AccessibilityID.tonesBack)
    }

    private func section(_ category: AIToneCategory) -> some View {
        VStack(alignment: .leading, spacing: Layout.labelToChips) {
            HStack(spacing: Layout.dotToLabel) {
                Circle()
                    .fill(AppColor.toneAccent)
                    .frame(width: Layout.dotSize, height: Layout.dotSize)
                Text(category.title)
                    .textStyle(.tonesSection)
                    .foregroundStyle(AppColor.toneSectionLabel)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            FlowLayout(horizontalSpacing: Layout.chipSpacing, verticalSpacing: Layout.rowSpacing) {
                ForEach(category.tones) { tone in
                    ToneChip(tone: tone, isSelected: draft.contains(tone)) {
                        withAnimation(AppAnimation.selection) {
                            toggle(tone)
                        }
                    }
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : Layout.appearOffset)
                    .animation(
                        .easeOut(duration: Layout.appearDuration).delay(appearDelay(for: tone)),
                        value: hasAppeared
                    )
                }
            }
        }
    }

    private func updateBar(safeAreaBottom: CGFloat) -> some View {
        Button {
            store.setSelectedTones(draft)
            onClose()
        } label: {
            Text("Update")
                .textStyle(.tonesAction)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: Layout.updateHeight)
                .background(RoundedRectangle(cornerRadius: Layout.updateCornerRadius).fill(AppColor.royal))
        }
        .buttonStyle(.pressable)
        .disabled(!canUpdate)
        .opacity(canUpdate ? 1 : Layout.disabledOpacity)
        .animation(AppAnimation.selection, value: canUpdate)
        .accessibilityIdentifier(AccessibilityID.tonesUpdate)
        .padding(.horizontal, Layout.updateHorizontal)
        .padding(.bottom, Layout.updateBottom - safeAreaBottom)
        .background(alignment: .top) {
            AppColor.tonesBackground
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func toggle(_ tone: AITone) {
        if draft.contains(tone) {
            draft.remove(tone)
        } else {
            draft.insert(tone)
        }
    }

    private func appearDelay(for tone: AITone) -> Double {
        Double(AITone.allCases.firstIndex(of: tone) ?? 0) * Layout.appearStagger
    }

    private enum Layout {
        static let horizontalMargin: CGFloat = 6.5.narrowScaled
        static let backTop: CGFloat = 2.5.narrowScaled
        static let backSize: CGFloat = 33.5.narrowScaled
        static let backIconSize: CGFloat = 21.narrowScaled
        static let backToTitle: CGFloat = 15.5.narrowScaled
        static let titleLineSpacing: CGFloat = 0.7.narrowScaled
        static let titleToSubtitle: CGFloat = 7.6.narrowScaled
        static let subtitleToSection: CGFloat = 20.3.narrowScaled
        static let sectionSpacing: CGFloat = 13.2.narrowScaled
        static let labelToChips: CGFloat = 6.6.narrowScaled
        static let dotSize: CGFloat = 3.narrowScaled
        static let dotToLabel: CGFloat = 6.narrowScaled
        static let chipSpacing: CGFloat = 6.5.narrowScaled
        static let rowSpacing: CGFloat = 5.5.narrowScaled
        static let updateHeight: CGFloat = 42.5.narrowScaled
        static let updateCornerRadius: CGFloat = 12.narrowScaled
        static let updateHorizontal: CGFloat = 7.narrowScaled
        static let updateBottom: CGFloat = 17.5.narrowScaled
        static let listBottomInset: CGFloat = 32.narrowScaled
        static let disabledOpacity: Double = 0.45
        static let appearOffset: CGFloat = 6.narrowScaled
        static let appearDuration: Double = 0.3
        static let appearStagger: Double = 0.015
    }
}

private struct TonesBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .topLeading) {
                AppColor.tonesBackground
                glow(AppColor.toneGlowBlue.opacity(0.12), diameter: 500, center: CGPoint(x: 179, y: 52), blur: 60, width: width)
                glow(AppColor.toneGlowViolet.opacity(0.03), diameter: 200, center: CGPoint(x: 178, y: 627), blur: 45, width: width)
                glow(
                    AppColor.toneGlowRoyal.opacity(0.05),
                    diameter: 400,
                    center: CGPoint(x: 122, y: proxy.size.height / (width / 390) - 68),
                    blur: 50,
                    width: width
                )
            }
            .dithered()
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func glow(_ color: Color, diameter: CGFloat, center: CGPoint, blur: CGFloat, width: CGFloat) -> some View {
        let scale = width / 390
        return Circle()
            .fill(color)
            .frame(width: diameter * scale, height: diameter * scale)
            .blur(radius: blur * scale)
            .position(x: center.x * scale, y: center.y * scale)
    }
}
