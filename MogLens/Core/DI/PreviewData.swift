import Foundation

/// Fixtures for SwiftUI previews. Keeps `#Preview` blocks free of setup noise.
enum PreviewData {
    /// Unlocked, so previews of the gated screens render their content rather
    /// than the paywall.
    static let dependencies = AppDependencies(
        subscriptionRepository: StaticSubscriptionRepository(subscribed: true)
    )
    static let emptyDependencies = AppDependencies.empty
    /// Locked, for the paywall preview — the unlocked configuration would send
    /// it straight back out again.
    static let lockedDependencies = AppDependencies(
        subscriptionRepository: StaticSubscriptionRepository(subscribed: false)
    )

    static let latestScan = SampleScans.latest
    static let previousScan = SampleScans.previous
    static let history = SampleScans.history

    static let recommendations = DesignContent.Improve.recommendations
    static let priorityFocus = DesignContent.Improve.lowerThirdFocus
    static let advice = latestScan.metrics
        .sorted { $0.percentile < $1.percentile }
        .map { MetricAdviceContent.advice(for: $0.kind, rating: $0.rating) }
    static let benefits = DesignContent.Paywall.benefits

    /// A router that has been through onboarding, so previews of Results and the
    /// paywall show the target line rather than omitting it.
    static var routerWithTarget: AppRouter {
        let router = AppRouter()
        router.onboardingDidFinish(with: OnboardingAnswers(targetRank: .chad))
        return router
    }
}
