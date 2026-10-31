import CoreGraphics

/// Facial landmark geometry, normalised for measurement.
///
/// Points are in **square space** with a top-left origin: y runs 0...1 down the
/// image, and x is measured in the same units — image width over height — so it
/// runs 0...``imageAspect``. Vision's own space is normalised separately on each
/// axis, which silently stretches every distance and angle on a photo that is
/// not square. Squaring up here, once, is what makes an angle mean degrees.
///
/// Vision also hands back points relative to the face bounding box, in a
/// bottom-left space. That conversion happens at the same edge, so nothing
/// downstream reasons about coordinate systems at all.
///
/// The set is also roll-corrected: it has been rotated so the line between the
/// pupils is horizontal. Together with dividing every distance by the
/// interocular distance, that is what makes a measurement reproducible across
/// two photos of the same face — the client's stated requirement.
struct FaceLandmarks: Hashable, Codable {

    struct Region: Hashable, Codable {
        /// Only the regions something actually measures or draws. Vision returns
        /// more; add a case when a metric needs it.
        /// Raw values are the on-disk encoding of a stored scan, so they are
        /// spelled out rather than derived from the case names.
        enum Kind: String, Hashable, Codable {
            case faceContour = "faceContour"
            case leftEye = "leftEye"
            case rightEye = "rightEye"
            case leftEyebrow = "leftEyebrow"
            case rightEyebrow = "rightEyebrow"
            /// `noseCrest` is the ridge, used to estimate head turn.
            case nose = "nose"
            case noseCrest = "noseCrest"
            case outerLips = "outerLips"
        }

        let kind: Kind
        let points: [CGPoint]
    }

    /// Face bounds in image space, top-left origin, x and y both 0...1.
    let boundingBox: CGRect
    /// Source image width over height. Divide a point's x by this to get back
    /// to image-normalised space for drawing.
    let imageAspect: CGFloat
    let regions: [Region]
    let leftPupil: CGPoint
    let rightPupil: CGPoint
    /// Head roll in degrees, as measured before correction. Reported for
    /// diagnostics; the points above already have it removed.
    let roll: Double
    /// Estimated head turn in degrees. Positive and negative are opposite
    /// directions; only the magnitude is used, to warn about off-angle photos.
    let yaw: Double

    /// Landmark points in unlevelled image space (0...1 on both axes, top-left origin),
    /// matching the raw photo before roll-leveling. Used for precise UI overlays.
    var unlevelledRegions: [Region]? = nil
    var unlevelledLeftPupil: CGPoint? = nil
    var unlevelledRightPupil: CGPoint? = nil

    func points(_ kind: Region.Kind) -> [CGPoint] {
        regions.first { $0.kind == kind }?.points ?? []
    }

    /// Returns unlevelled image-space points in 0...1 normalized space.
    func unlevelledPoints(_ kind: Region.Kind) -> [CGPoint] {
        if let pts = unlevelledRegions?.first(where: { $0.kind == kind })?.points, !pts.isEmpty {
            return pts
        }
        return points(kind).map { CGPoint(x: $0.x / imageAspect, y: $0.y) }
    }

    var rawLeftPupil: CGPoint {
        unlevelledLeftPupil ?? CGPoint(x: leftPupil.x / imageAspect, y: leftPupil.y)
    }

    var rawRightPupil: CGPoint {
        unlevelledRightPupil ?? CGPoint(x: rightPupil.x / imageAspect, y: rightPupil.y)
    }

    /// Pupil-to-pupil distance. The unit every other measurement is divided by.
    var interocularDistance: CGFloat {
        hypot(rightPupil.x - leftPupil.x, rightPupil.y - leftPupil.y)
    }

    var pupilMidpoint: CGPoint {
        CGPoint(x: (leftPupil.x + rightPupil.x) / 2, y: (leftPupil.y + rightPupil.y) / 2)
    }
}
