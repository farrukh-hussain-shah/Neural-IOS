import SwiftUI

struct AppSwitchToggleStyle: ToggleStyle {
    struct Metrics {
        let trackSize: CGSize
        let knobDiameter: CGFloat
        let onColor: Color
        let offColor: Color
        let knobBorderWhenOff: Color?

        var knobInset: CGFloat { (trackSize.height - knobDiameter) / 2 }

        static let standard = Metrics(
            trackSize: CGSize(width: 48.scaled, height: 28.scaled),
            knobDiameter: 24.scaled,
            onColor: AppColor.primary,
            offColor: AppColor.indicatorInactive,
            knobBorderWhenOff: nil
        )

        static let compact = Metrics(
            trackSize: CGSize(width: 44.scaled, height: 24.scaled),
            knobDiameter: 19.scaled,
            onColor: AppColor.azure,
            offColor: AppColor.switchTrackOff,
            knobBorderWhenOff: AppColor.switchKnobBorder
        )
    }

    var metrics: Metrics = .standard

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: AppSpacing.s12) {
            configuration.label
            Spacer(minLength: 0)
            track(isOn: configuration.isOn)
        }
        .contentShape(Rectangle())
        .onTapGesture { configuration.isOn.toggle() }
        .animation(.snappy(duration: 0.2), value: configuration.isOn)
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
                .toggleStyle(.switch)
        }
    }

    private func track(isOn: Bool) -> some View {
        Capsule()
            .fill(isOn ? metrics.onColor : metrics.offColor)
            .frame(width: metrics.trackSize.width, height: metrics.trackSize.height)
            .overlay(alignment: isOn ? .trailing : .leading) {
                Circle()
                    .fill(AppColor.switchKnob)
                    .overlay {
                        if !isOn, let border = metrics.knobBorderWhenOff {
                            Circle().strokeBorder(border, lineWidth: 1)
                        }
                    }
                    .frame(width: metrics.knobDiameter, height: metrics.knobDiameter)
                    .padding(metrics.knobInset)
            }
    }
}

extension ToggleStyle where Self == AppSwitchToggleStyle {
    static func appSwitch(_ metrics: AppSwitchToggleStyle.Metrics = .standard) -> AppSwitchToggleStyle {
        AppSwitchToggleStyle(metrics: metrics)
    }
}
