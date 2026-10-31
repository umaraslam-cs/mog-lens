import Foundation

/// A legal document rendered by one screen — Privacy Policy or Terms of Use.
/// Both read identically, so ``Kind`` selects the copy rather than the layout.
struct LegalDocument: Identifiable, Hashable {

    /// The two documents the app ships. `Identifiable` so it can drive `.sheet(item:)`.
    enum Kind: String, Identifiable, Hashable, CaseIterable {
        case privacy
        case terms

        var id: String { rawValue }
    }

    /// One heading plus its paragraph.
    struct Section: Identifiable, Hashable {
        let id: Int
        let heading: String
        let body: String
    }

    let kind: Kind
    let title: String
    /// Already formatted for display, e.g. "Last updated 9 August 2026".
    let lastUpdated: String
    /// Lead paragraph, shown above the first heading.
    let summary: String
    let sections: [Section]

    var id: Kind { kind }
}
