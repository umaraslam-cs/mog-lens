import Foundation

/// The onboarding steps, in order. Drives the progress indicator.
enum OnboardingStep: Int, CaseIterable, Identifiable, Hashable {
    case discoverFace
    case haloEffect
    case whyItMatters
    case selfRating
    case personalGap
    case futureSelf
    case desiredResult
    case biggestConcern
    case age
    case technology
    case facialMetricsPreview
    case scanPreparation
    case targetRank
    case socialProof

    var id: Int { rawValue }

    /// 1-based index used by the progress indicator.
    var stepNumber: Int { rawValue + 1 }

    static var totalSteps: Int { allCases.count }

    var next: OnboardingStep? { OnboardingStep(rawValue: rawValue + 1) }
    var previous: OnboardingStep? { OnboardingStep(rawValue: rawValue - 1) }
}

/// A preparation guideline tip on the Scan Preparation step.
struct ScanPreparationTip: Identifiable, Hashable {
    let id: Int
    let symbol: String
    let title: String
    let subtitle: String
}

/// An academic research card on facial judgments and first impressions.
struct ResearchCard: Identifiable, Hashable {
    let id: Int
    let headline: String
    var quote: String? = nil
    let attribution: String
    let footer: String
}

/// A verified user review card for the Social Proof onboarding step.
struct SocialReview: Identifiable, Hashable {
    let id: Int
    let avatarSymbol: String
    let name: String
    let badge: String
    let quote: String
    let footerLeft: String
    let footerRight: String
}

/// A clinical expert card for the Expert Perspective onboarding step.
struct ExpertCard: Identifiable, Hashable {
    let id: Int
    let name: String
    let role: String
    let credentials: String
    let quote: String
    var imageName: String? = nil
}

/// A metric preview item on the Facial Metrics preview step with concise looksmaxing details.
struct FacialMetricTeaser: Identifiable, Hashable {
    let id: Int
    let symbol: String
    let title: String
    let detail: String
    let value: String
}

/// A bulleted point on the "Why it matters" step.
struct ValueProposition: Identifiable, Hashable {
    let id: Int
    let symbol: String
    var eyebrow: String? = nil
    let title: String
    let detail: String
}

/// A capability listed on the Technology step.
struct TechnologyClaim: Identifiable, Hashable {
    let id: Int
    var number: String? = nil
    let symbol: String
    let title: String
    let detail: String
}

/// Aesthetic goal archetype selected on the "Desired Result" step.
enum GoalArchetype: String, CaseIterable, Identifiable, Hashable {
    case defined
    case balanced
    case refined
    case highImpact
    case notSureYet

    var id: String { rawValue }

    var title: String {
        switch self {
        case .defined: "Defined"
        case .balanced: "Balanced"
        case .refined: "Refined"
        case .highImpact: "High Impact"
        case .notSureYet: "Not Sure Yet"
        }
    }

    var subtitle: String {
        switch self {
        case .defined: "Sharper contours and enhanced angular jawline"
        case .balanced: "Natural facial harmony and proportional symmetry"
        case .refined: "Subtle symmetry and smooth facial transitions"
        case .highImpact: "Maximum structural definition and prominent features"
        case .notSureYet: "Analyze my facial structure and recommend the best fit"
        }
    }

    var imageName: String? {
        switch self {
        case .balanced: AppImage.goalBalanced
        case .defined: AppImage.goalDefined
        case .refined: AppImage.goalRefined
        case .highImpact: AppImage.goalHighImpact
        case .notSureYet: nil
        }
    }
}

/// Focus areas for improvement selected on the "Biggest Concern" step.
enum ImprovementArea: String, CaseIterable, Identifiable, Hashable {
    case jawline
    case eyes
    case cheekbones
    case skin
    case symmetry
    case hair
    case harmony
    case notSure

    var id: String { rawValue }

    var title: String {
        switch self {
        case .jawline: "JAWLINE"
        case .eyes: "EYES"
        case .cheekbones: "CHEEKBONES"
        case .skin: "SKIN"
        case .symmetry: "SYMMETRY"
        case .hair: "HAIR"
        case .harmony: "HARMONY"
        case .notSure: "NOT SURE"
        }
    }

    /// Contextual SF Symbols aligned with Mogscan's biometric and geometric design language
    var symbol: String {
        switch self {
        case .jawline: "angle"
        case .eyes: "eye.fill"
        case .cheekbones: "diamond.fill"
        case .skin: "drop.fill"
        case .symmetry: "square.split.2x1"
        case .hair: "scissors"
        case .harmony: "circle.grid.cross.fill"
        case .notSure: "questionmark.circle.fill"
        }
    }
}

