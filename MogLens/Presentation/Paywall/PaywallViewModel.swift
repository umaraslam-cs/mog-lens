import Foundation

/// Paywall state and the two store calls the screen can make.
///
/// Deliberately holds no scan: the paywall renders before any result value is
/// loaded into a view model, so no score, tier, metric or percentile can leak —
/// not behind a blur, not in memory.
@Observable
final class PaywallViewModel {
    /// What the store has said about the plan list so far. The paywall has no
    /// bundled prices to fall back on, so "still asking" and "the store has
    /// nothing to sell" are different screens and must be told apart.
    enum PlanState {
        case loading
        case ready
        case unavailable
    }

    private(set) var plans: [SubscriptionPlan] = []
    private(set) var planState: PlanState = .loading
    private(set) var benefits: [PaywallBenefit] = []
    /// True while a store call is in flight. The CTA and the restore link both
    /// read it, so a slow App Store sheet cannot be double-tapped into two
    /// purchases.
    private(set) var isBusy = false
    /// Non-nil while an outcome worth explaining is being shown. Cancelling is
    /// not one of them.
    var message: String?

    var selectedPlan: SubscriptionPlan.Period = .annual

    private let fetchOffer: FetchSubscriptionOfferUseCaseProtocol
    private let purchaseSubscription: PurchaseSubscriptionUseCaseProtocol
    private let restore: RestorePurchasesUseCaseProtocol
    private let refreshSubscription: RefreshEntitlementUseCaseProtocol

    init(
        fetchOffer: FetchSubscriptionOfferUseCaseProtocol,
        purchaseSubscription: PurchaseSubscriptionUseCaseProtocol,
        restore: RestorePurchasesUseCaseProtocol,
        refreshSubscription: RefreshEntitlementUseCaseProtocol
    ) {
        self.fetchOffer = fetchOffer
        self.purchaseSubscription = purchaseSubscription
        self.restore = restore
        self.refreshSubscription = refreshSubscription
    }

    convenience init(dependencies: AppDependencies) {
        self.init(
            fetchOffer: dependencies.fetchSubscriptionOffer,
            purchaseSubscription: dependencies.purchaseSubscription,
            restore: dependencies.restorePurchases,
            refreshSubscription: dependencies.refreshEntitlement
        )
    }

    @MainActor
    private func refreshEntitlement() async -> Bool {
        await refreshSubscription()
    }

    /// Loads the offer, and first checks whether this device is already
    /// entitled.
    ///
    /// Returns true when it is, so the view can leave without ever showing the
    /// ask: the cached entitlement starts locked on every cold launch, so a
    /// subscriber who scans before Home has refreshed would otherwise be
    /// charged-and-asked-again for something they already own.
    @MainActor
    @discardableResult
    func load() async -> Bool {
        if await refreshEntitlement() { return true }

        planState = .loading
        let offer = await fetchOffer()
        plans = offer.plans
        benefits = offer.benefits
        planState = plans.isEmpty ? .unavailable : .ready
        return false
    }

    /// Re-asks the store after a failed load. Same call as ``load()``; separate
    /// so the retry button reads as what it is at the call site.
    @MainActor
    @discardableResult
    func retryLoadingPlans() async -> Bool {
        await load()
    }

    /// True once the store has answered with something buyable.
    var canPurchase: Bool { planState == .ready && !isBusy }

    func select(_ period: SubscriptionPlan.Period) {
        selectedPlan = period
    }

    /// Buys the selected plan. Returns whether the results may now be shown, so
    /// the view can hand back to the flow; everything else — cancellation,
    /// failure — is absorbed into ``message``.
    @MainActor
    func purchase() async -> Bool {
        guard planState == .ready else {
            message = DesignContent.Paywall.offeringUnavailable
            return false
        }
        return await run(notEntitled: DesignContent.Paywall.purchasePending) {
            try await purchaseSubscription(selectedPlan)
        }
    }

    @MainActor
    func restorePurchases() async -> Bool {
        await run(notEntitled: DesignContent.Paywall.nothingToRestore) {
            try await restore()
        }
    }

    /// The shared shape of both store calls: busy flag, outcome, message.
    ///
    /// `notEntitled` is what to say when the call came back without raising the
    /// entitlement. The two callers mean different things by that — a restore
    /// found nothing to bring back, a purchase went through but is waiting on
    /// approval — and telling a buyer "no subscription found" would be wrong.
    @MainActor
    private func run(
        notEntitled: String,
        _ call: () async throws -> PurchaseOutcome
    ) async -> Bool {
        guard !isBusy else { return false }
        isBusy = true
        defer { isBusy = false }

        do {
            switch try await call() {
            case .unlocked:
                return true
            case .cancelled:
                // Backing out is a decision, not an error. Saying anything here
                // reads as nagging.
                return false
            case .nothingToRestore:
                message = notEntitled
                return false
            }
        } catch {
            // A transaction that finished while the connection dropped still
            // entitles the device, and RevenueCat will have it — so ask before
            // reporting a failure the user would otherwise pay through twice.
            if await refreshEntitlement() { return true }

            switch error {
            case SubscriptionError.offeringUnavailable:
                message = DesignContent.Paywall.offeringUnavailable
            case SubscriptionError.restoreFailed:
                message = DesignContent.Paywall.restoreFailed
            default:
                message = DesignContent.Paywall.purchaseFailed
            }
            return false
        }
    }
}
