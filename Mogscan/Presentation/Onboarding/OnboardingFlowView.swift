import SwiftUI

/// 02–07 — the onboarding flow. Steps slide in with a 0.25s opacity cross-fade.
///
/// Six steps, ending on the technology screen — the last thing before the
/// camera opens.
struct OnboardingFlowView: View {
    @State private var viewModel = OnboardingViewModel()
    /// Carries the answers the flow collected — its one lasting output.
    let onFinish: (OnboardingAnswers) -> Void

    var body: some View {
        ZStack {
            AppBackground()

            Group {
                switch viewModel.step {
                case .discoverFace:
                    DiscoverFaceStepView(onContinue: advance)
                case .haloEffect:
                    HaloEffectStepView(onContinue: advance)
                case .whyItMatters:
                    WhyItMattersStepView(onContinue: advance)
                case .selfRating:
                    SelfRatingStepView(viewModel: viewModel, onContinue: advance)
                case .personalGap:
                    PersonalGapStepView(viewModel: viewModel, onContinue: advance)
                case .futureSelf:
                    FutureSelfStepView(onContinue: advance)
                case .desiredResult:
                    DesiredResultStepView(viewModel: viewModel, onContinue: advance)
                case .biggestConcern:
                    BiggestConcernStepView(viewModel: viewModel, onContinue: advance)
                case .age:
                    AgeStepView(viewModel: viewModel, onContinue: advance)
                case .technology:
                    TechnologyStepView(onContinue: advance)
                case .facialMetricsPreview:
                    FacialMetricsPreviewStepView(onContinue: advance)
                case .scanPreparation:
                    ScanPreparationStepView(onContinue: advance)
                case .targetRank:
                    TargetRankStepView(viewModel: viewModel, onContinue: advance)
                case .socialProof:
                    SocialProofStepView(onBack: viewModel.goBack, onContinue: advance)
                }
            }
            .transition(
                .asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                )
            )
        }
        .animation(AppMotion.stepTransition, value: viewModel.step)
    }

    private func advance() {
        if viewModel.advance() {
            onFinish(viewModel.answers)
        }
    }
}

#Preview("Onboarding flow") {
    OnboardingFlowView { _ in }
}
