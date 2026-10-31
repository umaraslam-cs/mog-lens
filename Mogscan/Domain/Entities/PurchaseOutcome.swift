import Foundation

/// How a purchase or restore attempt settled.
enum PurchaseOutcome: Hashable {
    /// The entitlement is active — results may be rendered.
    case unlocked
    /// The user backed out of the App Store sheet. Not a failure, and not
    /// something to put an error in front of them for.
    case cancelled
    /// The call succeeded but left no entitlement: a restore on an Apple ID that
    /// never subscribed, or one whose subscription has lapsed.
    case nothingToRestore
}

/// Store failures worth showing.
///
/// Carries the case, not the copy — wording lives in `DesignContent` with the
/// rest of the user-facing strings, and the view model maps one to the other.
/// The store's own messages name products and entitlements, so they are kept
/// out of the UI and left for the logs.
enum SubscriptionError: Error, Hashable {
    /// No offering came back, so there is nothing to sell.
    case offeringUnavailable
    case purchaseFailed
    case restoreFailed
}
