import Foundation

/// One line of the analysing checklist. Steps tick over as real Vision requests
/// complete — there are no fake timers behind them.
struct AnalysisStep: Identifiable, Hashable {
    enum State: Hashable {
        case completed
        case inProgress
        case pending
    }

    let id: Int
    let title: String
    var state: State
}

/// A capture guideline shown on the Scan entry screen.
struct CaptureGuideline: Identifiable, Hashable {
    let id: Int
    let symbol: String
    let text: String
}
