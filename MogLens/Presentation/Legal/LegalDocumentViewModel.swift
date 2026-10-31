import Foundation

/// Backs the Privacy Policy and Terms of Use sheet. One view model serves
/// both — the ``LegalDocument/Kind`` passed to ``load(_:)`` picks the copy.
@Observable
final class LegalDocumentViewModel {
    private(set) var document: LegalDocument?

    private let fetchLegalDocument: FetchLegalDocumentUseCaseProtocol

    init(fetchLegalDocument: FetchLegalDocumentUseCaseProtocol) {
        self.fetchLegalDocument = fetchLegalDocument
    }

    convenience init(dependencies: AppDependencies) {
        self.init(fetchLegalDocument: dependencies.fetchLegalDocument)
    }

    func load(_ kind: LegalDocument.Kind) {
        document = fetchLegalDocument(kind)
    }
}
