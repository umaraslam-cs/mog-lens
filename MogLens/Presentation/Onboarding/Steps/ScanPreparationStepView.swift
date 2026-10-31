import SwiftUI
import UIKit

/// Onboarding — Scan Preparation Step ("WE'RE READY / Let's meet your face.").
/// Instructs the user on camera orientation, lighting, and facial expression before starting the scan.
struct ScanPreparationStepView: View {
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    private let tips = DesignContent.Onboarding.scanPrepTips

    var body: some View {
        OnboardingScaffold(step: .scanPreparation, onContinue: onContinue) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.l) {
                    // 1. Top Biometric Wireframe Head Visual
                    wireframeHeroVisual
                        .padding(.top, 50)
                        .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                    // 2. Header Block
                    VStack(spacing: Spacing.s) {
                        // Eyebrow
                        Text(DesignContent.Onboarding.scanPrepEyebrow)
                            .font(AppFont.mono(11, .bold))
                            .tracking(1.4)
                            .foregroundStyle(AppColor.accentStart)

                        // 2-Line Headline
                        VStack(spacing: 2) {
                            Text(DesignContent.Onboarding.scanPrepTitleLead)
                            Text(DesignContent.Onboarding.scanPrepTitleEnd)
                        }
                        .font(AppFont.system(32, .heavy))
                        .tracking(-0.5)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .lineHeight(1.15, size: 32)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white)
                        .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)

                        // Subtitle
                        Text(DesignContent.Onboarding.scanPrepSubtitle)
                            .font(AppFont.system(15))
                            .lineHeight(1.38, size: 15)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .padding(.horizontal, Layout.horizontal)
                    .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)

                    // 3. 3 Guideline Cards List
                    VStack(spacing: Spacing.m) {
                        ForEach(tips) { tip in
                            tipRow(for: tip)
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

    /// Top holographic wireframe face graphic with ambient spotlight glow
    private var wireframeHeroVisual: some View {
        ZStack {
            // Ambient Cyan Glow
            RadialGlow(
                color: AppColor.accentStart,
                opacity: 0.16,
                diameter: 260,
                falloff: 0.75
            )

            LoopedVideoPlayer(resourceName: "futureself", playbackRate: 1.4)
                .frame(width: 250, height: 250)
                .clipShape(Circle())
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
    }

    /// Guideline instruction card
    private func tipRow(for tip: ScanPreparationTip) -> some View {
        HStack(spacing: Spacing.m) {
            // Left SF Symbol Icon
            Image(systemName: tip.symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColor.accentStart)
                .frame(width: 28, height: 28)

            // Title + Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(tip.title)
                    .font(AppFont.system(15, .bold))
                    .foregroundStyle(Color.white)

                Text(tip.subtitle)
                    .font(AppFont.system(13, .regular))
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColor.panel.opacity(0.85))
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColor.surface)
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}

#Preview("Scan Preparation") {
    ScanPreparationStepView(onContinue: {})
        .preferredColorScheme(.dark)
}
