import SwiftUI

/// 09 — Home empty state. Shown when the local scan store is empty.
/// No skeleton cards, no fake numbers.
struct HomeEmptyState: View {
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            ZStack {
                BreathingGlow(opacity: 0.12, diameter: 150, duration: 5)

                Circle()
                    .strokeBorder(
                        AppColor.accentStart.opacity(0.35),
                        style: StrokeStyle(lineWidth: 1, dash: [5, 5])
                    )
                    .padding(12)

                Image(systemName: AppSymbol.takePhoto)
                    .font(.system(size: 52, weight: .regular))
                    .foregroundStyle(AppColor.accentStart)
            }
            .frame(width: 150, height: 150)
            .accessibilityHidden(true)

            VStack(spacing: Spacing.s) {
                Text(DesignContent.Home.emptyTitle)
                    .font(AppFont.title2)
                    .tracking(Tracking.title2)
                    .foregroundStyle(AppColor.textPrimary)

                Text(DesignContent.Home.emptyBody)
                    .font(AppFont.callout)
                    .lineHeight(1.45, size: 16)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 32)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ZStack {
        AppBackground()
        HomeEmptyState()
    }
}
