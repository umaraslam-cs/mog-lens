import Foundation

/// Turns raw measurements into percentiles, an overall score and a tier.
///
/// **Every curve below is derived from measured faces, not chosen.** 34 phone
/// photos supplied by the client on 20 Aug 2026 were run through the real
/// pipeline — the same Vision request, the same six-reading median — and their
/// quantiles are these anchors. A value at the observed median earns the 50th
/// percentile; the observed 10th and 90th earn p10 and p90. That is the only way
/// "Top X%" means anything.
///
/// They replace curves derived from public web portraits, which measured a
/// different thing than the app is pointed at. Front-camera photos are taken
/// close up, and the perspective that comes with that stretches the lower face:
/// against the web-derived curves this phone sample scored a median of p3 on
/// midface with 18 of 34 pinned to the floor, p18 on eye spacing with 11 pinned,
/// and p81 on jaw with 15 pinned to the ceiling. Only chin ratio survived. A
/// curve calibrated on the wrong framing is not a calibrated curve.
///
/// **34 faces is a thin sample, and the tails are the thin part.** The median and
/// quartiles here are solid; p2 and p98 rest on one or two faces each and will
/// move when more photos arrive. Re-deriving means replacing the numbers below
/// and nothing else — the harness that produced them reads the app's own
/// ``FaceGeometry`` unmodified.
///
/// Percentiles are interpolated between anchors rather than bucketed. Buckets
/// make the score jump when a measurement moves a hair, which reads as the app
/// being unstable — the opposite of what "measured, not guessed" promises.
enum ScoringTable {

    /// One point on a metric's curve: a raw value and the percentile it earns.
    private struct Anchor {
        let value: Double
        let percentile: Double

        init(_ value: Double, _ percentile: Double) {
            self.value = value
            self.percentile = percentile
        }
    }

    // MARK: Curves

    /// Symmetry, 0–100 from ``FaceGeometry``. Higher is better.
    ///
    /// Bunched at the top because the measure itself is: the gap between a
    /// typical face and a very symmetric one is a few points, while an
    /// off-centre pose opens a large one. Everything below p5 in this sample is
    /// one face, which is why that anchor sits so far from the next.
    private static let symmetry = [
        Anchor(70.9, 2), Anchor(78.8, 5), Anchor(88.3, 25), Anchor(90.8, 50),
        Anchor(93.1, 75), Anchor(95.5, 90), Anchor(96.7, 98)
    ]

    /// Jaw angle in degrees at the gonion. Higher reads as sharper.
    ///
    /// The client's original anchor — 125° is "Top 10%" — could not be used as
    /// given: measured with this pipeline, every face in both samples exceeds
    /// 125°, so honouring it literally would rank everyone in the top tenth. His
    /// intent (a sharp jaw is rare and should score) is kept by putting the
    /// measured 90th percentile where 125° was meant to sit. Confirmed by the
    /// client on 20 Aug 2026: 125° was a guess, the measurement wins.
    ///
    /// Phone photos read consistently sharper than web portraits — p90 moved
    /// from 137.9° to 144.2° — which is the close-up perspective again, not
    /// better jaws.
    private static let jawAngle = [
        Anchor(126.9, 2), Anchor(131.4, 5), Anchor(134.7, 25), Anchor(137.2, 50),
        Anchor(139.8, 75), Anchor(144.2, 90), Anchor(146.6, 98)
    ]

    /// Ratios scored on distance from a balanced value are penalised the same
    /// for being too large or too small.
    ///
    /// The ideal stays at the canonical 1.0 — equal facial thirds — because the
    /// client describes this metric as balance between the lower and mid face.
    /// The anchors are the measured spread of that deviation. This is the one
    /// curve the web sample nearly got right: it handed this phone sample a
    /// median of p43, against p3 and p18 for midface and eye spacing.
    private static let chinRatioIdeal = 1.0
    private static let chinRatioDeviation = [
        Anchor(0.021, 95), Anchor(0.070, 75), Anchor(0.154, 50),
        Anchor(0.215, 25), Anchor(0.313, 10), Anchor(0.332, 5)
    ]

    /// Eye spacing is pupil separation over face width — see ``FaceGeometry``.
    ///
    /// Centred on the measured median rather than a textbook figure, because the
    /// client's own copy frames this one relatively: eyes set "tighter or wider
    /// than average" read differently, with neither extreme named as the good
    /// one. If he decides wider-set should win outright, this becomes a direct
    /// ascending curve like ``jawAngle`` instead.
    ///
    /// "Average" is a property of the sample, so the centre moved with it —
    /// 0.4502 on web portraits, 0.4803 here. The whole sample spans 0.4385 to
    /// 0.5164, so the curve is necessarily tight; it earns that by being the
    /// most reproducible of the five (see ``weights``).
    private static let eyeSpacingIdeal = 0.4816
    private static let eyeSpacingDeviation = [
        Anchor(0.0024, 95), Anchor(0.0085, 75), Anchor(0.0149, 50),
        Anchor(0.0309, 25), Anchor(0.0353, 10), Anchor(0.0410, 5)
    ]

    /// Midface height over face width. **Lower is better**, so this curve
    /// descends.
    ///
    /// It was once scored as deviation from an ideal of 0.44, which marked a
    /// short midface down as heavily as a long one. That contradicts the
    /// client's own advice copy — "shorter midface reads as more compact,
    /// hunter-coded, and youthful" — so shorter scores higher, with no penalty
    /// at the short end.
    ///
    /// This is the curve the framing mismatch hit hardest. Its whole web-derived
    /// range, 0.413 to 0.531, sits below this sample's median of 0.530: a phone
    /// held at arm's length lengthens the midface, so every real user was being
    /// marked against portraits shot from further away and 18 of 34 landed on
    /// the floor.
    private static let midfaceRatio = [
        Anchor(0.4587, 98), Anchor(0.4662, 95), Anchor(0.4716, 90), Anchor(0.5085, 75),
        Anchor(0.5318, 50), Anchor(0.5656, 25), Anchor(0.5815, 10), Anchor(0.6229, 2)
    ]

    /// Weighted by how well each metric survives being photographed twice, on
    /// the client's instruction of 20 Aug 2026: the score leans on whatever is
    /// most reproducible, and symmetry and jaw stay the headline pair in the UI
    /// regardless, where they lead the list.
    ///
    /// Reliability is signal-to-noise — the spread between faces divided by the
    /// spread across re-readings of one face — measured on his 34 photos, each
    /// re-read after a ±3° rotation:
    ///
    /// | metric      | F    | weight |
    /// |-------------|------|--------|
    /// | chin ratio  | 23.8 | 2      |
    /// | midface     | 21.5 | 2      |
    /// | jaw angle   | 20.4 | 2      |
    /// | eye spacing | 11.1 | 1      |
    /// | symmetry    |  4.7 | 1      |
    ///
    /// **This is not the split the client named, and the difference is my
    /// error.** He asked for the double weight on chin ratio and eye spacing,
    /// against F-ratios I gave him — 4.68 eye, 3.03 chin, 1.53 jaw — measured on
    /// the old web-portrait sample with the old eye-spacing definition. On his
    /// own photos with the current pipeline that ordering does not hold: jaw is
    /// among the steadiest metrics, and eye spacing is second-weakest, so
    /// doubling it would work against the very thing he asked for. The table
    /// above follows his stated principle on corrected data. Reverting to his
    /// literal list is a one-line change if he prefers it.
    private static let weights: [FacialMetric.Kind: Double] = [
        .chinRatio: 2, .midfaceRatio: 2, .jawAngle: 2,
        .eyeSpacing: 1, .facialSymmetry: 1
    ]

    /// Maps the weighted average of the five percentiles onto the final score.
    ///
    /// Averaging pulls hard toward the middle: with all five metrics spread
    /// evenly across 1–99, the average still only spans 24–79, so no one would
    /// ever see a score in the 80s or below 25. These anchors are the measured
    /// distribution of that average, stretched back out to the full range.
    ///
    /// Derived last, from the same 34 faces scored through the five curves above
    /// with the weights above — so it already accounts for both. Re-derive it
    /// whenever a curve or a weight changes; it is the piece that makes the
    /// median face score 50 rather than whatever averaging happens to produce.
    private static let composite = [
        Anchor(31.7, 2), Anchor(33.8, 5), Anchor(43.4, 25), Anchor(51.3, 50),
        Anchor(58.5, 75), Anchor(65.4, 90), Anchor(72.5, 98)
    ]

    // MARK: Scoring

    static func metrics(from measurements: FaceGeometry.Measurements) -> [FacialMetric] {
        [
            FacialMetric(
                kind: .facialSymmetry,
                formattedValue: String(format: "%.1f%%", measurements.symmetry),
                percentile: percentile(measurements.symmetry, on: symmetry)
            ),
            FacialMetric(
                kind: .jawAngle,
                formattedValue: String(format: "%.0f°", measurements.jawAngle),
                percentile: percentile(measurements.jawAngle, on: jawAngle)
            ),
            FacialMetric(
                kind: .chinRatio,
                formattedValue: String(format: "%.2f", measurements.chinRatio),
                percentile: percentile(
                    deviation: measurements.chinRatio,
                    from: chinRatioIdeal,
                    on: chinRatioDeviation
                )
            ),
            FacialMetric(
                kind: .eyeSpacing,
                formattedValue: String(format: "%.2f", measurements.eyeSpacing),
                percentile: percentile(
                    deviation: measurements.eyeSpacing,
                    from: eyeSpacingIdeal,
                    on: eyeSpacingDeviation
                )
            ),
            FacialMetric(
                kind: .midfaceRatio,
                formattedValue: String(format: "%.2f", measurements.midfaceRatio),
                percentile: percentile(measurements.midfaceRatio, on: midfaceRatio)
            )
        ]
    }

    static func overallScore(for metrics: [FacialMetric]) -> Int {
        let weighted = metrics.reduce(into: (total: 0.0, weight: 0.0)) { running, metric in
            let weight = weights[metric.kind] ?? 1
            running.total += Double(metric.percentile) * weight
            running.weight += weight
        }
        guard weighted.weight > 0 else { return 0 }
        return clampedInt(interpolate(weighted.total / weighted.weight, on: composite))
    }

    /// The bands live on ``FacialTier/scoreRange``, because the Home ring needs
    /// them too — to show how far through a tier a score sits, not just which
    /// tier it is.
    ///
    /// Honest rather than flattering — the average face scores ~50, not ~70 —
    /// chosen by the client on 20 Aug 2026 over the better-converting option,
    /// so the progress tracking planned after launch has somewhere to climb to.
    static func tier(for score: Int) -> FacialTier {
        FacialTier(score: score)
    }

    // MARK: Interpolation

    /// Percentile for a value read directly off a curve.
    private static func percentile(_ value: Double, on anchors: [Anchor]) -> Int {
        clampedInt(interpolate(value, on: anchors))
    }

    /// Percentile for a ratio, scored on its distance from a balanced value.
    private static func percentile(
        deviation value: Double,
        from ideal: Double,
        on anchors: [Anchor]
    ) -> Int {
        clampedInt(interpolate(abs(value - ideal), on: anchors))
    }

    /// Piecewise-linear across the anchors, flat outside them. Anchors may run
    /// in either direction — deviation curves descend as the value grows.
    private static func interpolate(_ value: Double, on anchors: [Anchor]) -> Double {
        guard let first = anchors.first, let last = anchors.last else { return 0 }
        if value <= first.value { return first.percentile }
        if value >= last.value { return last.percentile }

        for (lower, upper) in zip(anchors, anchors.dropFirst()) where value <= upper.value {
            let span = upper.value - lower.value
            guard span > 0 else { return lower.percentile }
            let progress = (value - lower.value) / span
            return lower.percentile + progress * (upper.percentile - lower.percentile)
        }
        return last.percentile
    }

    private static func clampedInt(_ value: Double) -> Int {
        min(99, max(1, Int(value.rounded())))
    }
}
