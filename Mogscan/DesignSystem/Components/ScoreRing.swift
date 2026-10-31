import SwiftUI

/// The Home hero score ring: an accent arc trimmed to the score, over a faint
/// remainder, with the score punched into a dark core.
///
/// Trims 0 → score over 0.9s `.easeOut` on appear.
struct ScoreRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedProgress: Double = 0

    let score: Int
    var diameter: CGFloat = 104
    var lineWidth: CGFloat = 9

    /// The arc measures the score out of 100, matching the "/ 100" under it.
    private var fill: Double { Double(score) / 100 }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColor.hairline, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [AppColor.accentStart, AppColor.accentEnd],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )
                .rotationEffect(.degrees(-90))

            Circle()
                .fill(AppColor.scoreRingCore)
                .padding(lineWidth)

            VStack(spacing: 0) {
                Text("\(score)")
                    .font(AppFont.ringScore)
                    .tracking(Tracking.screenTitle)
                    .monospacedDigit()
                    .foregroundStyle(AppColor.textPrimary)
                Text("/ 100")
                    .font(AppFont.system(10))
                    .tracking(Tracking.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .frame(width: diameter, height: diameter)
        .shadow(color: AppColor.accentStart.opacity(0.22), radius: 15)
        .onAppear {
            guard !reduceMotion else {
                animatedProgress = fill
                return
            }
            withAnimation(AppMotion.ringTrim) {
                animatedProgress = fill
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Overall score \(score) out of 100")
    }
}

#Preview {
    ZStack {
        AppBackground()
        ScoreRing(score: 81)
    }
}
