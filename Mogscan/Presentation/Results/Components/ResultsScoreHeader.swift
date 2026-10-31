import SwiftUI

/// The overall score, tier badge and cohort line.
///
/// Score counts 0 → N over 0.8s; the badge springs in 0.4s later with a success
/// haptic.
struct ResultsScoreHeader: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayedScore: Double = 0
    @State private var isBadgeVisible = false

    let scan: FaceScan

    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack(alignment: .bottom, spacing: Spacing.xxsPlus) {
                AnimatedNumberText(value: displayedScore)
                Text("/100")
                    .font(AppFont.system(19))
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.bottom, Spacing.xs)
            }

            TierBadge(tier: scan.tier, size: .large)
                .scaleEffect(isBadgeVisible ? 1 : 0.8)
                .opacity(isBadgeVisible ? 1 : 0)

            Text(scan.percentileSummary)
                .font(AppFont.system(13.5))
                .foregroundStyle(AppColor.textSecondary)
        }
        .sensoryFeedback(.success, trigger: isBadgeVisible)
        .onAppear(perform: reveal)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Overall score \(scan.overallScore) out of 100, tier \(scan.tier.displayName). \(scan.percentileSummary)"
        )
    }

    private func reveal() {
        guard !reduceMotion else {
            displayedScore = Double(scan.overallScore)
            isBadgeVisible = true
            return
        }
        withAnimation(.easeOut(duration: AppMotion.scoreCountDuration)) {
            displayedScore = Double(scan.overallScore)
        }
        withAnimation(AppMotion.tierBadge.delay(AppMotion.tierBadgeDelay)) {
            isBadgeVisible = true
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        ResultsScoreHeader(scan: PreviewData.latestScan)
    }
}
