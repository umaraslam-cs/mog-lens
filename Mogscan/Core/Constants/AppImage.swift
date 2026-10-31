import Foundation

/// Asset catalog image names. Same role as ``AppSymbol``, for bundled artwork
/// rather than SF Symbols — views never spell an asset name inline.
enum AppImage {
    /// The brand mark: a landmark-mapped face inside scan brackets.
    static let logo = "Logo"
    /// Onboarding 03 hero. Cropped to the 402 × 330 slot; its lower third is
    /// dark so ``AppGradient/photoScrim`` blends into the background.
    static let haloPortrait = "HaloPortrait"
    /// Onboarding 07 frame. The landmark mesh is part of the artwork, so the
    /// slot renders static — nothing is drawn over it.
    static let technologyPortrait = "TechnologyPortrait"
    /// Onboarding Discover Face hero image.
    static let discoverFacePortrait = "DiscoverFacePortrait"
    /// Onboarding Personal Gap self-reported portrait image.
    static let personalGapPortrait = "PersonalGapPortrait"
    /// Onboarding Future Self 3D biometric mesh hero image.
    static let futureSelfMesh = "FutureSelfMesh"
    /// Onboarding Desired Result goal archetype images.
    static let goalBalanced = "GoalBalanced"
    static let goalDefined = "GoalDefined"
    static let goalRefined = "GoalRefined"
    static let goalHighImpact = "GoalHighImpact"
    /// Onboarding Facial Metrics Preview circular biometric mesh portrait image.
    static let facialMetricsPreview = "FacialMetricsPreviewGraphic"
    /// Onboarding Expert Perspective specialist avatar image.
    static let doctorFinchPortrait = "DoctorFinchPortrait"
    static let doctorWebbPortrait = "DoctorWebbPortrait"
}
