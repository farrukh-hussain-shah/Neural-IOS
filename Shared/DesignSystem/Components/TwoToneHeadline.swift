import SwiftUI

struct TwoToneHeadline: View {
    let primary: LocalizedStringKey
    let accent: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(primary)
                .textStyle(.headline)
                .foregroundStyle(AppColor.textPrimary)
            Text(accent)
                .textStyle(.headline)
                .foregroundStyle(AppColor.accent)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
