import Foundation

/// The RevenueCat account and products this build talks to.
///
/// RevenueCat is the only external service the contract allows, and its
/// **anonymous user ID** carries the entitlement — there are no accounts to
/// create and nothing syncs between devices.
enum RevenueCatConfiguration {

    /// Public SDK key, from RevenueCat → Project settings → API keys → Apple.
    ///
    /// Safe to ship in the binary: RevenueCat issues a separate secret key for
    /// server calls, which this app never makes. This is the live key for the
    /// client's `mogscan` project (App Store app `com.mogscan.app`).
    static let apiKey = "appl_wcTiyIETugORJPvFPIUqNorvsXK"

    /// The entitlement both plans unlock. Must match the identifier configured
    /// on the RevenueCat dashboard, which is `premium` ("Premium Access").
    static let entitlementIdentifier = "premium"

    /// Store product identifiers, one per plan.
    ///
    /// These are the IDs that already exist in the `Mogscan Pro` subscription
    /// group on App Store Connect, and the same ones the RevenueCat products
    /// carry. An App Store product ID cannot be renamed once created, so the
    /// app matches the store rather than the other way round.
    static func productIdentifier(for period: SubscriptionPlan.Period) -> String {
        switch period {
        case .monthly: "mogscan_monthly"
        case .annual: "mogscan_annual"
        }
    }

    /// Whether a real key has been dropped in.
    ///
    /// Kept as the guard for a build with the key stripped out: without one,
    /// configuring the SDK would only produce network errors behind the CTA, so
    /// ``StaticSubscriptionRepository`` stands in instead — locked, and
    /// unlockable in place, so the flow stays reviewable end to end without
    /// pretending a purchase happened.
    static var isConfigured: Bool { !apiKey.hasPrefix("appl_REPLACE") }
}
