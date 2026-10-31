import SwiftUI

/// An indeterminate ring spinner. A quarter arc rotating over a faint track.
struct SpinnerRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSpinning = false

    var size: CGFloat = 15
    var lineWidth: CGFloat = 2
    var color: Color = AppColor.accentStart
    var trackOpacity: Double = 0.25
    var duration: Double = AppMotion.spinnerDuration

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(color.opacity(trackOpacity), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .padding(lineWidth / 2)
                .rotationEffect(.degrees(isSpinning ? 360 : 0))
        }
        .frame(width: size, height: size)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                isSpinning = true
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        AppBackground()
        SpinnerRing(size: 40, lineWidth: 3)
    }
}
