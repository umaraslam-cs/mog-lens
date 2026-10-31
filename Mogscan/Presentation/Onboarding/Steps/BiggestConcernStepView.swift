import SwiftUI
import UIKit

/// Onboarding — Biggest Concern / Focus Areas Step.
/// Prompts the user to multi-select areas of facial aesthetic focus (2x4 grid)
/// to personalize their geometric scan report.
struct BiggestConcernStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        OnboardingScaffold(step: .biggestConcern, onContinue: onContinue) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xl) {
                    // 1. Header Section
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text(DesignContent.Onboarding.concernTitle)
                            .font(AppFont.system(26, .heavy))
                            .tracking(-0.3)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                            .lineHeight(1.15, size: 26)
                            .foregroundStyle(Color.white)
                            .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)

                        Text(DesignContent.Onboarding.concernSubtitle)
                            .font(AppFont.system(15))
                            .lineHeight(1.4, size: 15)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Layout.horizontal)
                    .padding(.top, 56)
                    .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                    // 2. 2x4 Improvement Areas Grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: Spacing.m),
                            GridItem(.flexible(), spacing: Spacing.m)
                        ],
                        spacing: Spacing.m
                    ) {
                        ForEach(viewModel.allFocusAreas) { area in
                            focusAreaTile(for: area)
                        }
                    }
                    .padding(.horizontal, Layout.horizontal)
                    .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)

                    Spacer(minLength: 20)
                }
                .padding(.bottom, Layout.bottomCTAInset + 80)
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }

    /// Interactive focus area tile with contextual icon and tactile selection state
    private func focusAreaTile(for area: ImprovementArea) -> some View {
        let isSelected = viewModel.focusAreas.contains(area)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                toggleArea(area)
            }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } label: {
            VStack(spacing: Spacing.s) {
                // Contextual SF Symbol matching biometric / geometry theme
                Image(systemName: area.symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(isSelected ? AppColor.accentStart : Color.white.opacity(0.90))

                Text(area.title)
                    .font(AppFont.system(12, .bold))
                    .tracking(Tracking.label)
                    .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: 0x0A141D).opacity(0.85))
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(AppColor.surface)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        isSelected ? AppColor.accentStart : Color.white.opacity(0.10),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .shadow(
                color: isSelected ? AppColor.accentStart.opacity(0.28) : Color.clear,
                radius: 10,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
    }

    private func toggleArea(_ area: ImprovementArea) {
        if area == .notSure {
            viewModel.focusAreas = [.notSure]
            return
        }

        viewModel.focusAreas.remove(.notSure)
        if viewModel.focusAreas.contains(area) {
            // Keep at least one area selected if possible
            if viewModel.focusAreas.count > 1 {
                viewModel.focusAreas.remove(area)
            }
        } else {
            viewModel.focusAreas.insert(area)
        }
    }
}

#Preview("Biggest Concern") {
    BiggestConcernStepView(viewModel: OnboardingViewModel(), onContinue: {})
        .preferredColorScheme(.dark)
}
