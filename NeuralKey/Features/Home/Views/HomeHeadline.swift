import SwiftUI

/// The Home headline: a short two-tone phrase (white, then blue) that changes every few seconds.
/// The next phrase slides up into place while the current one slides up and fades out.
struct HomeHeadline: View {
    struct Phrase {
        let primary: LocalizedStringKey
        let accent: LocalizedStringKey
    }

    static let phrases = [
        Phrase(primary: "Neural Key", accent: "AI"),
        Phrase(primary: "Unlock", accent: "AI Superpowers"),
        Phrase(primary: "Type Less", accent: "Do More"),
        Phrase(primary: "Thinking", accent: "Forward"),
        Phrase(primary: "Better", accent: "Replies")
    ]

    /// When false the first phrase stays put (UI tests use this for stable screenshots).
    var rotates = true

    @State private var index = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .leading) {
            // Holds the line's height while phrases slide in and out.
            line(Self.phrases[0])
                .hidden()
            line(Self.phrases[index])
                .id(index)
                .transition(transition)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
        .accessibilityElement(children: .combine)
        .task(id: rotates) {
            guard rotates else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: Timing.interval)
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: Timing.slideDuration)) {
                    index = (index + 1) % Self.phrases.count
                }
            }
        }
    }

    private func line(_ phrase: Phrase) -> some View {
        (Text(phrase.primary) + Text(verbatim: " ") + Text(phrase.accent).foregroundStyle(AppColor.royal))
            .textStyle(.homeTitle)
            .foregroundStyle(AppColor.textPrimary)
            .singleLineLabel(minimumScale: 0.6)
    }

    private var transition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }

    private enum Timing {
        static let interval: Duration = .seconds(3)
        static let slideDuration: TimeInterval = 0.6
    }
}

#Preview {
    HomeHeadline()
        .padding()
        .background(Color.black)
}
