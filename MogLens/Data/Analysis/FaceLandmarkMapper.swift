import CoreGraphics
import Foundation
import Vision

/// Converts a `VNFaceObservation` into ``FaceLandmarks``.
///
/// This is the step that quietly corrupts everything downstream if it is wrong,
/// because bad coordinates still produce plausible-looking numbers. Two traps:
///
/// - Vision's landmark points are normalised **to the face bounding box**, not
///   to the image. They have to be scaled into the box before they mean anything.
/// - Vision's origin is bottom-left; the app's is top-left. The y flip happens
///   here, once, so no view or measurement has to think about it.
///
/// Verify by drawing the overlay before trusting a single measurement.
enum FaceLandmarkMapper {

    static func map(_ observation: VNFaceObservation, imageSize: CGSize) -> FaceLandmarks? {
        guard let landmarks = observation.landmarks,
              imageSize.width > 0, imageSize.height > 0
        else { return nil }

        let box = observation.boundingBox
        /// Bounding box in top-left space, both axes 0...1.
        let imageBox = CGRect(
            x: box.minX,
            y: 1 - box.maxY,
            width: box.width,
            height: box.height
        )

        // x is scaled into the same units as y — see ``FaceLandmarks``. Without
        // this every distance and angle is stretched by the image's aspect ratio,
        // and the numbers still look entirely reasonable.
        let aspect = imageSize.width / imageSize.height

        func convert(_ region: VNFaceLandmarkRegion2D?) -> [CGPoint] {
            (region?.normalizedPoints ?? []).map { point in
                CGPoint(
                    x: (box.minX + point.x * box.width) * aspect,
                    y: 1 - (box.minY + point.y * box.height)
                )
            }
        }

        func convertRaw(_ region: VNFaceLandmarkRegion2D?) -> [CGPoint] {
            (region?.normalizedPoints ?? []).map { point in
                CGPoint(
                    x: box.minX + point.x * box.width,
                    y: 1 - (box.minY + point.y * box.height)
                )
            }
        }

        let leftEye = convert(landmarks.leftEye)
        let rightEye = convert(landmarks.rightEye)
        guard !leftEye.isEmpty, !rightEye.isEmpty else { return nil }

        // Vision reports pupils only sometimes; the eye centroid is equivalent
        // for our purposes and always available.
        let leftPupil = convert(landmarks.leftPupil).first ?? centroid(leftEye)
        let rightPupil = convert(landmarks.rightPupil).first ?? centroid(rightEye)

        let regions: [FaceLandmarks.Region] = [
            .init(kind: .faceContour, points: convert(landmarks.faceContour)),
            .init(kind: .leftEye, points: leftEye),
            .init(kind: .rightEye, points: rightEye),
            .init(kind: .leftEyebrow, points: convert(landmarks.leftEyebrow)),
            .init(kind: .rightEyebrow, points: convert(landmarks.rightEyebrow)),
            .init(kind: .nose, points: convert(landmarks.nose)),
            .init(kind: .noseCrest, points: convert(landmarks.noseCrest)),
            .init(kind: .outerLips, points: convert(landmarks.outerLips))
        ]

        let rawLeftEye = convertRaw(landmarks.leftEye)
        let rawRightEye = convertRaw(landmarks.rightEye)
        let rawLeftPupil = convertRaw(landmarks.leftPupil).first ?? centroid(rawLeftEye)
        let rawRightPupil = convertRaw(landmarks.rightPupil).first ?? centroid(rawRightEye)

        let rawRegions: [FaceLandmarks.Region] = [
            .init(kind: .faceContour, points: convertRaw(landmarks.faceContour)),
            .init(kind: .leftEye, points: rawLeftEye),
            .init(kind: .rightEye, points: rawRightEye),
            .init(kind: .leftEyebrow, points: convertRaw(landmarks.leftEyebrow)),
            .init(kind: .rightEyebrow, points: convertRaw(landmarks.rightEyebrow)),
            .init(kind: .nose, points: convertRaw(landmarks.nose)),
            .init(kind: .noseCrest, points: convertRaw(landmarks.noseCrest)),
            .init(kind: .outerLips, points: convertRaw(landmarks.outerLips))
        ]

        // Roll comes off the interpupillary line and is removed from every point,
        // so a tilted head does not skew anything measured against the midline.
        let roll = atan2(
            Double(rightPupil.y - leftPupil.y),
            Double(rightPupil.x - leftPupil.x)
        ) * 180 / .pi

        let pivot = CGPoint(
            x: (leftPupil.x + rightPupil.x) / 2,
            y: (leftPupil.y + rightPupil.y) / 2
        )

        let levelled = regions.map { region in
            FaceLandmarks.Region(
                kind: region.kind,
                points: region.points.map { rotate($0, around: pivot, byDegrees: -roll) }
            )
        }

        let levelledLeftPupil = rotate(leftPupil, around: pivot, byDegrees: -roll)
        let levelledRightPupil = rotate(rightPupil, around: pivot, byDegrees: -roll)

        return FaceLandmarks(
            boundingBox: imageBox,
            imageAspect: aspect,
            regions: levelled,
            leftPupil: levelledLeftPupil,
            rightPupil: levelledRightPupil,
            roll: roll,
            yaw: estimatedYaw(
                contour: levelled.first { $0.kind == .faceContour }?.points ?? [],
                noseCrest: levelled.first { $0.kind == .noseCrest }?.points ?? []
            ),
            unlevelledRegions: rawRegions,
            unlevelledLeftPupil: rawLeftPupil,
            unlevelledRightPupil: rawRightPupil
        )
    }

    /// Approximate head turn, from how far the nose sits off the centre of the
    /// face outline. Rough by design — it only has to decide whether the photo
    /// is angled enough to warn about, not to be reported as a number.
    ///
    /// The reference is the **centroid** of the nose crest, not its last point.
    /// That last point sits about 0.18 interocular widths off the midline on
    /// every face, which fed a constant +10.8° into the estimate and fired the
    /// angled-photo warning on front-on photos. The centroid is on the midline:
    /// measured over 66 mirrored pairs, it cut the bias to +0.8° while keeping
    /// the most response to real head turn of the references tried.
    private static func estimatedYaw(contour: [CGPoint], noseCrest: [CGPoint]) -> Double {
        guard !noseCrest.isEmpty,
              let left = contour.min(by: { $0.x < $1.x }),
              let right = contour.max(by: { $0.x < $1.x })
        else { return 0 }

        let nose = centroid(noseCrest)
        let toLeft = Double(nose.x - left.x)
        let toRight = Double(right.x - nose.x)
        let total = toLeft + toRight
        guard total > 0 else { return 0 }

        // −1...1, zero when the nose sits centred between the outline edges.
        let offset = (toLeft - toRight) / total
        return offset * 60
    }

    private static func rotate(
        _ point: CGPoint,
        around pivot: CGPoint,
        byDegrees degrees: Double
    ) -> CGPoint {
        let radians = degrees * .pi / 180
        let cosine = cos(radians)
        let sine = sin(radians)
        let dx = point.x - pivot.x
        let dy = point.y - pivot.y
        return CGPoint(
            x: pivot.x + dx * cosine - dy * sine,
            y: pivot.y + dx * sine + dy * cosine
        )
    }

    private static func centroid(_ points: [CGPoint]) -> CGPoint {
        guard !points.isEmpty else { return .zero }
        let sum = points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
        return CGPoint(x: sum.x / CGFloat(points.count), y: sum.y / CGFloat(points.count))
    }
}
