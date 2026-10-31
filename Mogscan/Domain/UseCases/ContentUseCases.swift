import Foundation

// MARK: - Recommendations

protocol FetchRecommendationsUseCaseProtocol {
    /// Cards in their declared order, with the category tied to the weakest
    /// metric floated to the top.
    func callAsFunction(prioritising scan: FaceScan?) -> [Recommendation]
}

struct FetchRecommendationsUseCase: FetchRecommendationsUseCaseProtocol {
    private let repository: RecommendationRepositoryProtocol

    init(repository: RecommendationRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction(prioritising scan: FaceScan?) -> [Recommendation] {
        let all = repository.recommendations()
        guard let leading = repository.priorityFocus(for: scan)?.leadingCategory,
              let index = all.firstIndex(where: { $0.category == leading }) else {
            return all
        }
        var ordered = all
        ordered.insert(ordered.remove(at: index), at: 0)
        return ordered
    }
}

// MARK: - Priority focus

protocol FetchPriorityFocusUseCaseProtocol {
    func callAsFunction(for scan: FaceScan?) -> PriorityFocus?
}

struct FetchPriorityFocusUseCase: FetchPriorityFocusUseCaseProtocol {
    private let repository: RecommendationRepositoryProtocol

    init(repository: RecommendationRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction(for scan: FaceScan?) -> PriorityFocus? {
        repository.priorityFocus(for: scan)
    }
}

// MARK: - Metric advice

protocol FetchMetricAdviceUseCaseProtocol {
    /// Advice for every metric in a scan, weakest first.
    ///
    /// Ordered rather than filtered: Results shows the top of the list, Improve
    /// shows all of it, and both want the same order. Which slice to take is a
    /// screen's decision, not this one's.
    func callAsFunction(for metrics: [FacialMetric]) -> [MetricAdvice]
}

struct FetchMetricAdviceUseCase: FetchMetricAdviceUseCaseProtocol {
    private let repository: MetricAdviceRepositoryProtocol

    init(repository: MetricAdviceRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction(for metrics: [FacialMetric]) -> [MetricAdvice] {
        metrics
            .sorted { $0.percentile < $1.percentile }
            .map { repository.advice(for: $0.kind, rating: $0.rating) }
    }
}

// MARK: - Settings

protocol FetchSettingsUseCaseProtocol {
    func callAsFunction() -> (sections: [SettingsSection], version: AppVersionInfo)
}

struct FetchSettingsUseCase: FetchSettingsUseCaseProtocol {
    private let repository: SettingsRepositoryProtocol

    init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction() -> (sections: [SettingsSection], version: AppVersionInfo) {
        (repository.sections(), repository.versionInfo())
    }
}

// MARK: - Legal

protocol FetchLegalDocumentUseCaseProtocol {
    func callAsFunction(_ kind: LegalDocument.Kind) -> LegalDocument
}

struct FetchLegalDocumentUseCase: FetchLegalDocumentUseCaseProtocol {
    private let repository: LegalRepositoryProtocol

    init(repository: LegalRepositoryProtocol) {
        self.repository = repository
    }

    func callAsFunction(_ kind: LegalDocument.Kind) -> LegalDocument {
        repository.document(kind)
    }
}
