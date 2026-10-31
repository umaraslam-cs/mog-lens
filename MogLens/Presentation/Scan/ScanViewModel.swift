import AVFoundation
import PhotosUI
import SwiftUI

/// Drives the scan tab: entry → permission → capture → analysing → paywall → results.
///
/// The photo — captured or imported — is held for the length of the flow so
/// analysing and results show the user's own face, and stored alongside the
/// scan once the analysis finishes.
@Observable
final class ScanViewModel {

    /// The screens the flow can be showing, in the order it walks them.
    enum Screen: Hashable {
        case capture
        case analysing
        case ratingPrompt
        case paywall
        case results
    }

    private(set) var screens: [Screen] = []
    /// True while the scan flow owns the screen.
    ///
    /// The flow is presented *over* the tab shell rather than pushed inside it,
    /// so no screen in it has to hide the tab bar and none of them animate it
    /// back in on the way out — that animation is what made the bar reappear a
    /// beat after the camera closed. It also makes Results genuinely standalone
    /// wherever it is opened from.
    ///
    /// Separate from ``screens`` being empty because the flow has to keep its
    /// screens until the dismissal animation finishes; emptying them any earlier
    /// blanks the flow while it is still on screen.
    private(set) var isFlowActive = false
    /// Which tab Results asked the app to land on, held until the flow has
    /// finished dismissing. The view applies it — this model never touches
    /// ``AppRouter`` — but it is flow state, so it lives with the flow.
    private(set) var landingTab: AppRouter.Tab?
    /// Shown when camera access was refused earlier — the system prompt only
    /// ever appears once, so the only route back is Settings.
    var isShowingCameraDeniedAlert = false
    var isShowingPhotoPicker = false
    /// The photo being analysed, captured or imported. Shown on analysing and results.
    private(set) var sourcePhoto: UIImage?
    /// The scan just produced. Also written to the store — this copy is what the
    /// screens in this flow render.
    private(set) var analysedScan: FaceScan?
    /// Set when analysis could not score the photo. Drawn over the whole flow —
    /// see ``analysisDidFail(_:)``.
    var analysisFailure: FaceAnalysisError?

    let title = DesignContent.Scan.title
    let subtitle = DesignContent.Scan.subtitle
    let guidelines = DesignContent.Scan.guidelines

    private let fetchLatestScan: FetchLatestScanUseCaseProtocol
    private let detectFace: DetectFaceUseCaseProtocol
    private let saveScan: SaveScanUseCaseProtocol
    private let checkSubscription: CheckSubscriptionUseCaseProtocol

    init(
        fetchLatestScan: FetchLatestScanUseCaseProtocol,
        detectFace: DetectFaceUseCaseProtocol,
        saveScan: SaveScanUseCaseProtocol,
        checkSubscription: CheckSubscriptionUseCaseProtocol
    ) {
        self.fetchLatestScan = fetchLatestScan
        self.detectFace = detectFace
        self.saveScan = saveScan
        self.checkSubscription = checkSubscription
    }

    convenience init(dependencies: AppDependencies) {
        self.init(
            fetchLatestScan: dependencies.fetchLatestScan,
            detectFace: dependencies.detectFace,
            saveScan: dependencies.saveScan,
            checkSubscription: dependencies.checkSubscription
        )
    }

    /// The scan whose values the results screen renders once unlocked.
    ///
    /// The scan just run wins; the stored one is the fallback for a flow entered
    /// without one, which is the same record read back.
    var resultScan: FaceScan? { analysedScan ?? fetchLatestScan() }

    // MARK: Flow

    /// Take Photo pushes the capture view once camera access is granted.
    ///
    /// The system prompt is the real one — `NSCameraUsageDescription` carries the
    /// copy. ``CameraPermissionAlertView`` remains only as the design-review
    /// replica of that prompt, and is no longer part of this flow.
    @MainActor
    func takePhoto() async {
        analysisFailure = nil
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            present(.capture)
        case .notDetermined:
            if await AVCaptureDevice.requestAccess(for: .video) {
                present(.capture)
            }
        default:
            isShowingCameraDeniedAlert = true
        }
    }

    /// Import Photo opens `PhotosPicker` — no library permission prompt needed.
    func importPhoto() {
        analysisFailure = nil
        isShowingPhotoPicker = true
    }

    /// Loads the picked photo, then starts the analysis. Cancelling the picker
    /// leaves the flow where it was.
    func photoPicked(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        analysisFailure = nil

        guard let data = try? await item.loadTransferable(type: Data.self),
              let photo = UIImage(data: data) else {
            analysisFailure = .imageUnreadable
            return
        }

        let normalized = normalizeOrientation(photo)
        await beginAnalysis(of: normalized)
    }

    func captureDidFinish(photo: UIImage) async {
        analysisFailure = nil
        let normalized = normalizeOrientation(photo)
        await beginAnalysis(of: normalized)
    }

    /// Normalizes orientation and ensures a valid CGImage is backed.
    private func normalizeOrientation(_ image: UIImage) -> UIImage {
        image.normalizedUpImage()
    }

    /// Moves to the analysis screen.
    private func beginAnalysis(of photo: UIImage) async {
        analysisFailure = nil
        let normalized = normalizeOrientation(photo)
        guard normalized.guaranteedCGImage != nil else {
            analysisFailure = .imageUnreadable
            return
        }

        sourcePhoto = normalized
        if isFlowActive {
            screens.append(.analysing)
        } else {
            // Imported photos skip the camera, so this is where the flow starts.
            present(.analysing)
        }
    }

    /// Opens the flow on its first screen.
    private func present(_ screen: Screen) {
        analysisFailure = nil
        screens = [screen]
        isFlowActive = true
    }

    /// Stores the scan, then moves to the paywall — or straight past it, for a
    /// subscriber who has already paid.
    ///
    /// Saved before the paywall rather than after it: the result exists whether
    /// or not it is paid for, and Home's history is the record of scans taken,
    /// not of purchases.
    ///
    /// The entitlement read here is the cached one, because a push cannot wait
    /// on the network. Reading it stale can only ever cost a subscriber one
    /// extra paywall, which their purchase or restore dismisses — it cannot open
    /// the results to someone who has not paid, since the entitlement starts
    /// locked and is only ever raised by the store.
    private(set) var hasPromptedRating: Bool {
        get { UserDefaults.standard.bool(forKey: "hasPromptedRating") }
        set { UserDefaults.standard.set(newValue, forKey: "hasPromptedRating") }
    }

    /// Stores the scan, then moves to the rating prompt/paywall — or straight past it, for a
    /// subscriber who has already paid.
    ///
    /// Saved before the paywall rather than after it: the result exists whether
    /// or not it is paid for, and Home's history is the record of scans taken,
    /// not of purchases.
    ///
    /// The entitlement read here is the cached one, because a push cannot wait
    /// on the network. Reading it stale can only ever cost a subscriber one
    /// extra paywall, which their purchase or restore dismisses — it cannot open
    /// the results to someone who has not paid, since the entitlement starts
    /// locked and is only ever raised by the store.
    func analysisDidFinish(scan: FaceScan) {
        analysedScan = scan
        saveScan(scan: scan, photo: sourcePhoto.flatMap(storablePhoto))
        // Capture and analysing are both spent by now, so the result replaces
        // them rather than sitting on top: returning to analysing would re-run
        // it and save a second copy of the same scan.
        if checkSubscription() {
            screens = [.results]
        } else if !hasPromptedRating {
            screens = [.ratingPrompt]
        } else {
            screens = [.paywall]
        }
    }

    /// User completed or dismissed the pre-paywall rating prompt.
    func ratingPromptDidFinish() {
        hasPromptedRating = true
        screens = [.paywall]
    }

    /// Shrinks the photo to something worth keeping thirty of.
    ///
    /// Full-size camera stills are 3–5MB each; the results overlay and the Home
    /// thumbnail never need more than a screen's worth of pixels, so the long
    /// edge is capped and the result JPEG-encoded to land near 150KB. Redrawing
    /// also bakes in the orientation, so a stored photo displays upright without
    /// carrying EXIF around.
    private func storablePhoto(_ photo: UIImage) -> Data? {
        let maxDimension: CGFloat = 1200
        let longEdge = max(photo.size.width, photo.size.height)
        let scale = min(1, maxDimension / max(longEdge, 1))
        let size = CGSize(width: photo.size.width * scale, height: photo.size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            photo.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: 0.8)
    }

    /// Raised by ``AnalysingView`` when there was nothing measurable in the photo.
    ///
    /// Sets state and touches nothing else. In particular it does **not** unwind
    /// the flow: the failure lands while the transition onto analysing may still
    /// be running, and emptying ``screens`` mid-transition blanks the flow.
    ///
    /// Nothing needs unwinding here anyway. ``AnalysisFailureOverlay`` is drawn
    /// over the flow rather than inside it — see that type for why it is not an
    /// `.alert` or a `.sheet`.
    func analysisDidFail(_ error: FaceAnalysisError) {
        analysisFailure = error
    }

    /// Clears the message and lands the user wherever a retry starts.
    ///
    /// From the camera that is the camera — the obvious next move after "no face
    /// in that shot" is another shot, so closing the flow would only make them
    /// reopen it. From an import there is nothing to return to, so the flow ends.
    ///
    /// Safe to change ``screens`` here: by now nothing is mid-transition.
    func analysisFailureAcknowledged() {
        analysisFailure = nil
        sourcePhoto = nil
        analysedScan = nil

        if let capture = screens.firstIndex(of: .capture) {
            screens.removeSubrange(screens.index(after: capture)...)
        } else {
            // Imported: there is no camera to fall back to, so the flow ends.
            dismissFlow()
        }
    }

    /// Replaces the paywall with the result — there is nothing left to buy, so
    /// there is nothing to go back to.
    func purchaseDidComplete() {
        screens = [.results]
    }

    /// Closes the flow. The scan, if one was taken, is already saved.
    func dismissFlow() {
        isFlowActive = false
    }

    /// Ends the flow from Results, naming where the app should land once it has
    /// finished dismissing.
    func finish(landingOn tab: AppRouter.Tab) {
        landingTab = tab
        dismissFlow()
    }

    /// Clears the flow once its dismissal animation has finished, handing back
    /// the tab to land on if Results named one.
    ///
    /// Clearing any earlier would empty the flow while it is still on screen.
    @discardableResult
    func flowDidDismiss() -> AppRouter.Tab? {
        defer {
            landingTab = nil
            screens.removeAll()
            sourcePhoto = nil
            analysedScan = nil
            analysisFailure = nil
        }
        return landingTab
    }
}
