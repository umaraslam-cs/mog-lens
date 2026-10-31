import SwiftUI

/// Onboarding — Future Self Step.
/// Features a holographic 3D biometric wireframe mesh, high-impact typography,
/// and a nodal telemetry callout card.
struct FutureSelfStepView: View {
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        OnboardingScaffold(step: .futureSelf, onContinue: onContinue) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.l) {
                    // 1. Hero 3D Biometric Mesh with Spotlight Ambient Glow
                    heroVisual
                        .padding(.top, 16)
                        .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                    // 2. Main Typography Block
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        EyebrowLabel(text: DesignContent.Onboarding.futureSelfEyebrow)

                        (
                            Text(DesignContent.Onboarding.futureSelfTitleLead)
                                .foregroundStyle(Color.white)
                            + Text(DesignContent.Onboarding.futureSelfTitleAccent)
                                .foregroundStyle(AppColor.accentStart)
                        )
                        .font(AppFont.screenTitle)
                        .tracking(Tracking.screenTitle)
                        .lineHeight(1.15, size: 32)
                        .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)

                        Text(DesignContent.Onboarding.futureSelfBody)
                            .font(AppFont.system(15.5))
                            .lineHeight(1.42, size: 15.5)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Layout.horizontal)
                    .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)

                    // 3. 128 Nodal Points Info Banner
                    nodalCalloutBanner
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

    /// Circular glowing viewport presenting the 3D wireframe mesh
    private var heroVisual: some View {
        ZStack {
            // Ambient cyan spotlight cone / glow
            RadialGlow(
                color: AppColor.accentStart,
                opacity: 0.18,
                diameter: 320,
                falloff: 0.75
            )

            // Circular framed hardware-accelerated 3D wireframe mesh video
            LoopedVideoPlayer(resourceName: "futureself", playbackRate: 1.4)
                .frame(width: 250, height: 250)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: AppColor.accentStart.opacity(0.40), location: 0),
                                    .init(color: Color.white.opacity(0.12), location: 0.5),
                                    .init(color: AppColor.accentStart.opacity(0.10), location: 1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                }
                .shadow(color: AppColor.accentStart.opacity(0.25), radius: 16)
        }
        .frame(height: 270)
        .frame(maxWidth: .infinity)
    }

    /// Glassmorphic nodal telemetry banner
    private var nodalCalloutBanner: some View {
        HStack(alignment: .center, spacing: Spacing.m) {
            // Concentric Target Icon
            ZStack {
                Circle()
                    .strokeBorder(AppColor.accentStart, lineWidth: 2)
                    .frame(width: 22, height: 22)

                Circle()
                    .fill(AppColor.accentStart)
                    .frame(width: 8, height: 8)
            }
            .frame(width: 28, height: 28)

            Text(DesignContent.Onboarding.futureSelfBannerText)
                .font(AppFont.system(14))
                .lineHeight(1.36, size: 14)
                .foregroundStyle(Color.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .fill(Color(hex: 0x0A141D).opacity(0.85))
                .background(
                    RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                        .fill(AppColor.surface)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.16), location: 0),
                                    .init(color: AppColor.accentStart.opacity(0.22), location: 0.25),
                                    .init(color: Color.white.opacity(0.04), location: 1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
    }
}

#Preview("Future Self") {
    FutureSelfStepView {}
        .preferredColorScheme(.dark)
}
