import SwiftUI

/// One improvement card: icon tile, title, short description and optional
/// difficulty / time chips.
struct RecommendationCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    let recommendation: Recommendation
    var index: Int = 0

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            IconTile(symbol: recommendation.symbol)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(recommendation.title)
                    .font(AppFont.calloutEmphasis)
                    .foregroundStyle(AppColor.textPrimary)

                Text(recommendation.detail)
                    .font(AppFont.system(13.5))
                    .lineHeight(1.35, size: 13.5)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if hasChips {
                    HStack(spacing: Spacing.xxsPlus) {
                        if let difficulty = recommendation.difficulty {
                            Chip(difficulty: difficulty)
                        }
                        if let time = recommendation.timeCommitment {
                            Chip(text: time)
                        }
                    }
                    .padding(.top, 2)
                }
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

    private var hasChips: Bool {
        recommendation.difficulty != nil || recommendation.timeCommitment != nil
    }
}

#Preview {
    ZStack {
        AppBackground()
        ScrollView {
            VStack(spacing: Spacing.s) {
                ForEach(Array(PreviewData.recommendations.enumerated()), id: \.element.id) { index, item in
                    RecommendationCard(recommendation: item, index: index)
                }
            }
            .padding(.horizontal, Layout.horizontal)
        }
    }
}
