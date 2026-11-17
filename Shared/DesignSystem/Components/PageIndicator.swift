import SwiftUI

struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: AppSpacing.s6) {
            ForEach(0..<count, id: \.self) { index in
                let isCurrent = index == currentIndex
                Capsule()
                    .fill(isCurrent ? AppColor.primary : AppColor.indicatorInactive)
                    .frame(
                        width: isCurrent ? AppSize.pageIndicatorActiveWidth : AppSize.pageIndicatorInactiveWidth,
                        height: AppSize.pageIndicatorHeight
                    )
            }
        }
        .animation(AppAnimation.pageIndicator, value: currentIndex)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Page \(currentIndex + 1) of \(count)"))
    }
}
