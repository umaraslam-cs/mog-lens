import ImageIO
import UIKit

/// Home dashboard state. Reads the local scan store through use cases and
/// exposes display-ready strings; the view holds no formatting logic.
@Observable
final class HomeViewModel {
    private let fetchLatestScan: FetchLatestScanUseCaseProtocol
    private let fetchScanHistory: FetchScanHistoryUseCaseProtocol
    private let fetchScanPhoto: FetchScanPhotoUseCaseProtocol
    private let deleteScanUseCase: DeleteScanUseCaseProtocol
    private let checkSubscription: CheckSubscriptionUseCaseProtocol
    private let refreshSubscription: RefreshEntitlementUseCaseProtocol

    private(set) var latestScan: FaceScan?
    private(set) var history: [FaceScan] = []
    /// Thumbnails for the history rows, keyed by scan. Decoded here rather than
    /// in the row so the list does not do file work while laying out.
    private(set) var thumbnails: [UUID: UIImage] = [:]
    /// Whether result values may be rendered at all. Home shows scores and
    /// tiers, so it gates on the same entitlement Results does.
    private(set) var isSubscribed = false

    init(
        fetchLatestScan: FetchLatestScanUseCaseProtocol,
        fetchScanHistory: FetchScanHistoryUseCaseProtocol,
        fetchScanPhoto: FetchScanPhotoUseCaseProtocol,
        deleteScan: DeleteScanUseCaseProtocol,
        checkSubscription: CheckSubscriptionUseCaseProtocol,
        refreshSubscription: RefreshEntitlementUseCaseProtocol
    ) {
        self.fetchLatestScan = fetchLatestScan
        self.fetchScanHistory = fetchScanHistory
        self.fetchScanPhoto = fetchScanPhoto
        self.deleteScanUseCase = deleteScan
        self.checkSubscription = checkSubscription
        self.refreshSubscription = refreshSubscription
    }

    convenience init(dependencies: AppDependencies) {
        self.init(
            fetchLatestScan: dependencies.fetchLatestScan,
            fetchScanHistory: dependencies.fetchScanHistory,
            fetchScanPhoto: dependencies.fetchScanPhoto,
            deleteScan: dependencies.deleteScan,
            checkSubscription: dependencies.checkSubscription,
            refreshSubscription: dependencies.refreshEntitlement
        )
    }

    /// The photo a stored scan was measured from, for the results overlay.
    /// Loaded on demand rather than held with the record — thirty photos in
    /// memory is not worth it to save a file read on tap.
    func photo(for scan: FaceScan) -> UIImage? {
        fetchScanPhoto(scanID: scan.id).flatMap(UIImage.init(data:))
    }

    /// Erases one scan, its photo and its thumbnail, then reloads.
    ///
    /// Reachable from the history row's menu. Settings holds the delete-all
    /// button; this is the per-scan half of the same promise.
    func delete(_ scan: FaceScan) {
        deleteScanUseCase(scanID: scan.id)
        thumbnails[scan.id] = nil
        load()
    }

    func load() {
        isSubscribed = checkSubscription()
        latestScan = fetchLatestScan()
        history = fetchScanHistory()
        loadThumbnails()
    }

    /// Re-reads entitlement from the store.
    ///
    /// Home is where a lapsed subscription has to be noticed: it is the screen
    /// with scores on it that nobody navigated through a paywall to reach.
    func refreshEntitlement() async {
        isSubscribed = await refreshSubscription()
    }

    /// Reads a small thumbnail per history row.
    ///
    /// ImageIO decodes straight to the size asked for, so a stored 1200px photo
    /// never becomes a full bitmap in memory — thirty rows cost about as much as
    /// one. Already-decoded rows are skipped, because Home reloads on every
    /// appearance and the photo for a given scan never changes.
    private func loadThumbnails() {
        let maxPixel = 104.0

        for scan in history where thumbnails[scan.id] == nil {
            guard let data = fetchScanPhoto(scanID: scan.id) as CFData?,
                  let source = CGImageSourceCreateWithData(data, nil),
                  let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                      kCGImageSourceCreateThumbnailFromImageAlways: true,
                      kCGImageSourceCreateThumbnailWithTransform: true,
                      kCGImageSourceThumbnailMaxPixelSize: maxPixel
                  ] as CFDictionary)
            else { continue }
            thumbnails[scan.id] = UIImage(cgImage: thumbnail)
        }
    }

    /// No scan yet — show the elegant empty state, no skeleton cards and no fake numbers.
    var isEmpty: Bool { latestScan == nil }

    /// Scans exist but may not be shown.
    ///
    /// Reachable in one way: closing the paywall after a scan. The scan is saved
    /// regardless — it is a record of what the user did, not of what they paid
    /// for — so Home has to hold something it cannot display. It says so, rather
    /// than pretending the scan never happened or leaking the score it produced.
    var isLocked: Bool { !isEmpty && !isSubscribed }

    /// e.g. "3 scans waiting".
    var lockedScansCaption: String {
        DesignContent.Home.lockedDetail(count: history.count)
    }

    var greeting: String {
        isEmpty ? DesignContent.Home.welcomeFirstRun : DesignContent.Home.welcomeReturning
    }

    /// e.g. "Last scan · 12 Mar, 09:24".
    var lastScanCaption: String {
        guard let latestScan else { return "" }
        return "Last scan · \(ScanDateFormatter.summary(latestScan.capturedAt))"
    }
}
