import SwiftUI

struct KeyboardTestField: View {
    @Binding var text: String

    var body: some View {
        TextField(
            "Test your keyboard",
            text: $text,
            prompt: Text("Type something amazing...").foregroundStyle(AppColor.textPlaceholder)
        )
        .textStyle(.input)
        .foregroundStyle(AppColor.textPrimary)
        .tint(AppColor.royal)
        .padding(.horizontal, AppSpacing.s20)
        .frame(height: AppSize.inputHeight)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(AppColor.inputGlow)
                    .padding(-AppSpacing.s2)
                    .blur(radius: AppSpacing.s4)
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(AppColor.inputSurface)
                    .appShadow(.inputDepth)
            }
        }
    }
}
