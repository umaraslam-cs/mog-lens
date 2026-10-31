import SwiftUI

/// The face guide outline — an oval with a slightly flatter, narrower base,
/// matching the design's `border-radius: 50% 50% 46% 46%`.
struct FaceGuideShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let topRadiusY = rect.height * 0.5
        let bottomRadiusY = rect.height * 0.46
        let radiusX = rect.width / 2

        path.move(to: CGPoint(x: midX, y: rect.minY))
        // Upper right quarter.
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + topRadiusY),
            control1: CGPoint(x: midX + radiusX * 0.552, y: rect.minY),
            control2: CGPoint(x: rect.maxX, y: rect.minY + topRadiusY * 0.448)
        )
        // Lower right quarter.
        path.addCurve(
            to: CGPoint(x: midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.maxY - bottomRadiusY * 0.448),
            control2: CGPoint(x: midX + radiusX * 0.552, y: rect.maxY)
        )
        // Lower left quarter.
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + topRadiusY),
            control1: CGPoint(x: midX - radiusX * 0.552, y: rect.maxY),
            control2: CGPoint(x: rect.minX, y: rect.maxY - bottomRadiusY * 0.448)
        )
        // Upper left quarter.
        path.addCurve(
            to: CGPoint(x: midX, y: rect.minY),
            control1: CGPoint(x: rect.minX, y: rect.minY + topRadiusY * 0.448),
            control2: CGPoint(x: midX - radiusX * 0.552, y: rect.minY)
        )
        path.closeSubpath()
        return path
    }
}

/// Four accent corner brackets framing the face guide on the Scan entry screen.
struct CornerBrackets: View {
    var length: CGFloat = 26
    var lineWidth: CGFloat = 2
    var cornerRadius: CGFloat = 6
    var color: Color = AppColor.accentStart

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                bracket(.topLeading)
                    .position(x: length / 2, y: length / 2)
                bracket(.topTrailing)
                    .position(x: geometry.size.width - length / 2, y: length / 2)
                bracket(.bottomLeading)
                    .position(x: length / 2, y: geometry.size.height - length / 2)
                bracket(.bottomTrailing)
                    .position(x: geometry.size.width - length / 2, y: geometry.size.height - length / 2)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func bracket(_ corner: UnitPoint) -> some View {
        BracketShape(corner: corner, cornerRadius: cornerRadius)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: length, height: length)
    }
}

private struct BracketShape: Shape {
    let corner: UnitPoint
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = cornerRadius

        switch corner {
        case .topLeading:
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + r, y: rect.minY),
                control: CGPoint(x: rect.minX, y: rect.minY)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        case .topTrailing:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + r),
                control: CGPoint(x: rect.maxX, y: rect.minY)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        case .bottomLeading:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - r))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + r, y: rect.maxY),
                control: CGPoint(x: rect.minX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        default:
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - r, y: rect.maxY),
                control: CGPoint(x: rect.maxX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        return path
    }
}

#Preview {
    ZStack {
        AppBackground()
        ZStack {
            FaceGuideShape()
                .stroke(
                    AppColor.accentStart.opacity(0.4),
                    style: StrokeStyle(lineWidth: 1, dash: [6, 5])
                )
            CornerBrackets()
        }
        .frame(width: 210, height: 270)
    }
}
