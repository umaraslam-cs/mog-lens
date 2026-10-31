import Foundation

/// Reads scans from the local store. UI-only: backed by the design's sample set.
struct StaticScanRepository: ScanRepositoryProtocol {
    /// Set empty to exercise the Home empty state.
    private let scans: [FaceScan]

    init(scans: [FaceScan] = SampleScans.history) {
        self.scans = scans
    }

    func latestScan() -> FaceScan? {
        scans.max { $0.capturedAt < $1.capturedAt }
    }

    func scanHistory() -> [FaceScan] {
        scans.sorted { $0.capturedAt > $1.capturedAt }
    }

    func scan(withID id: UUID) -> FaceScan? {
        scans.first { $0.id == id }
    }

    /// Fixtures are immutable — previews and the empty state must not start
    /// accumulating real scans.
    func save(_ scan: FaceScan, photo: Data?) {}

    func delete(scanID: UUID) {}

    func deleteAll() {}

    func photo(for id: UUID) -> Data? { nil }
}

/// Static improvement content shipped in the bundle.
struct StaticRecommendationRepository: RecommendationRepositoryProtocol {
    func recommendations() -> [Recommendation] {
        DesignContent.Improve.recommendations
    }

    /// Named after the weakest metric in the scan, not after a fixed region:
    /// the banner leads a list this same metric reorders, so the two have to
    /// agree.
    func priorityFocus(for scan: FaceScan?) -> PriorityFocus? {
        guard let weakest = scan?.metrics.min(by: { $0.percentile < $1.percentile }) else {
            return nil
        }
        return DesignContent.Improve.focus(for: weakest.kind)
    }
}

/// Paywall content with no store behind it.
///
/// Two jobs, both of them real. Previews and the Results `#Preview` need an
/// unlocked build to render anything, and dev builds need a flow that reaches
/// Results before the client's RevenueCat key exists — see
/// ``RevenueCatConfiguration/isConfigured``. Unlocking is in-memory and lasts
/// the session, so nothing here can be mistaken for an entitlement.
final class StaticSubscriptionRepository: SubscriptionRepositoryProtocol {
    private(set) var isSubscribed: Bool

    init(subscribed: Bool = true) {
        isSubscribed = subscribed
    }

    /// Always empty. With no store behind this repository there is no real
    /// price to quote, and the app quotes no other kind — the paywall says it
    /// is still loading rather than showing a figure nobody will be charged.
    func plans() async -> [SubscriptionPlan] { [] }

    func benefits() -> [PaywallBenefit] {
        DesignContent.Paywall.benefits
    }

    func refreshEntitlement() async -> Bool { isSubscribed }

    func purchase(_ period: SubscriptionPlan.Period) async throws -> PurchaseOutcome {
        isSubscribed = true
        return .unlocked
    }

    /// Nothing was ever bought, so there is nothing to bring back.
    func restorePurchases() async throws -> PurchaseOutcome {
        isSubscribed ? .unlocked : .nothingToRestore
    }
}

/// Client-written advice, read from the bundled lookup table.
struct StaticMetricAdviceRepository: MetricAdviceRepositoryProtocol {
    func advice(for kind: FacialMetric.Kind, rating: MetricRating) -> MetricAdvice {
        MetricAdviceContent.advice(for: kind, rating: rating)
    }
}

/// Picks the store the app talks to.
///
/// Without a RevenueCat key, configuring the SDK would put network errors
/// behind the CTA and make the paywall untestable, so the static repository
/// stands in — locked, and unlockable in place.
enum LiveSubscriptionRepository {
    static func make() -> SubscriptionRepositoryProtocol {
        RevenueCatConfiguration.isConfigured
            ? RevenueCatSubscriptionRepository()
            : StaticSubscriptionRepository(subscribed: false)
    }
}

/// Settings sheet contents.
struct StaticSettingsRepository: SettingsRepositoryProtocol {
    func sections() -> [SettingsSection] {
        DesignContent.Settings.sections
    }

    func versionInfo() -> AppVersionInfo {
        DesignContent.Settings.version
    }
}

/// Bundled legal copy.
struct StaticLegalRepository: LegalRepositoryProtocol {
    func document(_ kind: LegalDocument.Kind) -> LegalDocument {
        switch kind {
        case .privacy: DesignContent.Legal.privacy
        case .terms: DesignContent.Legal.terms
        }
    }
}
