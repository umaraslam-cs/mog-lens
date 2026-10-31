import SwiftUI

/// 05 — Target Rank. Same wheel component as the age step with an accent-tinted
/// selection band; the selected row animates up in weight.
struct TargetRankStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        OnboardingScaffold(
            step: .targetRank,
            ctaTitle: DesignContent.Onboarding.targetRankCTA,
            onContinue: onContinue
        ) { slot in
            DesignOffsetStack(offsets: [56, 242, 508], available: slot) {
                OnboardingHeadline(
                    title: DesignContent.Onboarding.targetRankTitle,
                    subtitle: DesignContent.Onboarding.targetRankSubtitle
                )
                .padding(.horizontal, Layout.horizontal)

                WheelPicker(
                    items: viewModel.tiers,
                    selection: $viewModel.targetRank,
                    appearance: .targetRank
                ) { $0.displayName }
                    .padding(.horizontal, Layout.horizontal)
                    .accessibilityLabel(DesignContent.Onboarding.targetRankTitle)

                InfoBanner(
                    symbol: AppSymbol.info,
                    title: DesignContent.Onboarding.targetRankNote
                )
                .padding(.horizontal, Layout.horizontal)
            }
        }
    }
}

#Preview("05 Target Rank") {
    TargetRankStepView(viewModel: OnboardingViewModel(), onContinue: {})
}
