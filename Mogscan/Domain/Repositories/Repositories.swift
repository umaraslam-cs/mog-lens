import CoreGraphics
import Foundation
import ImageIO

/// Runs the on-device Vision pipeline over one photo and returns a scored scan.
///
/// Takes a `CGImage` rather than a `UIImage` so this layer stays free of UIKit.
protocol FaceAnalysisRepositoryProtocol {
    func analyse(
        _ image: CGImage,
        orientation: CGImagePropertyOrientation
    ) async throws -> FaceScan

    /// Whether there is a face in the photo at all.
    ///
    /// Cheaper than ``analyse(_:orientation:)`` — face rectangles only, no
    /// landmarks — so the scan flow can turn a photo away before committing to
    /// the analysis screen.
    func containsFace(
        _ image: CGImage,
        orientation: CGImagePropertyOrientation
    ) async -> Bool
}

/// Local scan store. Backed by SwiftData or a file store in production; the UI
/// layer only ever sees this protocol.
protocol ScanRepositoryProtocol {
    /// Most recent scan, or `nil` when the store is empty.
    func latestScan() -> FaceScan?
    /// History, newest first.
    func scanHistory() -> [FaceScan]
    func scan(withID id: UUID) -> FaceScan?
    /// Adds a finished scan to the store, with the photo it was measured from
    /// already encoded for storage.
    func save(_ scan: FaceScan, photo: Data?)
    /// The stored photo for a scan, or `nil` if it has none.
    func photo(for id: UUID) -> Data?
    /// Erases one scan and the photo it was measured from.
    ///
    /// The photo is face data, so removal has to reach the file on disk and not
    /// just the record — App Review asks for a way to delete it, and a record
    /// that no longer lists a JPEG is not the same as a JPEG that is gone.
    func delete(scanID: UUID)
    /// Erases every scan, every photo and the records file.
    ///
    /// The user's way to withdraw consent for face data held on the device.
    func deleteAll()
}

/// Static improvement content shipped in the bundle.
protocol RecommendationRepositoryProtocol {
    /// The full, hand-written card set in its declared order.
    func recommendations() -> [Recommendation]
    /// Priority banner copy derived from the weakest metric of a scan.
    func priorityFocus(for scan: FaceScan?) -> PriorityFocus?
}

/// Store-facing subscription state.
///
/// RevenueCat backs this in the app. Its anonymous user ID carries the
/// entitlement and is the whole "backend" the contract allows — no accounts, no
/// sign-in, nothing to sync between devices.
protocol SubscriptionRepositoryProtocol {
    /// Plans in display order, priced from the store when it answers.
    func plans() async -> [SubscriptionPlan]
    func benefits() -> [PaywallBenefit]

    /// Whether result values may be rendered.
    ///
    /// A cached snapshot, and synchronous on purpose: it gates navigation, and
    /// a push cannot wait on the network. ``refreshEntitlement()`` is what keeps
    /// it current.
    var isSubscribed: Bool { get }

    /// Re-reads entitlement from the store. Returns the refreshed value.
    @discardableResult
    func refreshEntitlement() async -> Bool

    func purchase(_ period: SubscriptionPlan.Period) async throws -> PurchaseOutcome
    func restorePurchases() async throws -> PurchaseOutcome
}

/// Client-written advice, keyed metric × score band. Shipped in the bundle:
/// never generated, never personalised beyond the band a scan lands in.
protocol MetricAdviceRepositoryProtocol {
    func advice(for kind: FacialMetric.Kind, rating: MetricRating) -> MetricAdvice
}

/// Settings sheet contents.
protocol SettingsRepositoryProtocol {
    func sections() -> [SettingsSection]
    func versionInfo() -> AppVersionInfo
}

/// Legal copy shipped in the bundle. Remote-hosted documents would be fetched
/// behind this same protocol.
protocol LegalRepositoryProtocol {
    func document(_ kind: LegalDocument.Kind) -> LegalDocument
}

/// Copy for the priority banner on the Improve tab.
struct PriorityFocus: Hashable {
    let title: String
    let detail: String
    /// The category that floats to the top of the list.
    let leadingCategory: Recommendation.Category
}
