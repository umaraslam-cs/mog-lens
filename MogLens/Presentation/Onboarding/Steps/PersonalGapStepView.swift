import SwiftUI

/// Onboarding — Personal Gap Step.
/// Compares the user's self-perception score against the objective on-device
/// geometric measurements to highlight the value of precise facial mapping.
struct PersonalGapStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        OnboardingScaffold(step: .personalGap, onContinue: onContinue) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xl) {
                    // 1. Headline (Centered 3-line impact title)
                    VStack(spacing: 2) {
                        Text(DesignContent.Onboarding.personalGapTitleAccent)
                            .font(AppFont.system(28, .heavy))
                            .foregroundStyle(AppColor.accentStart)

                        Text(DesignContent.Onboarding.personalGapTitleMid)
                            .font(AppFont.system(28, .heavy))
                            .foregroundStyle(Color.white)

                        Text(DesignContent.Onboarding.personalGapTitleEnd)
                            .font(AppFont.system(28, .heavy))
                            .foregroundStyle(Color.white)
                    }
                    .tracking(-0.4)
                    .lineHeight(1.15, size: 28)
                    .multilineTextAlignment(.center)
                    .padding(.top, 56)
                    .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                    // 2. Comparison Cards Side by Side
                    HStack(spacing: Spacing.m) {
                        leftSelfReportedCard
                        rightMeasuredCard
                    }
                    .padding(.horizontal, Layout.horizontal)
                    .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)

                    // 3. Supporting Body Copy
                    Text(DesignContent.Onboarding.personalGapBody)
                        .font(AppFont.system(16))
                        .lineHeight(1.42, size: 16)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.horizontal, Layout.horizontal + 4)
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

    /// Left Card: User's self-reported score with portrait background and accent active border
    private var leftSelfReportedCard: some View {
        VStack(spacing: 0) {
            // Main visual area with portrait background
            ZStack {
                Image(AppImage.personalGapPortrait)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 170)
                    .clipped()
                    .overlay(Color.black.opacity(0.38))

                VStack(spacing: Spacing.xs) {
                    Text("\(viewModel.selfRating)/10")
                        .font(AppFont.system(32, .bold))
                        .foregroundStyle(Color.white)
                        .shadow(color: Color.black.opacity(0.8), radius: 4)

                    Text(DesignContent.Onboarding.personalGapSelfReported)
                        .font(AppFont.mono(10, .semibold))
                        .tracking(0.8)
                        .foregroundStyle(Color.white.opacity(0.85))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.black.opacity(0.60)))
                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 170)

            // Bottom Caption
            VStack {
                Text(DesignContent.Onboarding.personalGapLeftCaption)
                    .font(AppFont.system(11, .bold))
                    .tracking(0.8)
                    .lineHeight(1.2, size: 11)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white.opacity(0.90))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(AppColor.panelInk)
        }
        .frame(height: 228)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(AppColor.accentStart, lineWidth: 2)
        }
        .shadow(color: AppColor.accentStart.opacity(0.20), radius: 8, x: 0, y: 2)
    }

    /// Right Card: Mysterious locked metric card representing objective scan analysis
    private var rightMeasuredCard: some View {
        VStack(spacing: 0) {
            // Main visual area with lock icon and ?? score
            ZStack {
                RadialGlow(
                    color: AppColor.accentStart,
                    opacity: 0.12,
                    diameter: 140,
                    falloff: 0.75
                )

                VStack(spacing: Spacing.xs) {
                    ZStack {
                        Circle()
                            .fill(AppColor.accentStart.opacity(0.15))
                            .frame(width: 40, height: 40)
                            .overlay(Circle().strokeBorder(AppColor.accentStart.opacity(0.35), lineWidth: 1))

                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColor.accentStart)
                    }

                    Text("??")
                        .font(AppFont.system(32, .heavy))
                        .tracking(1.0)
                        .foregroundStyle(AppColor.accentStart)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 170)
            .background(AppColor.panel)

            // Bottom Caption
            VStack {
                Text(DesignContent.Onboarding.personalGapRightCaption)
                    .font(AppFont.system(11, .bold))
                    .tracking(0.8)
                    .lineHeight(1.2, size: 11)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(AppColor.panelInk)
        }
        .frame(height: 228)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        }
    }
}

#Preview("Personal Gap") {
    PersonalGapStepView(viewModel: OnboardingViewModel(), onContinue: {})
        .preferredColorScheme(.dark)
}
