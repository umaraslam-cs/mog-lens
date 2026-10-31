import SwiftUI

/// Onboarding — Discover Face. A visually immersive hero portrait seamlessly blended
/// into the background gradient, with telemetry HUD accents and high-impact typography.
struct DiscoverFaceStepView: View {
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        OnboardingScaffold(step: .discoverFace, onContinue: onContinue) {
            ZStack(alignment: .top) {
                hero

                VStack(alignment: .leading, spacing: Spacing.m) {
                    EyebrowLabel(text: DesignContent.Onboarding.discoverEyebrow)
                        .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                    // High-contrast title matching reference layout
                    VStack(alignment: .leading, spacing: 1) {
                        Text(DesignContent.Onboarding.discoverTitleLead)
                            .font(AppFont.system(32, .bold))
                            .foregroundStyle(Color.white)

                        (
                            Text(DesignContent.Onboarding.discoverTitleAccent)
                                .foregroundStyle(AppColor.accentStart)
                            + Text(DesignContent.Onboarding.discoverTitleMid)
                                .foregroundStyle(Color.white)
                        )
                        .font(AppFont.system(32, .bold))

                        Text(DesignContent.Onboarding.discoverTitleEnd)
                            .font(AppFont.system(32, .bold))
                            .foregroundStyle(Color.white)
                    }
                    .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                    .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)

                    // Body copy
                    Text(DesignContent.Onboarding.discoverBody)
                        .font(AppFont.system(15))
                        .lineHeight(1.42, size: 15)
                        .foregroundStyle(AppColor.textSecondary)
                        .staggeredAppear(hasAppeared, index: 2, reduceMotion: reduceMotion)
                }
                .padding(.horizontal, Layout.horizontal)
                .padding(.top, 460)
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }

    /// The hero portrait with multi-stage gradient blending into the app background.
    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            // Ambient glow behind the portrait to harmonize lighting
            RadialGlow(
                color: AppColor.accentStart,
                opacity: 0.12,
                diameter: 400,
                falloff: 0.75
            )
            .offset(y: 20)

            Image(AppImage.discoverFacePortrait)
                .resizable()
                .scaledToFill()
                .frame(height: 520)
                .frame(maxWidth: .infinity)
                // 1. Harmonize photo color palette with app's dark navy/black gradient
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: AppColor.backgroundTop.opacity(0.35), location: 0.0),
                            .init(color: .clear, location: 0.25),
                            .init(color: .clear, location: 0.45),
                            .init(color: AppColor.backgroundMid.opacity(0.40), location: 0.65),
                            .init(color: AppColor.backgroundMid.opacity(0.85), location: 0.85),
                            .init(color: AppColor.backgroundMid, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                // 2. Alpha mask: dissolves the image itself to 0% opacity at top & bottom edges
                // so the underlying AppBackground() gradient shows through seamlessly without seams
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .white, location: 0.10),
                            .init(color: .white, location: 0.50),
                            .init(color: .white.opacity(0.85), location: 0.65),
                            .init(color: .white.opacity(0.40), location: 0.80),
                            .init(color: .clear, location: 0.95)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .clipped()

            // Biometric telemetry chip floating over the image
            HStack(spacing: Spacing.xs) {
                Circle()
                    .fill(AppColor.accentStart)
                    .frame(width: 6, height: 6)
                    .shadow(color: AppColor.accentStart.opacity(0.8), radius: 4)

                Text("PRECISION MAPPING")
                    .font(AppFont.mono(11, .medium))
                    .tracking(0.8)
                    .foregroundStyle(AppColor.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial.opacity(0.8))
            .overlay {
                Capsule()
                    .strokeBorder(AppColor.accentStart.opacity(0.3), lineWidth: 1)
            }
            .clipShape(Capsule())
            .padding(.trailing, Layout.horizontal)
            .padding(.top, 60)
            .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)
        }
    }
}

#Preview("Discover Face") {
    DiscoverFaceStepView {}
        .preferredColorScheme(.dark)
}
