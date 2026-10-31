import SwiftUI

/// One metric's advice: icon tile, metric name, its rating chip, why it matters
/// and the tips for the band it landed in.
///
/// Shared by Results — where the two weakest metrics appear under the numbers —
/// and Improve, which lists all five. Same card either side, so the plan reads
/// as a continuation of the report rather than a different document.
struct MetricAdviceCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    let advice: MetricAdvice
    /// Position in its list, for the appearance stagger.
    var index: Int = 0
    /// Results shows the short form: tips only, no "why it matters" paragraph,
    /// because the screen above it is already dense with numbers.
    var showsWhyItMatters: Bool = true

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            IconTile(symbol: advice.symbol)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                header

                if showsWhyItMatters {
                    Text(advice.whyItMatters)
                        .font(AppFont.system(13.5))
                        .lineHeight(1.35, size: 13.5)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    ForEach(Array(advice.tips.enumerated()), id: \.offset) { _, tip in
                        TipRow(text: tip)
                    }
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.ml)
        .surfaceCard()
        .opacity(hasAppeared || reduceMotion ? 1 : 0)
        .offset(y: hasAppeared || reduceMotion ? 0 : AppMotion.cardAppearOffset)
        .onAppear {
            withAnimation(
                reduceMotion ? nil : AppMotion.cardAppear.delay(Double(index) * AppMotion.cardStagger)
            ) {
                hasAppeared = true
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var header: some View {
        HStack(spacing: Spacing.xs) {
            Text(advice.title)
                .font(AppFont.calloutEmphasis)
                .foregroundStyle(AppColor.textPrimary)

            // Repeats the bar colour in words, so the band a tip belongs to is
            // never carried by colour alone.
            Text(advice.rating.label)
                .font(AppFont.system(11, .semibold))
                .tracking(Tracking.label)
                .foregroundStyle(advice.rating.color)
        }
    }
}

/// A single bulleted tip. A leading dot rather than a `Label` so wrapped lines
/// stay hanging-indented under the text, not under the bullet.
private struct TipRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.xs) {
            Circle()
                .fill(AppColor.accentStart)
                .frame(width: 4, height: 4)
                .padding(.top, 7)

            Text(text)
                .font(AppFont.system(13.5))
                .lineHeight(1.35, size: 13.5)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        ScrollView {
            VStack(spacing: Spacing.s) {
                ForEach(Array(PreviewData.advice.enumerated()), id: \.element.id) { index, item in
                    MetricAdviceCard(advice: item, index: index)
                }
            }
            .padding(.horizontal, Layout.horizontal)
        }
    }
    .preferredColorScheme(.dark)
}
