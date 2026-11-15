import SwiftUI

struct KeyCalloutShape: Shape {
    let keySize: CGSize
    let leadingOverhang: CGFloat
    let trailingOverhang: CGFloat
    let balloonHeight: CGFloat
    let neckHeight: CGFloat
    let cornerRadius: CGFloat
    let keyCornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let balloonLeft = rect.minX
        let balloonRight = rect.maxX
        let keyLeft = rect.minX + leadingOverhang
        let keyRight = keyLeft + keySize.width
        let balloonBottom = rect.minY + balloonHeight
        let keyStraightTop = balloonBottom + neckHeight
        let bottom = rect.maxY
        let radius = min(cornerRadius, balloonHeight / 2)
        let neckControl = balloonBottom + neckHeight * 0.55

        var path = Path()
        path.move(to: CGPoint(x: balloonLeft + radius, y: rect.minY))
        path.addLine(to: CGPoint(x: balloonRight - radius, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: balloonRight, y: rect.minY + radius), control: CGPoint(x: balloonRight, y: rect.minY))
        path.addLine(to: CGPoint(x: balloonRight, y: balloonBottom - radius))
        path.addCurve(
            to: CGPoint(x: keyRight, y: keyStraightTop),
            control1: CGPoint(x: balloonRight, y: neckControl),
            control2: CGPoint(x: keyRight, y: balloonBottom + neckHeight * 0.3)
        )
        path.addLine(to: CGPoint(x: keyRight, y: bottom - keyCornerRadius))
        path.addQuadCurve(to: CGPoint(x: keyRight - keyCornerRadius, y: bottom), control: CGPoint(x: keyRight, y: bottom))
        path.addLine(to: CGPoint(x: keyLeft + keyCornerRadius, y: bottom))
        path.addQuadCurve(to: CGPoint(x: keyLeft, y: bottom - keyCornerRadius), control: CGPoint(x: keyLeft, y: bottom))
        path.addLine(to: CGPoint(x: keyLeft, y: keyStraightTop))
        path.addCurve(
            to: CGPoint(x: balloonLeft, y: balloonBottom - radius),
            control1: CGPoint(x: keyLeft, y: balloonBottom + neckHeight * 0.3),
            control2: CGPoint(x: balloonLeft, y: neckControl)
        )
        path.addLine(to: CGPoint(x: balloonLeft, y: rect.minY + radius))
        path.addQuadCurve(to: CGPoint(x: balloonLeft + radius, y: rect.minY), control: CGPoint(x: balloonLeft, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

enum KeyEdge {
    case leading
    case trailing
    case none
}

struct KeyPopup: View {
    let label: String
    let keySize: CGSize
    let edge: KeyEdge

    var body: some View {
        let leading = edge == .leading ? 0 : KeyboardMetrics.popupOverhang
        let trailing = edge == .trailing ? 0 : KeyboardMetrics.popupOverhang
        let balloonHeight = KeyboardMetrics.popupExtraHeight - KeyboardMetrics.popupNeckHeight
        let shape = KeyCalloutShape(
            keySize: keySize,
            leadingOverhang: leading,
            trailingOverhang: trailing,
            balloonHeight: balloonHeight,
            neckHeight: KeyboardMetrics.popupNeckHeight,
            cornerRadius: KeyboardMetrics.popupCornerRadius,
            keyCornerRadius: KeyboardMetrics.keyCornerRadius
        )

        shape
            .fill(AppColor.keyboardKey)
            .overlay(shape.stroke(AppColor.keyboardPopupBorder, lineWidth: 0.5))
            .shadow(color: AppColor.keyboardPopupShadow, radius: 3, y: 1)
            .overlay(alignment: .top) {
                Text(label)
                    .font(.system(size: KeyboardMetrics.popupFontSize, weight: .light))
                    .foregroundStyle(AppColor.keyboardPopupLabel)
                    .frame(height: balloonHeight)
            }
            .frame(
                width: keySize.width + leading + trailing,
                height: keySize.height + KeyboardMetrics.popupExtraHeight
            )
            .offset(x: -leading)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

struct KeyAlternatesPopup: View {
    let alternates: [String]
    let selectedIndex: Int
    let keySize: CGSize
    let expandsLeading: Bool

    static func width(for count: Int) -> CGFloat {
        CGFloat(count) * KeyboardMetrics.alternateWidth + 2 * KeyboardMetrics.popupCornerRadius / 2
    }

    static func index(forOffset offset: CGFloat, count: Int, expandsLeading: Bool, keyWidth: CGFloat) -> Int {
        let width = Self.width(for: count)
        let origin = expandsLeading ? keyWidth - width : 0
        let position = (offset - origin - KeyboardMetrics.popupCornerRadius / 2) / KeyboardMetrics.alternateWidth
        return min(max(Int(position.rounded(.down)), 0), count - 1)
    }

    var body: some View {
        let width = Self.width(for: alternates.count)
        let balloonHeight = KeyboardMetrics.popupExtraHeight - KeyboardMetrics.popupNeckHeight
        let leading = expandsLeading ? width - keySize.width : 0
        let trailing = expandsLeading ? 0 : width - keySize.width
        let shape = KeyCalloutShape(
            keySize: keySize,
            leadingOverhang: leading,
            trailingOverhang: trailing,
            balloonHeight: balloonHeight,
            neckHeight: KeyboardMetrics.popupNeckHeight,
            cornerRadius: KeyboardMetrics.popupCornerRadius,
            keyCornerRadius: KeyboardMetrics.keyCornerRadius
        )

        shape
            .fill(AppColor.keyboardKey)
            .overlay(shape.stroke(AppColor.keyboardPopupBorder, lineWidth: 0.5))
            .shadow(color: AppColor.keyboardPopupShadow, radius: 3, y: 1)
            .overlay(alignment: .top) {
                HStack(spacing: 0) {
                    ForEach(Array(alternates.enumerated()), id: \.offset) { index, alternate in
                        Text(alternate)
                            .font(.system(size: KeyboardMetrics.alternateFontSize))
                            .foregroundStyle(index == selectedIndex ? Color.white : AppColor.keyboardPopupLabel)
                            .frame(width: KeyboardMetrics.alternateWidth, height: balloonHeight - 8)
                            .background(
                                RoundedRectangle(cornerRadius: KeyboardMetrics.keyCornerRadius, style: .continuous)
                                    .fill(index == selectedIndex ? AppColor.keyboardPrimary : .clear)
                            )
                    }
                }
                .padding(.top, 4)
            }
            .frame(width: keySize.width + leading + trailing, height: keySize.height + KeyboardMetrics.popupExtraHeight)
            .offset(x: -leading)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
