import Foundation

/// Improve tab state.
///
/// Two lists, both hand-written and neither generated. The metric advice is the
/// client's lookup table, one card per metric, weakest first — the same cards
/// the unlocked report shows the top two of. Under it sit the general habit
/// cards, whose only dynamic behaviour is sort order: the category tied to the
/// lowest-percentile metric floats to the top, and the priority banner names
/// that region.
@Observable
final class ImproveViewModel {
    private(set) var advice: [MetricAdvice] = []
    private(set) var recommendations: [Recommendation] = []
    private(set) var priorityFocus: PriorityFocus?
    private(set) var latestScan: FaceScan?

    /// Whether measured content may be shown. The advice list is ordered
    /// weakest-metric-first and the priority banner names that region, so both
    /// are result values in everything but presentation — they sit behind the
    /// same paywall Home and Results do.
    private(set) var isSubscribed = false

    private let fetchLatestScan: FetchLatestScanUseCaseProtocol
    private let fetchRecommendations: FetchRecommendationsUseCaseProtocol
    private let fetchPriorityFocus: FetchPriorityFocusUseCaseProtocol
    private let fetchAdvice: FetchMetricAdviceUseCaseProtocol
    private let checkSubscription: CheckSubscriptionUseCaseProtocol
    private let refreshSubscription: RefreshEntitlementUseCaseProtocol

    init(
        fetchLatestScan: FetchLatestScanUseCaseProtocol,
        fetchRecommendations: FetchRecommendationsUseCaseProtocol,
        fetchPriorityFocus: FetchPriorityFocusUseCaseProtocol,
        fetchAdvice: FetchMetricAdviceUseCaseProtocol,
        checkSubscription: CheckSubscriptionUseCaseProtocol,
        refreshSubscription: RefreshEntitlementUseCaseProtocol
    ) {
        self.fetchLatestScan = fetchLatestScan
        self.fetchRecommendations = fetchRecommendations
        self.fetchPriorityFocus = fetchPriorityFocus
        self.fetchAdvice = fetchAdvice
        self.checkSubscription = checkSubscription
        self.refreshSubscription = refreshSubscription
    }

    convenience init(dependencies: AppDependencies) {
        self.init(
            fetchLatestScan: dependencies.fetchLatestScan,
            fetchRecommendations: dependencies.fetchRecommendations,
            fetchPriorityFocus: dependencies.fetchPriorityFocus,
            fetchAdvice: dependencies.fetchMetricAdvice,
            checkSubscription: dependencies.checkSubscription,
            refreshSubscription: dependencies.refreshEntitlement
        )
    }

    /// True once a scan exists that this device has not paid to see.
    var isLocked: Bool { latestScan != nil && !isSubscribed }

    func load() {
        isSubscribed = checkSubscription()
        latestScan = fetchLatestScan()
        // Nothing measured is read while locked: the weakest-first ordering is
        // itself a result, so it is not computed rather than merely hidden.
        let scan = isLocked ? nil : latestScan
        advice = fetchAdvice(for: scan?.metrics ?? [])
        recommendations = fetchRecommendations(prioritising: scan)
        priorityFocus = fetchPriorityFocus(for: scan)
    }

    /// Re-reads entitlement from the store, then reloads what may be shown.
    func refreshEntitlement() async {
        isSubscribed = await refreshSubscription()
        load()
    }

    /// e.g. "Based on your scan of 12 Mar.". Withheld while locked — the date
    /// of a scan is harmless, but the line reads as a report header.
    var subtitle: String? {
        guard let latestScan, !isLocked else { return nil }
        return DesignContent.Improve.subtitle(dateText: ScanDateFormatter.short(latestScan.capturedAt))
    }
}
