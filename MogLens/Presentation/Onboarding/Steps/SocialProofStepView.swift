import SwiftUI

/// Onboarding — Research on First Impressions Step ("What the research says about first impressions").
/// Displays peer-reviewed academic research findings from Princeton, University of Texas, etc.,
/// with exact quotes and clear disclaimers that they represent research on judgment, not app endorsements.
struct SocialProofStepView: View {
    var onBack: (() -> Void)? = nil
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    private let cards = DesignContent.Onboarding.researchCards

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                topNavBar
                    .padding(.horizontal, Layout.horizontal)
                    .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {
                        headlineBlock
                            .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                        researchCardList

                        Spacer(minLength: 20)
                    }
                    .padding(.top, Spacing.m)
                    .padding(.bottom, Layout.bottomCTAInset + 80)
                }
            }

            VStack(spacing: 0) {
                Spacer()
                BottomCTA {
                    PrimaryButton(
                        title: DesignContent.Onboarding.researchCTA,
                        action: onContinue
                    )
                }
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }

    // MARK: - Top Navigation Bar

    private var topNavBar: some View {
        HStack(alignment: .center) {
            Spacer()

            // Eyebrow capsule
            Text(DesignContent.Onboarding.researchEyebrow)
                .font(AppFont.mono(10, .bold))
                .tracking(0.8)
                .foregroundStyle(Color.white.opacity(0.75))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.white.opacity(0.07)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

            Spacer()
        }
    }

    // MARK: - Headline Block

    private var headlineBlock: some View {
        VStack(spacing: 3) {
            Text(DesignContent.Onboarding.researchTitleLead)
                .font(AppFont.system(28, .bold))
                .foregroundStyle(Color.white)

            Text(DesignContent.Onboarding.researchTitleMid)
                .font(AppFont.system(28, .bold))
                .foregroundStyle(Color.white.opacity(0.92))

            Text(DesignContent.Onboarding.researchTitleAccent)
                .font(AppFont.system(28, .bold))
                .foregroundStyle(AppColor.accentStart)
        }
        .tracking(-0.4)
        .multilineTextAlignment(.center)
        .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 2)
        .padding(.horizontal, Layout.horizontal)
    }

    // MARK: - Research Card List

    private var researchCardList: some View {
        VStack(spacing: Spacing.m) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                researchCard(card)
                    .staggeredAppear(hasAppeared, index: index + 1, reduceMotion: reduceMotion)
            }
        }
        .padding(.horizontal, Layout.horizontal)
    }

    // MARK: - Research Card

    private func researchCard(_ card: ResearchCard) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Headline
            Text(card.headline)
                .font(AppFont.system(16, .bold))
                .foregroundStyle(Color.white)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            // Quote (when available)
            if let quote = card.quote {
                HStack(alignment: .top, spacing: 10) {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(AppColor.accentStart)
                        .frame(width: 3)

                    Text(quote)
                        .font(AppFont.system(14.5, .medium))
                        .italic()
                        .foregroundStyle(Color.white.opacity(0.92))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 2)
            }

            // Attribution
            Text(card.attribution)
                .font(AppFont.system(13, .regular))
                .foregroundStyle(Color.white.opacity(0.65))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.top, 2)

            // Footer
            Text(card.footer)
                .font(AppFont.system(11, .regular))
                .foregroundStyle(Color.white.opacity(0.42))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColor.panelDeep.opacity(0.92))
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppColor.surfaceStrong)
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}

typealias ResearchStepView = SocialProofStepView

#Preview("Research Step") {
    SocialProofStepView(onBack: {}, onContinue: {})
        .preferredColorScheme(.dark)
}
