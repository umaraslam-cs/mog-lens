import Foundation

/// Drives the onboarding flow and holds the answers it collects.
@Observable
final class OnboardingViewModel {
    private(set) var step: OnboardingStep = .discoverFace

    /// Facial ratios are benchmarked against this age group.
    var age: AgeOption = .default
    /// The tier the user is training toward.
    var targetRank: FacialTier = .htn
    /// The user's self-assessed perception rating (1...10).
    var selfRating: Int = 6
    /// The user's target aesthetic goal archetype.
    var desiredGoal: GoalArchetype = .defined
    /// The user's selected improvement focus areas.
    var focusAreas: Set<ImprovementArea> = [.jawline]

    let ageOptions = AgeOption.all
    let tiers = FacialTier.allCases
    let goals: [GoalArchetype] = [.defined, .balanced, .refined, .highImpact]
    let allFocusAreas = ImprovementArea.allCases

    /// The answers the flow exists to collect.
    var answers: OnboardingAnswers {
        OnboardingAnswers(
            targetRank: targetRank,
            selfRating: selfRating,
            desiredGoal: desiredGoal,
            focusAreas: focusAreas
        )
    }

    /// CTA label for the current step.
    var ctaTitle: String {
        switch step {
        case .desiredResult: DesignContent.Onboarding.desiredResultCTA
        case .targetRank: DesignContent.Onboarding.targetRankCTA
        case .technology: DesignContent.Onboarding.technologyCTA
        case .socialProof: DesignContent.Onboarding.socialProofCTA
        default: DesignContent.Onboarding.continueTitle
        }
    }

    /// Advances one step; returns `true` once the flow is complete.
    @discardableResult
    func advance() -> Bool {
        guard let next = step.next else { return true }
        step = next
        return false
    }

    func goBack() {
        guard let previous = step.previous else { return }
        step = previous
    }
}
