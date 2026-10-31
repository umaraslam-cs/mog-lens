import SwiftUI

/// Self Rating onboarding step.
/// Prompts the user to self-assess their facial perception from 1 to 10
/// using an interactive step slider with tactile haptic response.
struct SelfRatingStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        OnboardingScaffold(step: .selfRating, onContinue: onContinue) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xl) {
                    // 1. Header Section (Consistent with Discover Face and other onboarding screens)
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        EyebrowLabel(text: DesignContent.Onboarding.selfRatingEyebrow)
                            .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(DesignContent.Onboarding.selfRatingTitleLead)
                                .font(AppFont.system(26, .bold))
                                .tracking(-0.4)
                                .foregroundStyle(Color.white)

                            (
                                Text(DesignContent.Onboarding.selfRatingTitleMid)
                                    .foregroundStyle(Color.white)
                                + Text(DesignContent.Onboarding.selfRatingTitleAccent)
                                    .foregroundStyle(AppColor.accentStart)
                                + Text(DesignContent.Onboarding.selfRatingTitleEnd)
                                    .foregroundStyle(Color.white)
                            )
                            .font(AppFont.system(26, .bold))
                            .tracking(-0.4)

                            Text(DesignContent.Onboarding.selfRatingTitleBottom)
                                .font(AppFont.system(26, .bold))
                                .tracking(-0.4)
                                .foregroundStyle(Color.white)
                        }
                        .lineHeight(1.12, size: 26)
                        .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                        .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 56)

                    Spacer(minLength: 10)

                    // 2. Score Perception Display Box
                    VStack(spacing: Spacing.s) {
                        Text(DesignContent.Onboarding.selfRatingPerceptionLabel)
                            .font(AppFont.eyebrow)
                            .tracking(Tracking.eyebrow)
                            .foregroundStyle(AppColor.textSecondary)

                        ZStack(alignment: .bottom) {
                            // Ambient glow pod underneath the box
                            Capsule()
                                .fill(AppColor.accentStart)
                                .frame(width: 54, height: 4)
                                .blur(radius: 5)
                                .opacity(0.85)
                                .offset(y: 8)

                            // Main perception box
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                Text("\(viewModel.selfRating)")
                                    .font(AppFont.heroScore)
                                    .tracking(Tracking.heroScore)
                                    .foregroundStyle(AppColor.accentStart)
                                    .contentTransition(.numericText())

                                Text(DesignContent.Onboarding.selfRatingScoreDenominator)
                                    .font(AppFont.headline)
                                    .foregroundStyle(AppColor.textSecondary)
                                    .padding(.bottom, 12)
                            }
                            .frame(width: 140, height: 100)
                            .background {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color(hex: 0x0A141D).opacity(0.85))
                                    .background(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .fill(AppColor.surface)
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .strokeBorder(
                                                LinearGradient(
                                                    stops: [
                                                        .init(color: Color.white.opacity(0.18), location: 0),
                                                        .init(color: AppColor.accentStart.opacity(0.25), location: 0.3),
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
                    .staggeredAppear(hasAppeared, index: 2, reduceMotion: reduceMotion)

                    // 3. Interactive Step Slider Card
                    SelfRatingSlider(rating: $viewModel.selfRating)
                        .staggeredAppear(hasAppeared, index: 3, reduceMotion: reduceMotion)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, Layout.horizontal)
                .padding(.bottom, Layout.bottomCTAInset + 80)
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }
}

#Preview("Self Rating Step") {
    SelfRatingStepView(viewModel: OnboardingViewModel(), onContinue: {})
        .preferredColorScheme(.dark)
}
