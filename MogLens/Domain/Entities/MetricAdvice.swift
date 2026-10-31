import Foundation

/// Client-written advice for one metric at one score band.
///
/// Keyed metric × ``MetricRating`` rather than metric × an advice-only band of
/// its own: the client supplied three bands per metric against placeholder
/// ranges (0–40 / 40–70 / 70–100) and asked that they be moved onto the real
/// scoring thresholds. `MetricRating` already carries those — < 40 / 40–74 /
/// ≥ 75 — and already colours the bars, so reusing it keeps the advice a user
/// reads and the colour they see on the same boundary.
struct MetricAdvice: Identifiable, Hashable {
    let metric: FacialMetric.Kind
    let rating: MetricRating
    /// Why the metric matters at all. Constant across the three bands.
    let whyItMatters: String
    /// Concrete actions for this band, in the client's own words.
    let tips: [String]

    var id: FacialMetric.Kind { metric }
    var title: String { metric.name }
    var symbol: String { metric.symbol }
}
