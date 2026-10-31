import Foundation

/// Settings sheet state. Contains only the entries the design lists — no
/// accounts, notifications, themes, social features or advanced settings.
@Observable
final class SettingsViewModel {
    private(set) var sections: [SettingsSection] = []
    private(set) var version: AppVersionInfo = DesignContent.Settings.version
    /// True while the restore call is in flight, so the row cannot be tapped
    /// into two overlapping store calls.
    private(set) var isRestoring = false
    /// Non-nil while the outcome of a restore is being shown.
    var message: String?

    private let fetchSettings: FetchSettingsUseCaseProtocol
    private let restore: RestorePurchasesUseCaseProtocol
    private let deleteAllScans: DeleteAllScansUseCaseProtocol

    init(
        fetchSettings: FetchSettingsUseCaseProtocol,
        restore: RestorePurchasesUseCaseProtocol,
        deleteAllScans: DeleteAllScansUseCaseProtocol
    ) {
        self.fetchSettings = fetchSettings
        self.restore = restore
        self.deleteAllScans = deleteAllScans
    }

    convenience init(dependencies: AppDependencies) {
        self.init(
            fetchSettings: dependencies.fetchSettings,
            restore: dependencies.restorePurchases,
            deleteAllScans: dependencies.deleteAllScans
        )
    }

    func load() {
        let result = fetchSettings()
        sections = result.sections
        version = result.version
    }

    /// Erases every stored scan, photo and measurement from this device.
    ///
    /// The app holds no copy anywhere else, so this is the whole of it — and it
    /// is what the privacy policy points at when it tells the user how to
    /// withdraw consent for face data.
    ///
    /// Silent, unlike restore. Restore reports back because nothing on screen
    /// moves when it works; this one has Home behind the sheet, which drops to
    /// its empty state the moment the sheet closes.
    @MainActor
    func deleteAllScanData() {
        deleteAllScans()
    }

    /// Brings a subscription back on a reinstalled or second device.
    ///
    /// Settings needs its own restore rather than sending the user to the
    /// paywall for one: a subscriber whose entitlement is already active never
    /// sees a paywall, and App Store Review expects a restore that is reachable
    /// without a purchase in front of it.
    ///
    /// Unlike the paywall's, this one reports success — nothing on screen
    /// changes when it works, so silence would read as a dead button.
    @MainActor
    func restorePurchases() async {
        guard !isRestoring else { return }
        isRestoring = true
        defer { isRestoring = false }

        do {
            switch try await restore() {
            case .unlocked:
                message = DesignContent.Settings.restoreSucceeded
            case .nothingToRestore:
                message = DesignContent.Paywall.nothingToRestore
            case .cancelled:
                // Backing out is a decision, not an error.
                break
            }
        } catch {
            message = DesignContent.Paywall.restoreFailed
        }
    }
}
