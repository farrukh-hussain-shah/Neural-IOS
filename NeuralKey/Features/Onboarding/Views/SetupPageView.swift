import SwiftUI

struct SetupPageView: View {
    let content: SetupContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(content.eyebrow)
                .textStyle(.eyebrow)
                .foregroundStyle(AppColor.soft)

            TwoToneHeadline(primary: content.headline.primary, accent: content.headline.accent)
                .padding(.top, AppSpacing.s8)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(content.steps) { step in
                    SetupStepRow(step: step, isLast: step.id == content.steps.last?.id)
                }
            }
            .padding(.top, AppSpacing.s32)
        }
    }
}

private struct SetupStepRow: View {
    let step: SetupStepItem
    let isLast: Bool

    private var isActive: Bool { step.status == .active }

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.s14) {
            VStack(spacing: AppSpacing.s6) {
                StepMarker(number: step.number, status: step.status)
                if !isLast {
                    Capsule()
                        .fill(step.status == .completed ? AppColor.stepConnectorCompleted : AppColor.stepConnector)
                        .frame(width: AppSize.stepConnectorWidth)
                        .frame(maxHeight: .infinity)
                }
            }

            details
                .padding(.bottom, isLast ? 0 : AppSpacing.s26)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(step.title)
                .textStyle(isActive ? .stepTitle : .stepTitleInactive)
                .foregroundStyle(isActive ? AppColor.textPrimary : AppColor.textMuted)
                .frame(minHeight: AppSize.stepMarker, alignment: .leading)
                .accessibilityAddTraits(isActive ? .isHeader : [])

            Text(step.detail)
                .textStyle(isActive ? .body : .caption)
                .foregroundStyle(isActive ? AppColor.textSecondary : AppColor.textTertiary)
                .padding(.top, AppSpacing.s2)

            if isActive, let toggleTitle = step.toggleTitle {
                SetupToggleCard(title: toggleTitle)
                    .padding(.top, AppSpacing.s16)
            }

            if isActive, let note = step.note {
                SetupNote(text: note)
                    .padding(.top, AppSpacing.s14)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct StepMarker: View {
    let number: Int
    let status: SetupStepItem.Status

    var body: some View {
        ZStack {
            switch status {
            case .completed:
                Circle()
                    .fill(AppColor.stepCompleted)
                Image(.check)
                    .resizable()
                    .frame(width: AppSize.Icon.small, height: AppSize.Icon.small)
                    .foregroundStyle(AppColor.pale)
            case .active:
                Circle()
                    .fill(AppColor.primary)
                Text(number, format: .number)
                    .textStyle(.stepNumber)
                    .foregroundStyle(AppColor.textPrimary)
            case .pending:
                Circle()
                    .strokeBorder(AppColor.stepPendingBorder, lineWidth: 1)
                Text(number, format: .number)
                    .textStyle(.stepNumber)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .frame(width: AppSize.stepMarker, height: AppSize.stepMarker)
        .accessibilityHidden(true)
    }
}

private struct SetupToggleCard: View {
    let title: LocalizedStringKey

    @State private var isOn = true

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .textStyle(.controlLabel)
                .foregroundStyle(AppColor.textPrimary)
        }
        .toggleStyle(.appSwitch(.standard))
        .padding(.leading, AppSpacing.s18)
        .padding(.trailing, AppSpacing.s16)
        .frame(height: AppSize.toggleCardHeight)
        .background(RoundedRectangle(cornerRadius: AppRadius.xl).fill(AppColor.selectedSurface))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.xl).strokeBorder(AppColor.primary, lineWidth: 1))
    }
}

private struct SetupNote: View {
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.s8) {
            Image(.lock)
                .resizable()
                .frame(width: AppSize.Icon.small, height: AppSize.Icon.small)
                .foregroundStyle(AppColor.soft)
                .padding(.top, AppSpacing.s2)
                .accessibilityHidden(true)
            Text(text)
                .textStyle(.note)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}
