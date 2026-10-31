import Foundation

/// How a metric reads against its age cohort.
///
/// Thresholds: ≥ 75th green · 40–74th amber · < 40th red.
/// Colour never carries meaning alone — the percentile label repeats it.
enum MetricRating: String, CaseIterable, Hashable {
    case excellent = "Excellent"
    case average = "Average"
    case needsImprovement = "Needs improvement"

    /// Derives the rating from a percentile, 0–100.
    init(percentile: Int) {
        switch percentile {
        case 75...: self = .excellent
        case 40..<75: self = .average
        default: self = .needsImprovement
        }
    }

    var label: String { rawValue }
}
