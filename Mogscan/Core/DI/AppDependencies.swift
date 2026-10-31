import SwiftUI

/// Composition root.
///
/// Owns the concrete repositories and hands view models the use cases they need.
/// Swapping ``StaticScanRepository`` for a SwiftData-backed store is the only
/// change required to move this build onto real data.
@Observable
final class AppDependencies {

    // MARK: Repositories

    let scanRepository: ScanRepositoryProtocol
    let faceAnalysisRepository: FaceAnalysisRepositoryProtocol
    let recommendationRepository: RecommendationRepositoryProtocol
    let subscriptionRepository: SubscriptionRepositoryProtocol
    let metricAdviceRepository: MetricAdviceRepositoryProtocol
    let settingsRepository: SettingsRepositoryProtocol
    let legalRepository: LegalRepositoryProtocol

    init(
        scanRepository: ScanRepositoryProtocol = FileScanRepository(),
        faceAnalysisRepository: FaceAnalysisRepositoryProtocol = VisionFaceAnalyser(),
        recommendationRepository: RecommendationRepositoryProtocol = StaticRecommendationRepository(),
        // Live store. `make()` configures RevenueCat when a key is present and
        // falls back to the locked static repository when one isn't, so a build
        // with the key stripped still runs the flow end to end.
        subscriptionRepository: SubscriptionRepositoryProtocol = LiveSubscriptionRepository.make(),
        metricAdviceRepository: MetricAdviceRepositoryProtocol = StaticMetricAdviceRepository(),
        settingsRepository: SettingsRepositoryProtocol = StaticSettingsRepository(),
        legalRepository: LegalRepositoryProtocol = StaticLegalRepository()
    ) {
        self.scanRepository = scanRepository
        self.faceAnalysisRepository = faceAnalysisRepository
        self.recommendationRepository = recommendationRepository
        self.subscriptionRepository = subscriptionRepository
        self.metricAdviceRepository = metricAdviceRepository
        self.settingsRepository = settingsRepository
        self.legalRepository = legalRepository
    }

    // MARK: Use cases

    var analyseFace: AnalyseFaceUseCaseProtocol {
        AnalyseFaceUseCase(repository: faceAnalysisRepository)
    }

    var detectFace: DetectFaceUseCaseProtocol {
        DetectFaceUseCase(repository: faceAnalysisRepository)
    }

    var saveScan: SaveScanUseCaseProtocol {
        SaveScanUseCase(repository: scanRepository)
    }

    var deleteScan: DeleteScanUseCaseProtocol {
        DeleteScanUseCase(repository: scanRepository)
    }

    var deleteAllScans: DeleteAllScansUseCaseProtocol {
        DeleteAllScansUseCase(repository: scanRepository)
    }

    var fetchScanPhoto: FetchScanPhotoUseCaseProtocol {
        FetchScanPhotoUseCase(repository: scanRepository)
    }

    var fetchLatestScan: FetchLatestScanUseCaseProtocol {
        FetchLatestScanUseCase(repository: scanRepository)
    }

    var fetchScanHistory: FetchScanHistoryUseCaseProtocol {
        FetchScanHistoryUseCase(repository: scanRepository)
    }

    var fetchScan: FetchScanUseCaseProtocol {
        FetchScanUseCase(repository: scanRepository)
    }

    var fetchRecommendations: FetchRecommendationsUseCaseProtocol {
        FetchRecommendationsUseCase(repository: recommendationRepository)
    }

    var fetchPriorityFocus: FetchPriorityFocusUseCaseProtocol {
        FetchPriorityFocusUseCase(repository: recommendationRepository)
    }

    var fetchMetricAdvice: FetchMetricAdviceUseCaseProtocol {
        FetchMetricAdviceUseCase(repository: metricAdviceRepository)
    }

    var fetchSubscriptionOffer: FetchSubscriptionOfferUseCaseProtocol {
        FetchSubscriptionOfferUseCase(repository: subscriptionRepository)
    }

    var checkSubscription: CheckSubscriptionUseCaseProtocol {
        CheckSubscriptionUseCase(repository: subscriptionRepository)
    }

    var refreshEntitlement: RefreshEntitlementUseCaseProtocol {
        RefreshEntitlementUseCase(repository: subscriptionRepository)
    }

    var purchaseSubscription: PurchaseSubscriptionUseCaseProtocol {
        PurchaseSubscriptionUseCase(repository: subscriptionRepository)
    }

    var restorePurchases: RestorePurchasesUseCaseProtocol {
        RestorePurchasesUseCase(repository: subscriptionRepository)
    }

    var fetchSettings: FetchSettingsUseCaseProtocol {
        FetchSettingsUseCase(repository: settingsRepository)
    }

    var fetchLegalDocument: FetchLegalDocumentUseCaseProtocol {
        FetchLegalDocumentUseCase(repository: legalRepository)
    }

    // MARK: Convenience configurations

    /// Store with no scans — drives the Home empty state. Locked, with no
    /// RevenueCat behind it: a preview has no business configuring the SDK.
    static var empty: AppDependencies {
        AppDependencies(
            scanRepository: StaticScanRepository(scans: []),
            subscriptionRepository: StaticSubscriptionRepository(subscribed: false)
        )
    }
}
