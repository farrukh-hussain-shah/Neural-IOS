import SwiftUI

struct SplashView: View {
    let onFinish: @MainActor () -> Void

    @State private var progress: Double = 0

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                brand
                    .padding(.top, proxy.size.height * Layout.logoTopRatio)
                Spacer(minLength: AppSpacing.s24)
                SplashProgressView(progress: progress)
                    .padding(.horizontal, AppSpacing.s32)
                    .padding(.bottom, AppSpacing.s32)
            }
            .frame(maxWidth: .infinity)
        }
        .background { SplashBackground() }
        .ignoresSafeArea()
        .task {
            #if DEBUG
            if let frozenProgress = LaunchOverrides.frozenSplashProgress {
                progress = frozenProgress
                return
            }
            #endif
            await runLoading()
        }
    }

    private var brand: some View {
        VStack(spacing: 0) {
            AppLogo(size: AppSize.splashLogo, cornerRadius: AppRadius.splashLogo)
            Text(verbatim: AppConfiguration.displayName)
                .textStyle(.splashTitle)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.top, AppSpacing.s24)
            Text("MAKE EVERY REPLY BETTER")
                .textStyle(.splashTagline)
                .foregroundStyle(AppColor.tagline)
                .padding(.top, AppSpacing.s6)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityID.splashBrand)
    }

    private func runLoading() async {
        let steps = AppConfiguration.Splash.progressSteps
        let interval = AppConfiguration.Splash.loadingDuration / Double(steps)
        for step in 1...steps {
            try? await Task.sleep(for: .seconds(interval))
            guard !Task.isCancelled else { return }
            withAnimation(.linear(duration: interval)) {
                progress = Double(step) / Double(steps)
            }
        }
        try? await Task.sleep(for: .seconds(AppConfiguration.Splash.completionDelay))
        guard !Task.isCancelled else { return }
        onFinish()
    }
}

private extension SplashView {
    enum Layout {
        static let logoTopRatio: CGFloat = 307.5 / 844
    }
}

private struct SplashProgressView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: Layout.labelToBar) {
            HStack {
                Text("Initializing Neural Network")
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.textSecondary)
                Spacer(minLength: AppSpacing.s12)
                Text(progress, format: .percent.precision(.fractionLength(0)))
                    .textStyle(.captionEmphasized)
                    .foregroundStyle(AppColor.highlight)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            GeometryReader { proxy in
                Capsule()
                    .fill(AppColor.progressTrack)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(AppColor.primaryBright)
                            .frame(width: proxy.size.width * min(max(progress, 0), 1))
                    }
            }
            .frame(height: AppSize.progressBarHeight)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Initializing Neural Network"))
        .accessibilityValue(Text(progress, format: .percent.precision(.fractionLength(0))))
    }

    private enum Layout {
        static let labelToBar: CGFloat = 9
    }
}

private struct SplashBackground: View {
    var body: some View {
        GeometryReader { proxy in
            RadialGradient(
                stops: [
                    .init(color: AppColor.primary.opacity(0.26), location: 0),
                    .init(color: AppColor.primary.opacity(0), location: 0.72)
                ],
                center: Layout.glowCenter,
                startRadius: 0,
                endRadius: proxy.size.width * Layout.glowRadiusRatio
            )
        }
        .background(AppColor.splashBackground)
        .ignoresSafeArea()
    }

    private enum Layout {
        static let glowCenter = UnitPoint(x: 0.5, y: 362.92 / 844)
        static let glowRadiusRatio: CGFloat = 300 / 390
    }
}

#Preview {
    SplashView {}
}
