import Foundation

/// Sample scans matching the values printed in the design.
///
/// Replaced wholesale once `VNDetectFaceLandmarksRequest` feeds the real store —
/// this exists so every screen renders with the exact numbers the design shows.
enum SampleScans {

    /// 12 Mar 2026, 09:24 — the scan shown on Home and Results.
    static let latest = FaceScan(
        capturedAt: date(day: 12, month: 3, year: 2026, hour: 9, minute: 24),
        overallScore: 81,
        tier: .htn,
        metrics: [
            FacialMetric(kind: .facialSymmetry, formattedValue: "96.4%", percentile: 88),
            FacialMetric(kind: .jawAngle, formattedValue: "118°", percentile: 84),
            FacialMetric(kind: .chinRatio, formattedValue: "0.94", percentile: 57),
            FacialMetric(kind: .eyeSpacing, formattedValue: "0.41", percentile: 29),
            // The design prints this metric's percentile (61) on Home but not its
            // raw value; 1.02 is a placeholder until Vision supplies the real one.
            FacialMetric(kind: .midfaceRatio, formattedValue: "1.02", percentile: 61)
        ],
        photoDescription: DesignContent.Results.photo,
        summary: "Top 18% for your age. Jaw and symmetry carry the score.",
        percentileSummary: "Better than 82% of men aged 21",
        poseDescription: "front-on"
    )

    /// 28 Feb 2026, 18:02 — the second history row.
    static let previous = FaceScan(
        capturedAt: date(day: 28, month: 2, year: 2026, hour: 18, minute: 2),
        overallScore: 76,
        tier: .mtn,
        metrics: [
            FacialMetric(kind: .facialSymmetry, formattedValue: "94.1%", percentile: 79),
            FacialMetric(kind: .jawAngle, formattedValue: "121°", percentile: 72),
            FacialMetric(kind: .chinRatio, formattedValue: "0.91", percentile: 51),
            FacialMetric(kind: .eyeSpacing, formattedValue: "0.40", percentile: 26),
            FacialMetric(kind: .midfaceRatio, formattedValue: "1.04", percentile: 55)
        ],
        photoDescription: "Previous scan photo",
        summary: "Symmetry carries the score; the lower third lags.",
        percentileSummary: "Better than 74% of men aged 21",
        poseDescription: "front-on"
    )

    static let history: [FaceScan] = [latest, previous]

    private static func date(day: Int, month: Int, year: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        components.hour = hour
        components.minute = minute
        return Calendar(identifier: .gregorian).date(from: components) ?? .now
    }
}

/// Shared date formatting for scan timestamps.
enum ScanDateFormatter {
    /// "12 Mar 2026".
    static func long(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }

    /// "12 Mar".
    static func short(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }

    /// "09:24".
    static func time(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    /// "12 Mar, 09:24".
    static func summary(_ date: Date) -> String {
        "\(short(date)), \(time(date))"
    }
}
