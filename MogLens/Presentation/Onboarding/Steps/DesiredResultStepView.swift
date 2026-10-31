import SwiftUI
import UIKit

/// Onboarding — Desired Result / Target Architecture Step.
/// Prompts the user to pick their desired aesthetic goal archetype via clean, text-only option boxes:
/// 2 in a row for Defined, Balanced, Refined, and High Impact; plus 1 full-width row for "Not Sure Yet".
struct DesiredResultStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        OnboardingScaffold(
            step: .desiredResult,
            ctaTitle: DesignContent.Onboarding.desiredResultCTA,
            onContinue: onContinue
        ) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 1. Header Section
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        EyebrowLabel(text: DesignContent.Onboarding.desiredResultEyebrow)

                        Text(DesignContent.Onboarding.desiredResultTitle)
                            .font(AppFont.screenTitle)
                            .tracking(Tracking.screenTitle)
                            .lineHeight(1.15, size: 32)
                            .foregroundStyle(Color.white)
                            .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Layout.horizontal)
                    .padding(.top, 56)
                    .padding(.bottom, 32)
                    .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                    // 2. 2 in a row Grid: Defined, Balanced, Refined, High Impact
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: Spacing.m),
                            GridItem(.flexible(), spacing: Spacing.m)
                        ],
                        spacing: Spacing.m
                    ) {
                        ForEach(viewModel.goals) { goal in
                            archetypeGridBox(for: goal)
                        }
                    }
                    .padding(.horizontal, Layout.horizontal)
                    .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)

                    // 3. 1 in a row: "Not Sure Yet"
                    notSureYetRow
                        .padding(.horizontal, Layout.horizontal)
                        .padding(.top, Spacing.m)
                        .staggeredAppear(hasAppeared, index: 2, reduceMotion: reduceMotion)

                    Spacer(minLength: 24)
                }
                .padding(.bottom, Layout.bottomCTAInset + 80)
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }

    /// Clean, text-only box for a 2-in-a-row grid archetype (Defined, Balanced, Refined, High Impact)
    private func archetypeGridBox(for goal: GoalArchetype) -> some View {
        let isSelected = viewModel.desiredGoal == goal

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.desiredGoal = goal
            }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    Text(goal.title)
                        .font(AppFont.system(15, .bold))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)

                    Spacer(minLength: 4)

                    ZStack {
                        Circle()
                            .strokeBorder(
                                isSelected ? AppColor.accentStart : Color.white.opacity(0.20),
                                lineWidth: 2
                            )
                            .frame(width: 20, height: 20)

                        if isSelected {
                            Circle()
                                .fill(AppColor.accentStart)
                                .frame(width: 9, height: 9)
                        }
                    }
                }

                Text(goal.subtitle)
                    .font(AppFont.system(12, .regular))
                    .foregroundStyle(AppColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
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
                        isSelected ? AppColor.accentStart : Color.white.opacity(0.10),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
            .shadow(
                color: isSelected ? AppColor.accentStart.opacity(0.25) : Color.clear,
                radius: 10,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
    }

    /// Single full-width row for "Not Sure Yet"
    private var notSureYetRow: some View {
        let isSelected = viewModel.desiredGoal == .notSureYet

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                viewModel.desiredGoal = .notSureYet
            }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } label: {
            HStack(spacing: Spacing.m) {
                // Left Icon Badge
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 40, height: 40)
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

                    Image(systemName: "sparkle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? AppColor.accentStart : Color.white.opacity(0.85))
                }

                // Title + Description
                VStack(alignment: .leading, spacing: 3) {
                    Text(GoalArchetype.notSureYet.title)
                        .font(AppFont.system(15, .bold))
                        .foregroundStyle(Color.white)

                    Text(GoalArchetype.notSureYet.subtitle)
                        .font(AppFont.system(12, .regular))
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: 12)

                // Radio Button Indicator
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? AppColor.accentStart : Color.white.opacity(0.20),
                            lineWidth: 2
                        )
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(AppColor.accentStart)
                            .frame(width: 9, height: 9)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
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
                        isSelected ? AppColor.accentStart : Color.white.opacity(0.10),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
            .shadow(
                color: isSelected ? AppColor.accentStart.opacity(0.25) : Color.clear,
                radius: 10,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Desired Result") {
    DesiredResultStepView(viewModel: OnboardingViewModel(), onContinue: {})
        .preferredColorScheme(.dark)
}
