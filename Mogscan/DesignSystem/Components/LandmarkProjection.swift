import SwiftUI

/// Projects measured ``FaceLandmarks`` onto a photo slot.
///
/// ``PhotoSlot`` fills its frame, so the photo is cropped on one axis. Landmarks
/// are normalised to the whole image, so without accounting for that crop the
/// dots drift off the features on any photo whose aspect ratio is not the slot's.
///
/// The drawn set is a curated subset, not all ~65 points Vision returns: the
/// approved design's overlay is a sparse mesh, and a dense one would read as
/// noise. The connectors trace what is actually being measured — the midline
/// symmetry is mirrored across, and the two jaw sides whose angle is scored.
enum LandmarkProjection {

    struct Projected {
        let points: [LandmarkPoint]
        let connectors: [LandmarkConnector]
    }

    /// Twelve points and four connectors, matching the density of the design's
    /// analysing overlay.
    static func analysing(
        _ landmarks: FaceLandmarks,
        imageSize: CGSize,
        in slotSize: CGSize
    ) -> Projected {
        let project = projector(landmarks: landmarks, imageSize: imageSize, slotSize: slotSize)

        let leftEye = landmarks.points(.leftEye)
        let rightEye = landmarks.points(.rightEye)
        let lips = landmarks.points(.outerLips)
        let contour = landmarks.points(.faceContour)

        let dots = [
            landmarks.leftPupil,
            landmarks.rightPupil,
            leftmost(leftEye), rightmost(leftEye),
            leftmost(rightEye), rightmost(rightEye),
            centroid(landmarks.points(.leftEyebrow)),
            centroid(landmarks.points(.rightEyebrow)),
            lowest(landmarks.points(.nose)),
            leftmost(lips), rightmost(lips),
            contour.middleElement
        ].compactMap { $0 }

        return Projected(
            points: dots.enumerated().map { index, point in
                let projected = project(point)
                return LandmarkPoint(id: index, x: projected.x, y: projected.y)
            },
            connectors: connectors(landmarks, contour: contour, project: project, includingJaw: true)
        )
    }

    /// The quieter five-point set the results header uses.
    static func results(
        _ landmarks: FaceLandmarks,
        imageSize: CGSize,
        in slotSize: CGSize
    ) -> Projected {
        let project = projector(landmarks: landmarks, imageSize: imageSize, slotSize: slotSize)
        let lips = landmarks.points(.outerLips)

        let dots = [
            landmarks.leftPupil,
            landmarks.rightPupil,
            lowest(landmarks.points(.nose)),
            leftmost(lips), rightmost(lips)
        ].compactMap { $0 }

        return Projected(
            points: dots.enumerated().map { index, point in
                let projected = project(point)
                return LandmarkPoint(id: index, x: projected.x, y: projected.y)
            },
            connectors: connectors(
                landmarks,
                contour: landmarks.points(.faceContour),
                project: project,
                includingJaw: false
            )
        )
    }

    // MARK: Connectors

    private static func connectors(
        _ landmarks: FaceLandmarks,
        contour: [CGPoint],
        project: (CGPoint) -> CGPoint,
        includingJaw: Bool
    ) -> [LandmarkConnector] {
        var lines: [(CGPoint, CGPoint)] = [
            (landmarks.leftPupil, landmarks.rightPupil)
        ]

        if let chin = contour.middleElement {
            lines.append((landmarks.pupilMidpoint, chin))

            if includingJaw, let start = contour.first, let end = contour.last {
                lines.append((start, chin))
                lines.append((chin, end))
            }
        }

        return lines.enumerated().map { index, line in
            LandmarkConnector(id: index, from: project(line.0), to: project(line.1))
        }
    }

    // MARK: Crop-aware projection

    /// Maps an image-normalised point into the slot's own unit space.
    ///
    /// Only the two aspect ratios matter, not the absolute sizes: the axis that
    /// overflows is scaled and re-centred, the other passes through untouched.
    private static func projector(
        landmarks: FaceLandmarks,
        imageSize: CGSize,
        slotSize: CGSize
    ) -> (CGPoint) -> CGPoint {
        guard imageSize.width > 0, imageSize.height > 0,
              slotSize.width > 0, slotSize.height > 0,
              landmarks.imageAspect > 0
        else { return { $0 } }

        let imageAspect = imageSize.width / imageSize.height
        let slotAspect = slotSize.width / slotSize.height
        // Landmark x is in units of image height — undo that before mapping.
        let squareScale = landmarks.imageAspect

        if imageAspect > slotAspect {
            // Photo is wider than the slot: the sides are cropped.
            let scale = imageAspect / slotAspect
            return { point in
                CGPoint(x: 0.5 + (point.x / squareScale - 0.5) * scale, y: point.y)
            }
        } else {
            // Photo is taller: top and bottom are cropped.
            let scale = slotAspect / imageAspect
            return { point in
                CGPoint(x: point.x / squareScale, y: 0.5 + (point.y - 0.5) * scale)
            }
        }
    }

    // MARK: Point helpers

    private static func centroid(_ points: [CGPoint]) -> CGPoint? {
        guard !points.isEmpty else { return nil }
        let sum = points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
        return CGPoint(x: sum.x / CGFloat(points.count), y: sum.y / CGFloat(points.count))
    }

    private static func leftmost(_ points: [CGPoint]) -> CGPoint? {
        points.min { $0.x < $1.x }
    }

    private static func rightmost(_ points: [CGPoint]) -> CGPoint? {
        points.max { $0.x < $1.x }
    }

    private static func lowest(_ points: [CGPoint]) -> CGPoint? {
        points.max { $0.y < $1.y }
    }
}

private extension Array where Element == CGPoint {
    /// Vision traces the contour from one side around to the other, so the
    /// middle element is the chin.
    var middleElement: CGPoint? {
        isEmpty ? nil : self[count / 2]
    }
}
