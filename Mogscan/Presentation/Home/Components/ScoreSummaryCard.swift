import SwiftUI

/// Home hero card: score ring, current tier, summary line and a footer linking
/// through to the full result.
struct ScoreSummaryCard: View {
    let scan: FaceScan
    let lastScanCaption: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.screen) {
                ScoreRing(score: scan.overallScore)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    EyebrowLabel(
                        text: DesignContent.Home.currentTierLabel,
                        color: AppColor.textSecondary,
                        size: 11,
                        tracking: Tracking.label
                    )

                    TierBadge(tier: scan.tier, size: .medium)

                    Text(scan.summary)
                        .font(AppFont.system(13.5))
                        .lineHeight(1.35, size: 13.5)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            HairlineDivider(color: AppColor.hairlineStrong)
                .padding(.top, Spacing.l)

            HStack {
                Text(lastScanCaption)
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)

                Spacer(minLength: Spacing.xs)

                HStack(spacing: Spacing.xxs) {
                    Text(DesignContent.Home.viewAction)
                        .font(AppFont.system(13, .semibold))
                    Image(systemName: AppSymbol.chevronRight)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(AppColor.accentStart)
            }
            .padding(.top, Spacing.ml)
        }
        .padding(Spacing.screen)
        .background(alignment: .topTrailing) {
            RadialGlow(opacity: 0.18, diameter: 200, falloff: 0.7)
                .offset(x: 50, y: -70)
        }
        .gradientCard(
            AppGradient.heroCard,
            radius: Radius.hero,
            border: AppColor.accentStart.opacity(0.2)
        )
        .roundedClip(Radius.hero)
    }
}

#Preview {
    ZStack {
        AppBackground()
        ScoreSummaryCard(
            scan: PreviewData.latestScan,
            lastScanCaption: "Last scan · 12 Mar, 09:24"
        )
        .padding(.horizontal, Layout.horizontal)
    }
}
