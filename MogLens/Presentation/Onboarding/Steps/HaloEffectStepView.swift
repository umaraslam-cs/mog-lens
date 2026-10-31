import SwiftUI

/// 03 — Hype 1, The Halo Effect. A visually immersive portrait seamlessly blended
/// into the background gradient, with a rounded eyebrow badge, high-impact headline,
/// and copy explaining the psychological impact of facial features.
struct HaloEffectStepView: View {
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        OnboardingScaffold(step: .haloEffect, onContinue: onContinue) {
            ZStack(alignment: .top) {
                hero

                VStack(alignment: .leading, spacing: Spacing.s) {
                    // Eyebrow with rounded capsule background
                    eyebrowBadge
                        .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                    // 4-line high-contrast title matching Discover Face typography
                    VStack(alignment: .leading, spacing: 1) {
                        Text(DesignContent.Onboarding.haloTitleLead)
                            .font(AppFont.system(32, .bold))
                            .foregroundStyle(Color.white)

                        Text(DesignContent.Onboarding.haloTitleAccent)
                            .font(AppFont.system(32, .bold))
                            .foregroundStyle(AppColor.accentStart)

                        Text(DesignContent.Onboarding.haloTitleMid)
                            .font(AppFont.system(32, .bold))
                            .foregroundStyle(Color.white)

                        Text(DesignContent.Onboarding.haloTitleEnd)
                            .font(AppFont.system(32, .bold))
                            .foregroundStyle(Color.white)
                    }
                    .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                    .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)

                    // Body copy
                    Text(DesignContent.Onboarding.haloBody)
                        .font(AppFont.system(15))
                        .lineHeight(1.42, size: 15)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .staggeredAppear(hasAppeared, index: 2, reduceMotion: reduceMotion)
                }
                .padding(.horizontal, Layout.horizontal)
                .padding(.top, 435)
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }

    /// Rounded pill badge for "THE HALO EFFECT"
    private var eyebrowBadge: some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(AppColor.accentStart)
                .frame(width: 6, height: 6)
                .shadow(color: AppColor.accentStart.opacity(0.8), radius: 4)

            Text(DesignContent.Onboarding.haloEyebrow)
                .font(AppFont.mono(11, .semibold))
                .tracking(0.8)
                .foregroundStyle(AppColor.accentStart)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.06))
        .overlay {
            Capsule()
                .strokeBorder(AppColor.accentStart.opacity(0.35), lineWidth: 1)
        }
        .clipShape(Capsule())
    }

    /// The hero portrait with seamless alpha gradient mask and color-matched blend
    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            // Ambient glow behind the portrait to harmonize lighting
            RadialGlow(
                color: AppColor.accentStart,
                opacity: 0.12,
                diameter: 380,
                falloff: 0.75
            )
            .offset(y: 10)

            Image(AppImage.haloPortrait)
                .resizable()
                .scaledToFill()
                .scaleEffect(0.70)
                .frame(height: 400)
                .frame(maxWidth: .infinity)
                .offset(y: 20)
                // 1. Harmonize photo color palette with app's dark navy/black gradient
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: AppColor.backgroundTop.opacity(0.35), location: 0.0),
                            .init(color: .clear, location: 0.25),
                            .init(color: .clear, location: 0.45),
                            .init(color: AppColor.backgroundMid.opacity(0.25), location: 0.65),
                            .init(color: AppColor.backgroundMid.opacity(0.90), location: 0.98),
                            .init(color: AppColor.backgroundMid, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .offset(y: 10)
                }
                // 2. Alpha mask: dissolves the image itself to 0% opacity at top & bottom edges
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .white, location: 0.10),
                            .init(color: .white, location: 0.45),
                            .init(color: .white.opacity(0.70), location: 0.65),
                            .init(color: .white.opacity(0.25), location: 0.82),
                            .init(color: .clear, location: 0.95)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .offset(y: 10)
                }
                .clipped()
        }
    }
}

#Preview("03 Halo Effect") {
    HaloEffectStepView {}
        .preferredColorScheme(.dark)
}
