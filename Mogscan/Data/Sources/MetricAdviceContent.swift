import Foundation

/// The advice lookup table, supplied by the client on 15 Aug 2026.
///
/// **Verbatim client copy.** Wording is his, including the community framing
/// ("hunter vs prey", "chad vs average"); it is not to be rewritten. Only the
/// band boundaries were changed, and only as he asked: he wrote the three bands
/// against placeholder ranges (0–40 / 40–70 / 70–100) and said to move them onto
/// whatever the real thresholds turned out to be. They now sit on
/// ``MetricRating`` — < 40 needs improvement, 40–74 average, ≥ 75 excellent —
/// which is the same boundary the bars are already coloured on.
///
/// Nothing here is generated or personalised. A scan picks a row; it never
/// writes one.
enum MetricAdviceContent {

    static func advice(for kind: FacialMetric.Kind, rating: MetricRating) -> MetricAdvice {
        MetricAdvice(
            metric: kind,
            rating: rating,
            whyItMatters: whyItMatters(kind),
            tips: tips(kind, rating)
        )
    }

    // MARK: Why it matters

    /// Constant per metric — the same line whatever the score.
    private static func whyItMatters(_ kind: FacialMetric.Kind) -> String {
        switch kind {
        case .facialSymmetry:
            "Symmetry affects how balanced a face reads at a glance - it's one of the first things perceived, even subconsciously."
        case .jawAngle:
            "Jaw definition is one of the most immediately noticeable structural traits, tied closely to perceived masculinity/sharpness."
        case .chinRatio:
            "This ratio is a key driver of how balanced the lower and mid face appear together."
        case .eyeSpacing:
            "Eye spacing is one of the biggest factors in how 'hunter vs prey' a face reads - tighter or wider than average changes perceived intensity."
        case .midfaceRatio:
            "Midface length is a core 'chad vs average' signal in the community - shorter midface reads as more compact, hunter-coded, and youthful."
        }
    }

    // MARK: Tips

    private static func tips(_ kind: FacialMetric.Kind, _ rating: MetricRating) -> [String] {
        switch (kind, rating) {

        case (.facialSymmetry, .needsImprovement):
            [
                "Sleeping on your back rather than one side can stop asymmetry worsening.",
                "Jaw clenching and teeth grinding pull the jawline out of alignment over months — a night guard helps."
            ]
        case (.facialSymmetry, .average):
            [
                "Posture matters more than people think — chin-forward posture from phone and laptop use visually skews balance.",
                "Chewing evenly on both sides keeps jaw muscle development balanced."
            ]
        case (.facialSymmetry, .excellent):
            [
                "Already a strong percentile — maintenance only: consistent sleep position, no one-sided chewing."
            ]

        case (.jawAngle, .needsImprovement):
            [
                "Mewing — tongue on the roof of the mouth — consistently over months, not days.",
                "Reducing body fat percentage usually has the single biggest visible impact."
            ]
        case (.jawAngle, .average):
            [
                "Jaw exercises — gum, resistance trainers — over 2–3 months of consistency.",
                "Hydration reduces the facial water retention that softens the apparent angle."
            ]
        case (.jawAngle, .excellent):
            [
                "Grooming: beard shaping, and a hairstyle that doesn't compete with jaw visibility."
            ]

        case (.chinRatio, .needsImprovement):
            [
                "Mostly structural and bone-based, so it responds less to lifestyle change — good posture stops it looking worse than it is.",
                "A well-groomed beard can visually balance chin proportion."
            ]
        case (.chinRatio, .average):
            [
                "Nothing drastic — a hairstyle with volume and length variation subtly shifts proportion perception."
            ]
        case (.chinRatio, .excellent):
            [
                "Already working in your favour — keep facial hair well-maintained, it interacts directly with this feature."
            ]

        case (.eyeSpacing, .needsImprovement):
            [
                "Almost entirely structural — genetics call the shots, so spend the effort on skin, jaw and grooming instead.",
                "Strong brow grooming reframes how spacing reads at a glance."
            ]
        case (.eyeSpacing, .average):
            [
                "Close to the sweet spot — hooded or tired-looking eyes throw off perceived spacing, so sleep and hydration genuinely pull weight.",
                "A slightly lower, more textured brow shape tightens the visual gap."
            ]
        case (.eyeSpacing, .excellent):
            [
                "Already working for you, low-maintenance — just don't let brow grooming drift into over-plucked territory."
            ]

        case (.midfaceRatio, .needsImprovement):
            [
                "Mostly bone structure, so lifestyle won't shrink it — consistent mewing tightens the surrounding muscle over time.",
                "Avoid hairstyles with lots of forehead exposure, they stretch the midface visually."
            ]
        case (.midfaceRatio, .average):
            [
                "Solid range — facial fat loss is the biggest lever left.",
                "A well-placed hairline or fringe visually shortens midface perception."
            ]
        case (.midfaceRatio, .excellent):
            [
                "A genuine strength, part of the \"compact\" hunter look — keep facial leanness up to preserve it."
            ]
        }
    }
}
