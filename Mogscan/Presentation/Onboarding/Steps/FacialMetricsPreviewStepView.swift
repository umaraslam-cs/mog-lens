import SwiftUI
import UIKit

/// Onboarding — Facial Metrics Preview Step ("Your Face Has More Data Than a Mirror Shows").
/// Teases the 8 core locked biometric dimensions with 1-line looksmaxing details in a 2-column grid,
/// alongside an animated geometric scanning radar graphic.
struct FacialMetricsPreviewStepView: View {
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false
    @State private var isRotating = false

    private let teasers = DesignContent.Onboarding.metricsPreviewTeasers

    var body: some View {
        OnboardingScaffold(step: .facialMetricsPreview, onContinue: onContinue) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.l) {
                    // 1. Header Section
                    VStack(spacing: Spacing.s) {
                        // 2-Line Impact Headline
                        VStack(spacing: 2) {
                            Text(DesignContent.Onboarding.metricsPreviewTitleLead)
                            Text(DesignContent.Onboarding.metricsPreviewTitleEnd)
                        }
                        .font(AppFont.system(26, .heavy))
                        .tracking(-0.4)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .lineHeight(1.15, size: 26)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white)
                        .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)

                        // Subtitle
                        Text(DesignContent.Onboarding.metricsPreviewBody)
                            .font(AppFont.system(15))
                            .lineHeight(1.38, size: 15)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppColor.textSecondary)
                            .padding(.horizontal, Layout.horizontal + 1)
                    }
                    .padding(.top, 56)
                    .padding(.horizontal, Layout.horizontal + 5)
                    .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                    // 2. Biometric Scanning Radar Graphic
                    radarScanningGraphic
                        .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)

                    // 3. 2 Cards Per Row Grid with 1-Line Looksmaxing Details
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: Spacing.m),
                            GridItem(.flexible(), spacing: Spacing.m)
                        ],
                        spacing: Spacing.m
                    ) {
                        ForEach(Array(teasers.enumerated()), id: \.element.id) { index, teaser in
                            metricTeaserCard(for: teaser)
                                .staggeredAppear(hasAppeared, index: 2 + index, reduceMotion: reduceMotion)
                        }
                    }
                    .padding(.horizontal, Layout.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.bottom, Layout.bottomCTAInset + 80)
            }
        }
        .onAppear {
            hasAppeared = true
            if !reduceMotion {
                withAnimation(.linear(duration: 24).repeatForever(autoreverses: false)) {
                    isRotating = true
                }
            }
        }
    }

    /// Center circular biometric scanning radar with glowing dashed lines and facial metrics preview portrait
    private var radarScanningGraphic: some View {
        ZStack {
            // Ambient Cyan Glow
            RadialGlow(
                color: AppColor.accentStart,
                opacity: 0.20,
                diameter: 240,
                falloff: 0.75
            )

            // Outer Dashed Geometric Ring
            Circle()
                .stroke(
                    AppColor.accentStart.opacity(0.75),
                    style: StrokeStyle(lineWidth: 1.5, dash: [4, 7])
                )
                .frame(width: 195, height: 195)
                .rotationEffect(.degrees(isRotating ? 360 : 0))

            // Outer hairline ring
            Circle()
                .strokeBorder(AppColor.accentStart.opacity(0.18), lineWidth: 1)
                .frame(width: 208, height: 208)

            // Circular Biometric Landmark Portrait Image
            Image(AppImage.facialMetricsPreview)
                .resizable()
                .scaledToFill()
                .frame(width: 175, height: 175)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(AppColor.accentStart.opacity(0.40), lineWidth: 1.5)
                }
                .shadow(color: AppColor.accentStart.opacity(0.30), radius: 10, x: 0, y: 2)
        }
        .frame(height: 215)
    }

    /// Individual locked biometric teaser card (2 per row, with 1-line looksmaxing detail)
    private func metricTeaserCard(for teaser: FacialMetricTeaser) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Top Row: Metric Icon + Lock Badge
            HStack {
                Image(systemName: teaser.symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColor.accentStart)

                Spacer()

                Image(systemName: "lock.fill")
                    .font(.system(size: 11.5, weight: .regular))
                    .foregroundStyle(AppColor.accentStart.opacity(0.50))
            }

            // Metric Name
            Text(teaser.title)
                .font(AppFont.system(12, .bold))
                .tracking(Tracking.label)
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            // 2-Line Looksmaxing Detail
            Text(teaser.detail)
                .font(AppFont.system(11, .regular))
                .lineHeight(1.28, size: 11)
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .frame(minHeight: 28, alignment: .topLeading)

            // Locked Blurred Value Indicator
            Text(teaser.value)
                .font(AppFont.mono(13, .semibold))
                .foregroundStyle(Color.white.opacity(0.45))
                .blur(radius: 3.5)
                .lineLimit(1)
                .padding(.top, 2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 124, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: 0x0A141D).opacity(0.85))
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColor.surface)
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.14), location: 0),
                            .init(color: AppColor.accentStart.opacity(0.20), location: 0.3),
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

#Preview("Facial Metrics Preview") {
    FacialMetricsPreviewStepView(onContinue: {})
        .preferredColorScheme(.dark)
}
