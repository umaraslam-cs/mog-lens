import Foundation

/// What onboarding hands back.
///
/// One answer today, and still a named type rather than a bare `FacialTier`:
/// the flow's output is a thing worth naming, so adding a second question later
/// touches this type rather than every signature between the flow and the router.
struct OnboardingAnswers: Hashable {
    let targetRank: FacialTier
    var selfRating: Int? = 6
    var desiredGoal: GoalArchetype? = .balanced
    var focusAreas: Set<ImprovementArea> = [.jawline]
}
