import Foundation

/// Results state. Only ever populated for an unlocked scan.
@Observable
final class ResultsViewModel {
    let scan: FaceScan

    /// Advice for the weakest metrics, in the order they should be worked on.
    private(set) var advice: [MetricAdvice] = []

    private let fetchAdvice: FetchMetricAdviceUseCaseProtocol

    /// How many advice cards the report carries.
    ///
    /// Two, not five: the client asked that the unlocked report not read as a
    /// bare number, not that it become the plan. Improve is the full list, and
    /// the CTA under these cards is what leads there.
    private static let adviceCount = 2

    init(scan: FaceScan, fetchAdvice: FetchMetricAdviceUseCaseProtocol) {
        self.scan = scan
        self.fetchAdvice = fetchAdvice
    }

    convenience init(scan: FaceScan, dependencies: AppDependencies) {
        self.init(scan: scan, fetchAdvice: dependencies.fetchMetricAdvice)
    }

    func load() {
        advice = Array(fetchAdvice(for: scan.metrics).prefix(Self.adviceCount))
    }

    var metrics: [FacialMetric] { scan.metrics }

    /// Caption comparing the scored tier against the one picked in onboarding.
    /// Nil when there is no target — onboarding was skipped, or this scan was
    /// opened from Home on a launch that never ran it.
    func targetReachedCaption(_ target: FacialTier?) -> String? {
        guard let target, hasReachedTarget(target) else { return nil }
        return scan.tier > target
            ? DesignContent.Results.targetPassed(target.displayName)
            : DesignContent.Results.targetReached(target.displayName)
    }

    /// Whether the user is at *or above* the tier they were training toward.
    ///
    /// Comparison, not equality: scoring Chad Lite against a HTN target is the
    /// target met, and drawing it as a current → target pair pointed at a tier
    /// below the one just scored read as a bug.
    func hasReachedTarget(_ target: FacialTier?) -> Bool {
        guard let target else { return false }
        return scan.tier >= target
    }

    /// Bars fill 0.5s with a 0.06s stagger down the list.
    func delay(for index: Int) -> Double {
        Double(index) * AppMotion.barStagger
    }
}
