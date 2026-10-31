import SwiftUI

/// Maps a rating to its semantic colour. Colour never carries meaning alone —
/// the percentile caption repeats it in words.
extension MetricRating {
    var color: Color {
        switch self {
        case .excellent: AppColor.success
        case .average: AppColor.warning
        case .needsImprovement: AppColor.negative
        }
    }
}

/// Compact metric row used in the Home preview: label · bar · score.
struct MetricPreviewRow: View {
    let metric: FacialMetric
    var delay: Double = 0

    var body: some View {
        HStack(spacing: Spacing.m) {
            Text(metric.kind.shortName)
                .font(AppFont.system(14))
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: 118, alignment: .leading)

            ProgressBarView(
                progress: metric.progress,
                height: 6,
                color: metric.rating.color,
                delay: delay
            )

            Text("\(metric.percentile)")
                .font(AppFont.mono(13))
                .foregroundStyle(metric.rating.color)
                .frame(width: 34, alignment: .trailing)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(metric.accessibilityDescription)
    }
}

/// Full metric card used on Results: title · value · bar · percentile caption.
struct MetricCard: View {
    let metric: FacialMetric
    var delay: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(metric.name)
                    .font(AppFont.system(15.5, .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                Spacer(minLength: Spacing.xs)
                Text(metric.formattedValue)
                    .font(AppFont.mono(15))
                    .foregroundStyle(metric.rating.color)
            }

            ProgressBarView(
                progress: metric.progress,
                height: 5,
                color: metric.rating.color,
                delay: delay
            )

            Text(metric.percentileCaption)
                .font(AppFont.system(12.5))
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(.vertical, 13)
        .padding(.horizontal, Spacing.ml)
        .surfaceCard(radius: Radius.button)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(metric.accessibilityDescription)
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.s) {
            ForEach(PreviewData.latestScan.metrics) { metric in
                MetricPreviewRow(metric: metric)
            }
            Divider().overlay(AppColor.hairline)
            ForEach(PreviewData.latestScan.metrics) { metric in
                MetricCard(metric: metric)
            }
        }
        .padding(Layout.horizontal)
    }
}
