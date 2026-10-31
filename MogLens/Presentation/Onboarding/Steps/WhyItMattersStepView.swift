import SwiftUI

/// 04 — Hype 2, Why It Matters.
/// Displays the question headline directly under the progress bar, followed by
/// the two enhanced glassmorphic value proposition cards and the pinned Continue button.
struct WhyItMattersStepView: View {
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    private let propositions = DesignContent.Onboarding.valuePropositions

    var body: some View {
        OnboardingScaffold(step: .whyItMatters, onContinue: onContinue) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    // Heading directly under the progress bar
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(DesignContent.Onboarding.whyTitle)
                            .font(AppFont.system(18, .medium))
                            .foregroundStyle(AppColor.textSecondary)
                            .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                        (
                            Text(DesignContent.Onboarding.whyHeroAccent)
                                .foregroundStyle(AppColor.accentStart)
                            + Text(DesignContent.Onboarding.whyHeroRemaining)
                                .foregroundStyle(Color.white)
                        )
                        .font(AppFont.system(32, .heavy))
                        .tracking(-0.5)
                        .lineHeight(1.12, size: 32)
                        .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)
                    }

                    // Value Proposition Cards
                    VStack(spacing: Spacing.m) {
                        ForEach(Array(propositions.enumerated()), id: \.element.id) { index, proposition in
                            ValuePropositionCard(proposition: proposition, index: index)
                        }
                    }
                }
                .padding(.horizontal, Layout.horizontal)
                .padding(.top, 56)
                .padding(.bottom, Layout.bottomCTAInset + 80)
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }
}

#Preview("04 Why it matters") {
    WhyItMattersStepView {}
        .preferredColorScheme(.dark)
}
