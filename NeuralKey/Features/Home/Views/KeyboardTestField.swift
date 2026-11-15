import SwiftUI

struct KeyboardTestField: View {
    @Binding var text: String

    private var fieldShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Layout.cornerRadius)
    }

    var body: some View {
        TextField(
            "Test your keyboard",
            text: $text,
            prompt: Text("Type something...").foregroundStyle(AppColor.textPlaceholder)
        )
        .textStyle(.input)
        .foregroundStyle(AppColor.textPrimary)
        .tint(AppColor.royal)
        .padding(.horizontal, Layout.horizontalPadding)
        .frame(height: AppSize.inputHeight)
        .background {
            fieldShape
                .stroke(AppGradient.brand, lineWidth: Layout.glowWidth)
                .blur(radius: Layout.glowBlur)
                .opacity(Layout.glowOpacity)
        }
        .background(fieldShape.fill(AppColor.inputSurface))
        .overlay {
            fieldShape
                .strokeBorder(AppGradient.brand, lineWidth: Layout.borderWidth)
                .opacity(Layout.borderOpacity)
        }
    }

    private enum Layout {
        static let cornerRadius: CGFloat = 12.narrowScaled
        static let horizontalPadding: CGFloat = 13.5.narrowScaled
        static let borderWidth: CGFloat = 1.5.narrowScaled
        static let borderOpacity: Double = 0.6
        static let glowWidth: CGFloat = 3.narrowScaled
        static let glowBlur: CGFloat = 4.narrowScaled
        static let glowOpacity: Double = 0.55
    }
}
