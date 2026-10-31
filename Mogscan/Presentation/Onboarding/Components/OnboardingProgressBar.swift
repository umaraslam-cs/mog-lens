import SwiftUI

/// Six 3pt segments across the top of every onboarding step. Completed segments
/// carry the accent ramp; the rest are white at 12%.
struct OnboardingProgressBar: View {
    let currentStep: Int
    var totalSteps: Int = OnboardingStep.totalSteps

    var body: some View {
        HStack(spacing: Spacing.xxsPlus) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(segmentStyle(at: index))
                    .frame(height: 3)
            }
        }
        .animation(AppMotion.stepTransition, value: currentStep)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(currentStep) of \(totalSteps)")
    }

    private func segmentStyle(at index: Int) -> AnyShapeStyle {
        index < currentStep
            ? AnyShapeStyle(AppGradient.accentHorizontal)
            : AnyShapeStyle(Color.white.opacity(0.12))
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.section) {
            ForEach(1...6, id: \.self) { OnboardingProgressBar(currentStep: $0) }
        }
        .padding(Layout.horizontal)
    }
}
