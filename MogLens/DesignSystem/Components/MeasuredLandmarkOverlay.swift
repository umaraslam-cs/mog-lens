import SwiftUI

/// Draws real measured landmarks over a photo, falling back to the design's
/// fixed layout when there are none.
///
/// Sample scans and every `#Preview` carry no landmarks, so the overlay has to
/// keep rendering without them — that fallback is what keeps design review
/// possible away from a device.
struct MeasuredLandmarkOverlay: View {
    enum Density {
        /// Twelve points, four connectors — the analysing screen.
        case analysing
        /// Five points, two connectors — the results header.
        case results
    }

    let landmarks: FaceLandmarks?
    let imageSize: CGSize?
    var density: Density = .analysing
    var dotSize: CGFloat = 5
    var connectorOpacity: Double = 0.45

    var body: some View {
        GeometryReader { geometry in
            let projected = projection(in: geometry.size)

            LandmarkOverlay(
                points: projected.points,
                connectors: projected.connectors,
                dotSize: dotSize,
                connectorOpacity: connectorOpacity
            )
        }
    }

    private func projection(in slotSize: CGSize) -> LandmarkProjection.Projected {
        guard let landmarks, let imageSize else { return fallback }

        return switch density {
        case .analysing:
            LandmarkProjection.analysing(landmarks, imageSize: imageSize, in: slotSize)
        case .results:
            LandmarkProjection.results(landmarks, imageSize: imageSize, in: slotSize)
        }
    }

    private var fallback: LandmarkProjection.Projected {
        switch density {
        case .analysing:
            LandmarkProjection.Projected(
                points: LandmarkLayout.analysing,
                connectors: LandmarkLayout.analysingConnectors
            )
        case .results:
            LandmarkProjection.Projected(
                points: LandmarkLayout.results,
                connectors: LandmarkLayout.resultsConnectors
            )
        }
    }
}
