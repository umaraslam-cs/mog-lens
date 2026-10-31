import Foundation

// MARK: - Offer

protocol FetchSubscriptionOfferUseCaseProtocol {
    func callAsFunction() async -> (plans: [SubscriptionPlan], benefits: [PaywallBenefit])
}

struct FetchSubscriptionOfferUseCase: FetchSubscriptionOfferUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol

    init(repository: SubscriptionRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction() async -> (plans: [SubscriptionPlan], benefits: [PaywallBenefit]) {
        await (repository.plans(), repository.benefits())
    }
}

// MARK: - Entitlement

/// The gate every result value sits behind. Reads the cached entitlement, so it
/// is safe to call while deciding where to navigate.
protocol CheckSubscriptionUseCaseProtocol {
    func callAsFunction() -> Bool
}

struct CheckSubscriptionUseCase: CheckSubscriptionUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol

    init(repository: SubscriptionRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction() -> Bool { repository.isSubscribed }
}

/// Re-reads entitlement from the store. Run on launch and whenever a screen
/// that gates on it appears, so a lapsed subscription re-locks results without
/// waiting for a purchase attempt.
protocol RefreshEntitlementUseCaseProtocol {
    @discardableResult
    func callAsFunction() async -> Bool
}

struct RefreshEntitlementUseCase: RefreshEntitlementUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol

    init(repository: SubscriptionRepositoryProtocol) {
        self.repository = repository
    }

    @discardableResult
    func callAsFunction() async -> Bool {
        await repository.refreshEntitlement()
    }
}

// MARK: - Transactions

protocol PurchaseSubscriptionUseCaseProtocol {
    func callAsFunction(_ period: SubscriptionPlan.Period) async throws -> PurchaseOutcome
}

struct PurchaseSubscriptionUseCase: PurchaseSubscriptionUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol

    init(repository: SubscriptionRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction(_ period: SubscriptionPlan.Period) async throws -> PurchaseOutcome {
        try await repository.purchase(period)
    }
}

/// Required by App Store review, and the only way back in for a user who
/// reinstalled — with anonymous IDs there is no account to sign into.
protocol RestorePurchasesUseCaseProtocol {
    func callAsFunction() async throws -> PurchaseOutcome
}

struct RestorePurchasesUseCase: RestorePurchasesUseCaseProtocol {
    private let repository: SubscriptionRepositoryProtocol

    init(repository: SubscriptionRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction() async throws -> PurchaseOutcome {
        try await repository.restorePurchases()
    }
}
