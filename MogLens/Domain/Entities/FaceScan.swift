import Foundation

/// A completed facial analysis, stored locally. No account, no sync.
struct FaceScan: Identifiable, Hashable, Codable {
    let id: UUID
    let capturedAt: Date
    /// Overall score, 0–100.
    let overallScore: Int
    let tier: FacialTier
    let metrics: [FacialMetric]
    /// Whether the user's entitlement unlocks the result values.
    let isUnlocked: Bool
    /// Describes the photo that belongs in the thumbnail slot.
    let photoDescription: String
    /// One line summarising what carries the score, shown on the Home hero card.
    let summary: String
    /// e.g. "Better than 82% of men aged 21".
    let percentileSummary: String
    /// e.g. "front-on".
    let poseDescription: String
    /// Measured geometry, for the results overlay. Nil for sample data, which
    /// falls back to the fixed layout in `LandmarkLayout`.
    let landmarks: FaceLandmarks?
    /// Set when the head was turned far enough at capture to move the numbers.
    /// The scan still scores — it warns rather than blocks.
    let poseWarning: String?

    init(
        id: UUID = UUID(),
        capturedAt: Date,
        overallScore: Int,
        tier: FacialTier,
        metrics: [FacialMetric],
        isUnlocked: Bool = true,
        photoDescription: String,
        summary: String,
        percentileSummary: String,
        poseDescription: String,
        landmarks: FaceLandmarks? = nil,
        poseWarning: String? = nil
    ) {
        self.id = id
        self.capturedAt = capturedAt
        self.overallScore = overallScore
        self.tier = tier
        self.metrics = metrics
        self.isUnlocked = isUnlocked
        self.photoDescription = photoDescription
        self.summary = summary
        self.percentileSummary = percentileSummary
        self.poseDescription = poseDescription
        self.landmarks = landmarks
        self.poseWarning = poseWarning
    }

    /// Ring fill fraction, 0–1.
    var scoreProgress: Double { Double(overallScore) / 100 }

    /// The three metrics previewed on Home: symmetry, jaw angle, midface ratio.
    var previewMetrics: [FacialMetric] {
        let previewed: [FacialMetric.Kind] = [.facialSymmetry, .jawAngle, .midfaceRatio]
        return previewed.compactMap { kind in metrics.first { $0.kind == kind } }
    }

    /// The weakest metric — drives the Improve ordering.
    var weakestMetric: FacialMetric? { metrics.min { $0.percentile < $1.percentile } }
}
