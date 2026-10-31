import SwiftUI

/// Home's stand-in for the score card while the results are locked.
///
/// Occupies the same slot as ``ScoreSummaryCard`` and deliberately carries none
/// of its content: no score, no tier, no metric, not even blurred. The paywall
/// gates the entire result, so the only thing Home may say is that a result
/// exists.
struct LockedResultsCard: View {
    let detail: String
    let onUnlock: () -> Void

    var body: some View {
        VStack(spacing: Spacing.m) {
            IconTile(
                symbol: AppSymbol.locked,
                size: 52,
                radius: Radius.listCard,
                symbolSize: 22,
                fillOpacity: 0.14,
                border: AppColor.accentStart.opacity(0.3)
            )

            Text(DesignContent.Home.lockedTitle)
                .font(AppFont.sectionTitle)
                .tracking(Tracking.sectionTitle)
                .foregroundStyle(AppColor.textPrimary)

            Text(detail)
                .font(AppFont.footnote)
                .lineHeight(1.4, size: 13)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            PrimaryButton(title: DesignContent.Home.lockedCTA, action: onUnlock)
                .padding(.top, Spacing.xxs)
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity)
        .background(AppColor.surface, in: RoundedRectangle(
            cornerRadius: Radius.hero, style: .continuous
        ))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.hero, style: .continuous)
                .strokeBorder(AppColor.accentStart.opacity(0.28), lineWidth: 1)
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        LockedResultsCard(detail: DesignContent.Home.lockedDetail(count: 2)) {}
            .padding(.horizontal, Layout.horizontal)
    }
    .preferredColorScheme(.dark)
}
