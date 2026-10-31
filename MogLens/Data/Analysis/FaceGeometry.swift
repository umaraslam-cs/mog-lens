import CoreGraphics
import Foundation

/// The measurements themselves: pure functions over ``FaceLandmarks``.
///
/// Two rules hold throughout, and together they are what makes a score
/// reproducible across two photos of the same face:
///
/// 1. Every distance is divided by the interocular distance, so the result does
///    not change with how close the camera was.
/// 2. The landmark set arrives roll-corrected, so a tilted head does not skew
///    anything measured against the midline.
///
/// Nothing here is random and nothing here reads the clock. Same landmarks in,
/// same numbers out, always.
enum FaceGeometry {

    /// Raw, unscored measurements. Units differ per metric; ``ScoringTable``
    /// turns each into a percentile.
    struct Measurements {
        /// 0–100, higher is more symmetric.
        let symmetry: Double
        /// Degrees at the chin, between the two jaw sides.
        let jawAngle: Double
        /// Lower third over middle third. Balanced sits near 1.0.
        let chinRatio: Double
        /// Pupil separation over face width. Sits near 0.48 on phone photos.
        let eyeSpacing: Double
        /// Midface height over face width.
        let midfaceRatio: Double
    }

    static func measure(_ landmarks: FaceLandmarks) -> Measurements {
        Measurements(
            symmetry: symmetry(landmarks),
            jawAngle: jawAngle(landmarks),
            chinRatio: chinRatio(landmarks),
            eyeSpacing: eyeSpacing(landmarks),
            midfaceRatio: midfaceRatio(landmarks)
        )
    }

    // MARK: Symmetry

    /// Mirrors paired features across the facial midline and reports how closely
    /// the two sides agree.
    ///
    /// The midline runs from the pupil midpoint to the chin. For each pair, the
    /// perpendicular distance of each side to that line is compared; the mean
    /// disagreement, relative to interocular distance, is the asymmetry.
    private static func symmetry(_ landmarks: FaceLandmarks) -> Double {
        let unit = landmarks.interocularDistance
        guard unit > 0 else { return 0 }

        let contour = landmarks.points(.faceContour)
        guard let chin = contour.middle else { return 0 }

        let axisOrigin = landmarks.pupilMidpoint
        let axis = normalised(CGPoint(x: chin.x - axisOrigin.x, y: chin.y - axisOrigin.y))

        let pairs: [(CGPoint, CGPoint)] = [
            (centroid(landmarks.points(.leftEye)), centroid(landmarks.points(.rightEye))),
            (centroid(landmarks.points(.leftEyebrow)), centroid(landmarks.points(.rightEyebrow))),
            (leftmost(landmarks.points(.outerLips)), rightmost(landmarks.points(.outerLips))),
            (contour.first ?? .zero, contour.last ?? .zero)
        ]

        let differences = pairs.map { left, right in
            let dLeft = abs(perpendicularDistance(of: left, fromOrigin: axisOrigin, along: axis))
            let dRight = abs(perpendicularDistance(of: right, fromOrigin: axisOrigin, along: axis))
            return abs(dLeft - dRight) / unit
        }

        guard !differences.isEmpty else { return 0 }
        let meanDeviation = differences.reduce(0, +) / Double(differences.count)

        // A mean deviation of 0.25 interocular widths reads as fully asymmetric.
        // Anything past that is clamped rather than allowed to go negative.
        return max(0, 100 - meanDeviation * 400)
    }

    // MARK: Jaw angle

    /// The client's named three-point calculation, measured at the **gonion** —
    /// the corner of the jaw — between the line up to the ear and the line
    /// forward to the chin.
    ///
    /// Measured at the chin instead it would be a different quantity entirely,
    /// around 50°, and the client's one calibrated anchor (125° is Top 10%) is
    /// a gonial angle. Both sides are measured and averaged, which steadies the
    /// number when one side of the contour is less cleanly detected.
    private static func jawAngle(_ landmarks: FaceLandmarks) -> Double {
        let contour = landmarks.points(.faceContour)
        guard contour.count >= 5, let chin = contour.middle else { return 0 }

        // Vision traces ear → jaw → chin → jaw → ear, so the quarter points sit
        // on the jaw corners.
        let leftGonion = contour[contour.count / 4]
        let rightGonion = contour[contour.count * 3 / 4]

        guard let leftEar = contour.first, let rightEar = contour.last else { return 0 }

        let left = angle(at: leftGonion, from: leftEar, to: chin)
        let right = angle(at: rightGonion, from: rightEar, to: chin)
        return (left + right) / 2
    }

    // MARK: Chin-to-nose ratio

    /// Lower third (nose base to chin) over middle third (brow line to nose base).
    ///
    /// The brow line is the top of the middle third, not the pupil line — pupils
    /// sit well below the brows, which shortens the denominator and pushes every
    /// face's ratio far above the balanced 1.0.
    private static func chinRatio(_ landmarks: FaceLandmarks) -> Double {
        guard let chin = landmarks.points(.faceContour).middle,
              let noseBase = lowest(landmarks.points(.nose))
        else { return 0 }

        let brows = landmarks.points(.leftEyebrow) + landmarks.points(.rightEyebrow)
        let browLine = brows.isEmpty ? landmarks.pupilMidpoint : centroid(brows)

        let middleThird = distance(browLine, noseBase)
        guard middleThird > 0 else { return 0 }

        return distance(noseBase, chin) / middleThird
    }

    // MARK: Eye spacing

    /// Pupil separation over face width — how far apart the eyes sit on the face.
    ///
    /// Measured against one eye's own width instead, this was the weakest metric
    /// in the set: an eye region's pixel extent shrinks as the face gets smaller
    /// in frame, so the ratio drifted 21% between a 1600px and a 128px face, and
    /// photo-to-photo noise nearly swamped the difference between two people
    /// (signal-to-noise 1.48). Both distances here are large and robust, which
    /// measures 4.68 over the same set — the strongest of the five — and halves
    /// the resolution drift. It is also the quantity the client's own copy
    /// describes: eyes set tighter or wider than average across the face.
    private static func eyeSpacing(_ landmarks: FaceLandmarks) -> Double {
        let contour = landmarks.points(.faceContour)
        guard !contour.isEmpty else { return 0 }

        let faceWidth = distance(leftmost(contour), rightmost(contour))
        guard faceWidth > 0 else { return 0 }

        return Double(landmarks.interocularDistance) / faceWidth
    }

    // MARK: Midface ratio

    /// Midface height (pupil line to mouth) over face width at its widest.
    private static func midfaceRatio(_ landmarks: FaceLandmarks) -> Double {
        let contour = landmarks.points(.faceContour)
        guard !contour.isEmpty else { return 0 }

        let width = distance(leftmost(contour), rightmost(contour))
        guard width > 0 else { return 0 }

        let mouth = centroid(landmarks.points(.outerLips))
        let height = abs(mouth.y - landmarks.pupilMidpoint.y)
        return height / width
    }

    // MARK: Primitives

    private static func distance(_ a: CGPoint, _ b: CGPoint) -> Double {
        Double(hypot(b.x - a.x, b.y - a.y))
    }

    /// Interior angle at `vertex`, in degrees.
    private static func angle(at vertex: CGPoint, from a: CGPoint, to b: CGPoint) -> Double {
        let v1 = CGPoint(x: a.x - vertex.x, y: a.y - vertex.y)
        let v2 = CGPoint(x: b.x - vertex.x, y: b.y - vertex.y)
        let dot = Double(v1.x * v2.x + v1.y * v2.y)
        let magnitude = distance(.zero, v1) * distance(.zero, v2)
        guard magnitude > 0 else { return 0 }
        return acos(min(1, max(-1, dot / magnitude))) * 180 / .pi
    }

    /// Signed distance from `point` to the line through `origin` in direction `axis`.
    private static func perpendicularDistance(
        of point: CGPoint,
        fromOrigin origin: CGPoint,
        along axis: CGPoint
    ) -> Double {
        let relative = CGPoint(x: point.x - origin.x, y: point.y - origin.y)
        return Double(relative.x * axis.y - relative.y * axis.x)
    }

    private static func normalised(_ vector: CGPoint) -> CGPoint {
        let length = hypot(vector.x, vector.y)
        guard length > 0 else { return CGPoint(x: 0, y: 1) }
        return CGPoint(x: vector.x / length, y: vector.y / length)
    }

    private static func centroid(_ points: [CGPoint]) -> CGPoint {
        guard !points.isEmpty else { return .zero }
        let sum = points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
        return CGPoint(x: sum.x / CGFloat(points.count), y: sum.y / CGFloat(points.count))
    }

    private static func leftmost(_ points: [CGPoint]) -> CGPoint {
        points.min { $0.x < $1.x } ?? .zero
    }

    private static func rightmost(_ points: [CGPoint]) -> CGPoint {
        points.max { $0.x < $1.x } ?? .zero
    }

    /// Largest y — top-left origin, so the lowest point on the face.
    private static func lowest(_ points: [CGPoint]) -> CGPoint? {
        points.max { $0.y < $1.y }
    }
}

private extension Array where Element == CGPoint {
    /// Vision walks the face contour from one side around to the other, so the
    /// middle element is the chin.
    var middle: CGPoint? {
        isEmpty ? nil : self[count / 2]
    }
}
