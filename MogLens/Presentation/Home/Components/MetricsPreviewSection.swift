import SwiftUI

/// The three-metric preview under the hero card. Bars fill with a 0.06s stagger.
struct MetricsPreviewSection: View {
    let metrics: [FacialMetric]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: DesignContent.Home.metricsSection)

            VStack(spacing: Spacing.s) {
                ForEach(Array(metrics.enumerated()), id: \.element.id) { index, metric in
                    MetricPreviewRow(metric: metric, delay: Double(index) * AppMotion.barStagger)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        MetricsPreviewSection(metrics: PreviewData.latestScan.previewMetrics)
            .padding(.horizontal, Layout.horizontal)
    }
}
