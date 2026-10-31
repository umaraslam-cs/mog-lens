import Foundation

/// Difficulty of a recommendation. Optional — two categories ship without one.
enum RecommendationDifficulty: String, Hashable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var label: String { rawValue }
}

/// A static, hand-written improvement card. Never AI-generated.
struct Recommendation: Identifiable, Hashable {
    enum Category: String, CaseIterable, Hashable {
        case skincare = "Skincare"
        case posture = "Posture"
        case jawExercises = "Jaw Exercises"
        case sleep = "Sleep"
        case hydration = "Hydration"
        case grooming = "Grooming"
        case lifestyle = "Lifestyle"

        var title: String { rawValue }

        var symbol: String {
            switch self {
            case .skincare: AppSymbol.skincare
            case .posture: AppSymbol.posture
            case .jawExercises: AppSymbol.jawExercises
            case .sleep: AppSymbol.sleep
            case .hydration: AppSymbol.hydration
            case .grooming: AppSymbol.grooming
            case .lifestyle: AppSymbol.lifestyle
            }
        }
    }

    let category: Category
    let detail: String
    let difficulty: RecommendationDifficulty?
    /// Estimated time, e.g. "5 min / day". Optional.
    let timeCommitment: String?

    var id: Category { category }
    var title: String { category.title }
    var symbol: String { category.symbol }
}
