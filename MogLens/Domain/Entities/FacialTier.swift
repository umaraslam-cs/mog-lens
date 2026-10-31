import Foundation

/// The five facial tiers the product ranks against.
enum FacialTier: String, CaseIterable, Identifiable, Hashable, Codable, Comparable {
    case ltn = "LTN"
    case mtn = "MTN"
    case htn = "HTN"
    case chadLite = "Chad Lite"
    case chad = "Chad"

    var id: String { rawValue }

    /// Case order *is* the tier ladder: LTN < MTN < HTN < Chad Lite < Chad.
    /// Ranked off the score band rather than the case index so the ladder can
    /// never drift from the bands a score is actually read against.
    static func < (lhs: FacialTier, rhs: FacialTier) -> Bool {
        lhs.scoreRange.lowerBound < rhs.scoreRange.lowerBound
    }

    /// The score band this tier covers.
    ///
    /// The one place these numbers live: both which tier a score earns and how
    /// far through that tier it sits are read from here. ``ScoringTable`` spreads
    /// the score evenly across 1–99, so the widths set how rare each tier is
    /// directly — Chad the top 5%, Chad Lite the next 15%, HTN the next 25%.
    var scoreRange: ClosedRange<Int> {
        switch self {
        case .ltn: 0...24
        case .mtn: 25...54
        case .htn: 55...79
        case .chadLite: 80...94
        case .chad: 95...100
        }
    }

    /// The tier a score earns.
    init(score: Int) {
        self = FacialTier.allCases.last { score >= $0.scoreRange.lowerBound } ?? .ltn
    }

    /// Label shown inside a tier badge.
    var displayName: String { rawValue }

    /// Visual weight of the badge, ascending with the tier.
    var emphasis: Emphasis {
        switch self {
        case .ltn: .quiet
        case .mtn: .neutral
        case .htn: .accent
        case .chadLite: .accentGlow
        case .chad: .peak
        }
    }

    enum Emphasis {
        /// Translucent surface, secondary text.
        case quiet
        /// Translucent surface, primary text.
        case neutral
        /// Accent gradient fill.
        case accent
        /// Accent gradient fill with a glow.
        case accentGlow
        /// Brightened gradient with a stronger glow.
        case peak
    }
}
