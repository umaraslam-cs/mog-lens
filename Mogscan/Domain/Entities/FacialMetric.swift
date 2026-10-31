import Foundation

/// One geometric measurement produced by a scan.
///
/// Values are pre-formatted because their units differ per metric — a percentage
/// for symmetry, degrees for jaw angle, a bare ratio for the rest.
struct FacialMetric: Identifiable, Hashable, Codable {
    enum Kind: String, CaseIterable, Hashable, Codable {
        case facialSymmetry = "Facial Symmetry"
        case jawAngle = "Jaw Angle"
        case chinRatio = "Chin Ratio"
        case eyeSpacing = "Eye Spacing"
        case midfaceRatio = "Midface Ratio"

        var name: String { rawValue }

        /// Shortened label used in the compact Home preview.
        var shortName: String {
            switch self {
            case .facialSymmetry: "Symmetry"
            case .jawAngle: "Jaw Angle"
            case .chinRatio: "Chin Ratio"
            case .eyeSpacing: "Eye Spacing"
            case .midfaceRatio: "Midface Ratio"
            }
        }

        /// Icon used wherever a metric is listed rather than measured — the
        /// advice cards on Results and Improve.
        var symbol: String {
            switch self {
            case .facialSymmetry: AppSymbol.symmetry
            case .jawAngle: AppSymbol.jawAngle
            case .chinRatio: AppSymbol.chinRatio
            case .eyeSpacing: AppSymbol.eyeSpacing
            case .midfaceRatio: AppSymbol.midfaceRatio
            }
        }
    }

    let kind: Kind
    /// Display-ready value including its unit, e.g. `96.4%`, `118°`, `0.94`.
    let formattedValue: String
    /// 0–100.
    let percentile: Int

    var id: Kind { kind }
    var name: String { kind.name }
    var rating: MetricRating { MetricRating(percentile: percentile) }
    /// Progress fraction for the bar, 0–1.
    var progress: Double { Double(percentile) / 100 }
    /// Share of people this beats, phrased as the client's brief specifies:
    /// "a percentile ranking, such as Top X%".
    ///
    /// The same score reads better this way — "Top 12%" lands harder than "88th
    /// percentile" — which matters on a screen selling a subscription. The
    /// rating label carries the qualitative read, so a weak metric still says
    /// so rather than hiding behind a large number.
    var topPercentage: Int { max(1, 100 - percentile) }

    /// Ranking phrase: "Top 12%" above the median, "Bottom 8%" below it.
    ///
    /// Always phrasing it as "Top X%" is what the brief's example shows, but it
    /// inverts on a weak metric — a 8th-percentile result would read "Top 92%",
    /// which sounds like praise for the worst score on the screen. Flipping to
    /// "Bottom X%" below the median keeps the client's phrasing where it works
    /// and stays honest where it doesn't.
    var rankingText: String {
        percentile >= 50 ? "Top \(topPercentage)%" : "Bottom \(percentile)%"
    }

    /// e.g. "Top 12% · Excellent".
    var percentileCaption: String { "\(rankingText) · \(rating.label)" }

    /// One accessibility label carrying value, ranking and rating together.
    var accessibilityDescription: String {
        "\(name), \(formattedValue), \(rankingText), \(rating.label)"
    }
}
