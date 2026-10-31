import Foundation
import RevenueCat

/// Entitlement and purchases, through RevenueCat.
///
/// A class rather than a struct because the entitlement is cached: reading it
/// gates navigation, which cannot await the network, so the value is kept here
/// and refreshed around it. The customer-info stream keeps that cache honest
/// when a subscription lapses or is restored on another device — without it a
/// lapsed user would keep their results until the next launch.
final class RevenueCatSubscriptionRepository: SubscriptionRepositoryProtocol {

    /// Last known entitlement. Starts locked: the safe answer before the store
    /// has been asked is "no results".
    private(set) var isSubscribed = false

    private let entitlementIdentifier = RevenueCatConfiguration.entitlementIdentifier
    private var entitlementObserver: Task<Void, Never>?

    /// Configures the SDK on construction.
    ///
    /// The composition root builds this once at launch, which is exactly when
    /// RevenueCat wants configuring, and it keeps store setup out of the `App`
    /// type where nothing else store-shaped lives.
    init() {
        Purchases.logLevel = .warn
        Purchases.configure(withAPIKey: RevenueCatConfiguration.apiKey)
        observeEntitlement()
    }

    deinit { entitlementObserver?.cancel() }

    // MARK: Offer

    func plans() async -> [SubscriptionPlan] {
        // No bundled fallback: every price the paywall shows is the one the
        // App Store will charge. Until the store answers the list is empty and
        // the screen says so, rather than quoting a figure this build guessed.
        guard let offering = try? await Purchases.shared.offerings().current else { return [] }

        let monthly = product(in: offering, for: .monthly)
        let annual = product(in: offering, for: .annual)

        return SubscriptionPlan.Period.allCases.compactMap { period in
            switch period {
            case .monthly:
                monthly.map { plan(for: .monthly, product: $0, badge: nil) }
            case .annual:
                annual.map {
                    plan(for: .annual, product: $0, badge: savingsBadge(annual: $0, monthly: monthly))
                }
            }
        }
    }

    func benefits() -> [PaywallBenefit] { DesignContent.Paywall.benefits }

    // MARK: Entitlement

    @discardableResult
    func refreshEntitlement() async -> Bool {
        guard let info = try? await Purchases.shared.customerInfo() else { return isSubscribed }
        await apply(info)
        return isSubscribed
    }

    /// Keeps the cache in step with renewals, lapses and purchases made
    /// elsewhere, for as long as the app is alive.
    private func observeEntitlement() {
        entitlementObserver = Task { [weak self] in
            for await info in Purchases.shared.customerInfoStream {
                guard let self else { return }
                await apply(info)
            }
        }
    }

    /// Main-actor because the cache has two writers — this stream and the
    /// store calls below — and one synchronous reader, ``isSubscribed``, which
    /// gates navigation from the main thread. One writer thread, one reader
    /// thread, no torn reads.
    @MainActor
    private func apply(_ info: CustomerInfo) {
        isSubscribed = info.entitlements[entitlementIdentifier]?.isActive == true
    }

    // MARK: Transactions

    func purchase(_ period: SubscriptionPlan.Period) async throws -> PurchaseOutcome {
        guard let package = await package(for: period) else {
            throw SubscriptionError.offeringUnavailable
        }

        do {
            let result = try await Purchases.shared.purchase(package: package)
            guard !result.userCancelled else { return .cancelled }
            await apply(result.customerInfo)
            return isSubscribed ? .unlocked : .nothingToRestore
        } catch {
            // Backing out of the App Store sheet arrives as an error, not as a
            // cancelled result, depending on where the user taps. Neither is a
            // failure worth an alert.
            if isCancellation(error) { return .cancelled }
            throw SubscriptionError.purchaseFailed
        }
    }

    func restorePurchases() async throws -> PurchaseOutcome {
        do {
            let info = try await Purchases.shared.restorePurchases()
            await apply(info)
            return isSubscribed ? .unlocked : .nothingToRestore
        } catch {
            if isCancellation(error) { return .cancelled }
            throw SubscriptionError.restoreFailed
        }
    }

    private func isCancellation(_ error: Error) -> Bool {
        (error as NSError).code == ErrorCode.purchaseCancelledError.rawValue
    }

    // MARK: Store lookup

    private func package(for period: SubscriptionPlan.Period) async -> Package? {
        guard let offering = try? await Purchases.shared.offerings().current else { return nil }
        return offering.availablePackages.first {
            $0.storeProduct.productIdentifier == RevenueCatConfiguration.productIdentifier(for: period)
        }
    }

    private func product(in offering: Offering, for period: SubscriptionPlan.Period) -> StoreProduct? {
        offering.availablePackages
            .map(\.storeProduct)
            .first { $0.productIdentifier == RevenueCatConfiguration.productIdentifier(for: period) }
    }

    // MARK: Display

    private func plan(
        for period: SubscriptionPlan.Period,
        product: StoreProduct,
        badge: String?
    ) -> SubscriptionPlan {
        SubscriptionPlan(
            period: period,
            title: DesignContent.Paywall.planTitle(period),
            priceCaption: caption(for: period, product: product),
            badge: badge
        )
    }

    /// The annual caption carries a per-month figure because that is the
    /// comparison the user is actually making on this screen.
    private func caption(for period: SubscriptionPlan.Period, product: StoreProduct) -> String {
        switch period {
        case .monthly:
            DesignContent.Paywall.monthlyCaption(product.localizedPriceString)
        case .annual:
            DesignContent.Paywall.annualCaption(
                product.localizedPriceString,
                perMonth: formatted(price: product.price / 12, like: product)
            )
        }
    }

    /// Whole percent saved by paying yearly. Nil when either product is missing
    /// or the maths does not favour the annual plan — a badge claiming a saving
    /// that isn't there is worse than no badge.
    private func savingsBadge(annual: StoreProduct, monthly: StoreProduct?) -> String? {
        guard let monthly, monthly.price > 0 else { return nil }
        let saved = 1 - (annual.price / 12) / monthly.price
        let percent = Int((saved * 100 as NSDecimalNumber).doubleValue.rounded())
        guard percent > 0 else { return nil }
        return DesignContent.Paywall.savingsBadge(percent)
    }

    /// Formats a derived amount in the product's own currency and locale, so a
    /// per-month figure reads like the price above it.
    private func formatted(price: Decimal, like product: StoreProduct) -> String {
        guard let formatter = product.priceFormatter,
              let text = formatter.string(from: price as NSDecimalNumber) else {
            return "\(price)"
        }
        return text
    }
}
