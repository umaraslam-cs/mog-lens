import SwiftUI
import AVFoundation
import UIKit

/// Onboarding — Technology / Measured Not Guessed Step.
/// Highlights on-device Apple Vision biometric facial landmark mapping and raw coordinate geometry.
struct TechnologyStepView: View {
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    private let claims = DesignContent.Onboarding.technologyClaims

    var body: some View {
        OnboardingScaffold(
            step: .technology,
            ctaTitle: DesignContent.Onboarding.technologyCTA,
            onContinue: onContinue
        ) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.l) {
                    // 1. Header Section
                    VStack(spacing: Spacing.s) {
                        // Eyebrow badge
                        Text(DesignContent.Onboarding.technologyEyebrow)
                            .font(AppFont.mono(11, .bold))
                            .tracking(1.4)
                            .foregroundStyle(Color.white.opacity(0.85))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.white.opacity(0.08)))
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

                        // Title: MEASURED. NOT GUESSED.
                        VStack(spacing: 2) {
                            Text(DesignContent.Onboarding.technologyTitleLead)
                                .font(AppFont.system(28, .heavy))
                                .foregroundStyle(Color.white)

                            Text(DesignContent.Onboarding.technologyTitleAccent)
                                .font(AppFont.system(28, .heavy))
                                .foregroundStyle(AppColor.accentStart)
                        }
                        .tracking(-0.4)
                        .multilineTextAlignment(.center)

                        // Subtitle
                        Text(DesignContent.Onboarding.technologySubtitle)
                            .font(AppFont.system(15))
                            .lineHeight(1.38, size: 15)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppColor.textSecondary)
                            .padding(.horizontal, Layout.horizontal)
                    }
                    .padding(.top, 56)
                    .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                    // 2. Hero Landmark Portrait Card
                    landmarkHeroCard
                        .padding(.horizontal, Layout.horizontal)
                        .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)

                    // 3. Feature Claims List
                    VStack(spacing: Spacing.m) {
                        ForEach(claims) { claim in
                            TechnologyClaimRow(claim: claim)
                        }
                    }
                    .padding(.horizontal, Layout.horizontal)
                    .staggeredAppear(hasAppeared, index: 2, reduceMotion: reduceMotion)

                    Spacer(minLength: 20)
                }
                .padding(.bottom, Layout.bottomCTAInset + 80)
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }

    /// Hero visual card with biometric facial landmark mapping video and cyan ambient rim glow
    private var landmarkHeroCard: some View {
        ZStack(alignment: .top) {
            // Ambient cyan spotlight glow behind the hero container
            RadialGlow(
                color: AppColor.accentStart,
                opacity: 0.16,
                diameter: 280,
                falloff: 0.75
            )
            .offset(y: -30)

            // Video player layer with aspect-fill scaling and dark gradient vignette
            LoopedVideoPlayer(resourceName: "technologysteps", playbackRate: 1.6)
                .frame(height: 270)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay {
                    // Vignette & subtle bottom dark gradient blend
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.65),
                            .init(color: Color(hex: 0x050C12).opacity(0.85), location: 0.95),
                            .init(color: Color(hex: 0x050C12), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

            // Top Cyan Neon Glow Accent Edge
            VStack {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: AppColor.accentStart.opacity(0.95), location: 0.5),
                        .init(color: .clear, location: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 2.5)
                .shadow(color: AppColor.accentStart, radius: 8, x: 0, y: 1)
                .shadow(color: AppColor.accentStart.opacity(0.6), radius: 16, x: 0, y: 2)

                Spacer()
            }
        }
        .frame(height: 270)
        .frame(maxWidth: .infinity)
        .background(Color(hex: 0x07111A))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: AppColor.accentStart.opacity(0.65), location: 0.0),
                            .init(color: Color.white.opacity(0.12), location: 0.35),
                            .init(color: Color.white.opacity(0.06), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.2
                )
        }
        .shadow(color: AppColor.accentStart.opacity(0.20), radius: 16, x: 0, y: 6)
    }
}

#Preview("Technology Step") {
    TechnologyStepView(onContinue: {})
        .preferredColorScheme(.dark)
}
