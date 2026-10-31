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
    /// server calls, which this app never makes. This key was issued for the
    /// RevenueCat app registered against the previous bundle ID. RevenueCat
    /// needs a new Apple app for `com.moglens.app`, and its key replaces this one.
    static let apiKey = "appl_wcTiyIETugORJPvFPIUqNorvsXK"

    /// The entitlement both plans unlock. Must match the identifier configured
    /// on the RevenueCat dashboard, which is `premium` ("Premium Access").
    static let entitlementIdentifier = "premium"

    /// Store product identifiers, one per plan.
    ///
    /// These must match the products in the `MogLens Pro` subscription group on
    /// App Store Connect and the RevenueCat products. App Store product IDs
    /// cannot be renamed once created, so after the rename these are new
    /// products that still have to be created under `com.moglens.app`.
    static func productIdentifier(for period: SubscriptionPlan.Period) -> String {
        switch period {
        case .monthly: "moglens_monthly"
        case .annual: "moglens_annual"
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
