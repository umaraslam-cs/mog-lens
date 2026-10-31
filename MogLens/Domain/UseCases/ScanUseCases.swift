import CoreGraphics
import Foundation
import ImageIO

// MARK: - Analyse a photo

protocol AnalyseFaceUseCaseProtocol {
    func callAsFunction(
        image: CGImage,
        orientation: CGImagePropertyOrientation
    ) async throws -> FaceScan
}

protocol SaveScanUseCaseProtocol {
    func callAsFunction(scan: FaceScan, photo: Data?)
}

struct SaveScanUseCase: SaveScanUseCaseProtocol {
    private let repository: ScanRepositoryProtocol

    init(repository: ScanRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction(scan: FaceScan, photo: Data?) {
        repository.save(scan, photo: photo)
    }
}

/// Erases one stored scan, photo included.
protocol DeleteScanUseCaseProtocol {
    func callAsFunction(scanID: UUID)
}

struct DeleteScanUseCase: DeleteScanUseCaseProtocol {
    private let repository: ScanRepositoryProtocol

    init(repository: ScanRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction(scanID: UUID) {
        repository.delete(scanID: scanID)
    }
}

/// Erases every stored scan and photo — the withdraw-consent action in Settings.
protocol DeleteAllScansUseCaseProtocol {
    func callAsFunction()
}

struct DeleteAllScansUseCase: DeleteAllScansUseCaseProtocol {
    private let repository: ScanRepositoryProtocol

    init(repository: ScanRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction() {
        repository.deleteAll()
    }
}

protocol FetchScanPhotoUseCaseProtocol {
    func callAsFunction(scanID: UUID) -> Data?
}

struct FetchScanPhotoUseCase: FetchScanPhotoUseCaseProtocol {
    private let repository: ScanRepositoryProtocol

    init(repository: ScanRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction(scanID: UUID) -> Data? {
        repository.photo(for: scanID)
    }
}

protocol DetectFaceUseCaseProtocol {
    func callAsFunction(
        image: CGImage,
        orientation: CGImagePropertyOrientation
    ) async -> Bool
}

struct DetectFaceUseCase: DetectFaceUseCaseProtocol {
    private let repository: FaceAnalysisRepositoryProtocol

    init(repository: FaceAnalysisRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction(
        image: CGImage,
        orientation: CGImagePropertyOrientation
    ) async -> Bool {
        await repository.containsFace(image, orientation: orientation)
    }
}

struct AnalyseFaceUseCase: AnalyseFaceUseCaseProtocol {
    private let repository: FaceAnalysisRepositoryProtocol

    init(repository: FaceAnalysisRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction(
        image: CGImage,
        orientation: CGImagePropertyOrientation
    ) async throws -> FaceScan {
        try await repository.analyse(image, orientation: orientation)
    }
}

// MARK: - Latest scan

protocol FetchLatestScanUseCaseProtocol {
    func callAsFunction() -> FaceScan?
}

struct FetchLatestScanUseCase: FetchLatestScanUseCaseProtocol {
    private let repository: ScanRepositoryProtocol

    init(repository: ScanRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction() -> FaceScan? {
        repository.latestScan()
    }
}

// MARK: - History

protocol FetchScanHistoryUseCaseProtocol {
    func callAsFunction() -> [FaceScan]
}

struct FetchScanHistoryUseCase: FetchScanHistoryUseCaseProtocol {
    private let repository: ScanRepositoryProtocol

    init(repository: ScanRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction() -> [FaceScan] {
        repository.scanHistory()
    }
}

// MARK: - Single scan

protocol FetchScanUseCaseProtocol {
    func callAsFunction(id: UUID) -> FaceScan?
}

struct FetchScanUseCase: FetchScanUseCaseProtocol {
    private let repository: ScanRepositoryProtocol

    init(repository: ScanRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction(id: UUID) -> FaceScan? {
        repository.scan(withID: id)
    }
}
