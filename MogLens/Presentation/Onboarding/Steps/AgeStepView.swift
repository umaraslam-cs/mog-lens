import SwiftUI

/// 02 — Onboarding, Age. Native wheel selection with a `.selection` haptic on
/// each detent; Continue is 54pt tall, above the 44pt minimum.
struct AgeStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        OnboardingScaffold(step: .age, onContinue: onContinue) { slot in
            DesignOffsetStack(offsets: [56, 226], available: slot) {
                OnboardingHeadline(
                    title: DesignContent.Onboarding.ageTitle,
                    subtitle: DesignContent.Onboarding.ageSubtitle
                )
                .padding(.horizontal, Layout.horizontal)

                WheelPicker(
                    items: viewModel.ageOptions,
                    selection: $viewModel.age,
                    appearance: .age
                ) { "\($0.years)" }
                    .padding(.horizontal, Layout.horizontal)
                    .accessibilityLabel(DesignContent.Onboarding.ageTitle)
            }
        }
    }
}

#Preview("02 Age") {
    AgeStepView(viewModel: OnboardingViewModel(), onContinue: {})
}
