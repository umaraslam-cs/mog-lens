import SwiftUI

/// The dashed face guide on the Scan entry screen, with accent corner brackets
/// and a breathing glow behind it.
struct FaceGuideView: View {
    var width: CGFloat = 210
    var height: CGFloat = 270

    var body: some View {
        ZStack {
            BreathingGlow(opacity: 0.10, diameter: max(width, height) + 32, duration: 5)

            FaceGuideShape()
                .stroke(
                    AppColor.accentStart.opacity(0.4),
                    style: StrokeStyle(lineWidth: 1, dash: [6, 5])
                )

            Image(systemName: AppSymbol.faceGuide)
                .font(.system(size: 74, weight: .light))
                .foregroundStyle(AppColor.accentStart.opacity(0.85))

            CornerBrackets()
        }
        .frame(width: width, height: height)
        .accessibilityHidden(true)
    }
}

/// A capture guideline row: quiet icon, quiet copy.
struct CaptureGuidelineRow: View {
    let guideline: CaptureGuideline

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: guideline.symbol)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: 20)

            Text(guideline.text)
                .font(AppFont.system(14.5))
                .foregroundStyle(AppColor.textSecondary)

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.section) {
            FaceGuideView()
            VStack(spacing: Spacing.m) {
                ForEach(DesignContent.Scan.guidelines) { CaptureGuidelineRow(guideline: $0) }
            }
            .padding(.horizontal, Layout.horizontal)
        }
    }
}
