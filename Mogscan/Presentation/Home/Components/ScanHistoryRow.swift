import SwiftUI

/// One row of the local scan history: thumbnail, date, score and tier.
/// Selecting it opens the Results screen.
struct ScanHistoryRow: View {
    let scan: FaceScan
    /// The stored photo, already downsized to thumbnail pixels by the view model.
    var image: UIImage?

    var body: some View {
        HStack(spacing: Spacing.ml) {
            PhotoSlot(placeholder: scan.photoDescription, image: image, showsLabel: true)
                .frame(width: 52, height: 52)
                .roundedClip(12)

            VStack(alignment: .leading, spacing: 3) {
                Text(ScanDateFormatter.long(scan.capturedAt))
                    .font(AppFont.calloutEmphasis)
                    .foregroundStyle(AppColor.textPrimary)
                Text("\(ScanDateFormatter.time(scan.capturedAt)) · \(scan.poseDescription)")
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer(minLength: Spacing.xs)

            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text("\(scan.overallScore)")
                    .font(AppFont.system(19, .bold))
                    .tracking(-0.19)
                    .monospacedDigit()
                    .foregroundStyle(AppColor.textPrimary)
                TierLabel(tier: scan.tier)
            }

            Image(systemName: AppSymbol.chevronRight)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(Spacing.s)
        .surfaceCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(ScanDateFormatter.long(scan.capturedAt)), score \(scan.overallScore), tier \(scan.tier.displayName)"
        )
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.m) {
            ForEach(PreviewData.history) { ScanHistoryRow(scan: $0) }
        }
        .padding(.horizontal, Layout.horizontal)
    }
}
