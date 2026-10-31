import SwiftUI

/// Fixed landmark layouts used by the two screens that draw an overlay.
/// Coordinates are unit-space, taken directly from the design.
///
/// In production these are replaced by the regions returned from
/// `VNDetectFaceLandmarksRequest`; the geometry below only exists so the
/// overlay renders identically before a real detection runs.
enum LandmarkLayout {

    // MARK: Analysing screen — twelve points behind the sweep

    static let analysing: [LandmarkPoint] = [
        .init(id: 0, x: 0.30, y: 0.28),
        .init(id: 1, x: 0.44, y: 0.26),
        .init(id: 2, x: 0.58, y: 0.26),
        .init(id: 3, x: 0.70, y: 0.28),
        .init(id: 4, x: 0.36, y: 0.36),
        .init(id: 5, x: 0.64, y: 0.36),
        .init(id: 6, x: 0.50, y: 0.50),
        .init(id: 7, x: 0.42, y: 0.62),
        .init(id: 8, x: 0.58, y: 0.62),
        .init(id: 9, x: 0.32, y: 0.74),
        .init(id: 10, x: 0.50, y: 0.82),
        .init(id: 11, x: 0.68, y: 0.74)
    ]

    static let analysingConnectors: [LandmarkConnector] = [
        .init(id: 0, from: CGPoint(x: 0.30, y: 0.28), to: CGPoint(x: 0.70, y: 0.28)),
        .init(id: 1, from: CGPoint(x: 0.50, y: 0.26), to: CGPoint(x: 0.50, y: 0.82)),
        // Jawline — the design tilts this connector 9°.
        .init(id: 2, from: CGPoint(x: 0.32, y: 0.74), to: CGPoint(x: 0.68, y: 0.79))
    ]

    // MARK: Results header — five points, quieter

    static let results: [LandmarkPoint] = [
        .init(id: 0, x: 0.38, y: 0.34),
        .init(id: 1, x: 0.62, y: 0.34),
        .init(id: 2, x: 0.50, y: 0.48),
        .init(id: 3, x: 0.40, y: 0.62),
        .init(id: 4, x: 0.60, y: 0.62)
    ]

    static let resultsConnectors: [LandmarkConnector] = [
        .init(id: 0, from: CGPoint(x: 0.38, y: 0.34), to: CGPoint(x: 0.62, y: 0.34)),
        .init(id: 1, from: CGPoint(x: 0.50, y: 0.34), to: CGPoint(x: 0.50, y: 0.62))
    ]
}
