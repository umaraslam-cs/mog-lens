import CoreGraphics
import CoreML
import Foundation
import ImageIO
import Vision

/// The on-device analysis pipeline: Vision landmarks in, scored ``FaceScan`` out.
///
/// This is the only type that knows Vision exists. Everything it returns is
/// plain domain values, so the rest of the app never sees a `VN` type.
struct VisionFaceAnalyser: FaceAnalysisRepositoryProtocol {

    /// Past this much head turn the numbers move enough to be worth flagging.
    /// The scan still scores — the decision was to warn, not block.
    private let yawWarningThreshold: Double = 12

    /// Scales the photo is re-read at before the measurements are medianed.
    /// Each is read twice, once mirrored — see ``stabilisedMeasurements``.
    private let measurementScales: [CGFloat] = [1.0, 0.9, 0.8]

    func analyse(
        _ image: CGImage,
        orientation: CGImagePropertyOrientation
    ) async throws -> FaceScan {
        // Sanitize to a plain RGBA-8 bitmap so Vision never sees a GPU-backed,
        // wide-gamut, or HDR image that can cause handler.perform to throw.
        let safe = sanitized(image) ?? image

        // detectFace returns the observation AND the orientation it succeeded with,
        // so that orientedSize uses the same frame Vision used for its coordinates.
        let (observation, detectedOrientation) = try detectFace(in: safe, preferring: orientation)

        let size = orientedSize(of: safe, orientation: detectedOrientation)

        guard let landmarks = FaceLandmarkMapper.map(observation, imageSize: size) else {
            throw FaceAnalysisError.landmarksUnavailable
        }

        // The overlay draws the full-resolution landmarks; the numbers come from
        // the median of several readings. See ``stabilisedMeasurements``.
        let measurements = stabilisedMeasurements(of: safe, orientation: detectedOrientation)
            ?? FaceGeometry.measure(landmarks)
        let metrics = ScoringTable.metrics(from: measurements)
        let score = ScoringTable.overallScore(for: metrics)
        let isAngled = abs(landmarks.yaw) > yawWarningThreshold

        return FaceScan(
            capturedAt: Date(),
            overallScore: score,
            tier: ScoringTable.tier(for: score),
            metrics: metrics,
            photoDescription: DesignContent.Scan.analysingPhoto,
            summary: summary(for: metrics),
            percentileSummary: DesignContent.Results.percentileSummary(score),
            poseDescription: isAngled
                ? DesignContent.Scan.poseAngled
                : DesignContent.Scan.poseFrontOn,
            landmarks: landmarks,
            poseWarning: isAngled ? DesignContent.Scan.poseWarning : nil
        )
    }

    /// Face rectangles only. Roughly an order of magnitude cheaper than the
    /// landmark pass, which is what makes it usable as a gate before the flow
    /// moves on.
    ///
    /// A pass here does not promise ``analyse(_:orientation:)`` will succeed —
    /// landmarks can still come back empty on a face this finds. It is a fast
    /// rejection, not a guarantee, so the failure path stays in place behind it.
    func containsFace(
        _ image: CGImage,
        orientation: CGImagePropertyOrientation
    ) async -> Bool {
        let request = VNDetectFaceRectanglesRequest()
        if (try? performVisionRequest(request, on: image, orientation: orientation)) != nil,
           let results = request.results, !results.isEmpty {
            return true
        }
        if orientation != .up {
            let fallbackRequest = VNDetectFaceRectanglesRequest()
            if (try? performVisionRequest(fallbackRequest, on: image, orientation: .up)) != nil,
               let results = fallbackRequest.results, !results.isEmpty {
                return true
            }
        }
        return false
    }

    // MARK: Stabilised measurement

    /// Reads the same photo six ways — three scales, each also mirrored — and
    /// takes the median of each measurement.
    ///
    /// Vision's landmark positions shift by a pixel or two depending on how the
    /// face is sampled, and a calibrated score amplifies that, because the
    /// percentile curves are only as wide as the population actually spreads.
    /// Measured on the client's 34 photos, re-read after a ±3° rotation, a
    /// three-reading score drifts a median of 5.5 points and changes tier on 11
    /// of 34 faces. That fails his one hard requirement outright.
    ///
    /// The mirrored readings are what fixes it, and they are free accuracy: all
    /// five measurements are mirror-invariant by definition — swapping left and
    /// right cannot change a symmetry score, an angle at the chin, or a vertical
    /// ratio — so a flipped reading measures the same face, while Vision's own
    /// left/right bias flips with it and cancels in the median. Drift falls to
    /// 3.5 points, tier changes to 3 of 34, and every metric's signal-to-noise
    /// rises by about half.
    ///
    /// Six readings, not more. Five scales and seven were both measured: the
    /// median drift stops improving while the *worst* case gets worse, because
    /// shrinking past ~0.8 costs Vision more precision than the extra sample
    /// returns.
    ///
    /// Nothing here is random and nothing reads the clock: the same photo always
    /// produces the same six renderings, so two scans of one image agree exactly.
    private func stabilisedMeasurements(
        of image: CGImage,
        orientation: CGImagePropertyOrientation
    ) -> FaceGeometry.Measurements? {
        let samples = measurementScales
            .compactMap { resized(image, by: $0) }
            .flatMap { [$0, mirrored($0)].compactMap { $0 } }
            .compactMap { variant -> FaceGeometry.Measurements? in
                guard let (observation, _) = try? detectFace(in: variant, preferring: orientation),
                      let landmarks = FaceLandmarkMapper.map(
                          observation,
                          imageSize: orientedSize(of: variant, orientation: orientation)
                      )
                else { return nil }
                return FaceGeometry.measure(landmarks)
            }
        guard !samples.isEmpty else { return nil }

        func median(_ value: (FaceGeometry.Measurements) -> Double) -> Double {
            let sorted = samples.map(value).sorted()
            let middle = sorted.count / 2
            return sorted.count.isMultiple(of: 2)
                ? (sorted[middle - 1] + sorted[middle]) / 2
                : sorted[middle]
        }

        return FaceGeometry.Measurements(
            symmetry: median(\.symmetry),
            jawAngle: median(\.jawAngle),
            chinRatio: median(\.chinRatio),
            eyeSpacing: median(\.eyeSpacing),
            midfaceRatio: median(\.midfaceRatio)
        )
    }

    /// The image's dimensions *as Vision sees them*.
    ///
    /// Vision reports against the oriented image, so a photo carrying a quarter
    /// turn in its EXIF — which is most of what a phone camera writes — reports
    /// against swapped dimensions. ``FaceLandmarkMapper`` scales x by
    /// width ÷ height to put both axes in the same units, so handing it the
    /// unrotated size inverts that ratio and stretches every horizontal distance
    /// by the square of the aspect. On a 4:3 photo that is 1.78×, which collapsed
    /// midface from ~0.53 to ~0.30 and dragged jaw angle to the floor with it.
    ///
    /// Both the overlay landmarks and the measured ones go through here, because
    /// only the overlay path had the correction and the measurements are what the
    /// score is built from.
    private func orientedSize(
        of image: CGImage,
        orientation: CGImagePropertyOrientation
    ) -> CGSize {
        let isQuarterTurned = [.left, .leftMirrored, .right, .rightMirrored].contains(orientation)
        return isQuarterTurned
            ? CGSize(width: image.height, height: image.width)
            : CGSize(width: image.width, height: image.height)
    }

    /// Horizontal flip. Paired with each scale so the detector's left/right bias
    /// cancels — see ``stabilisedMeasurements``.
    private func mirrored(_ image: CGImage) -> CGImage? {
        guard let context = CGContext(
            data: nil, width: image.width, height: image.height,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.translateBy(x: CGFloat(image.width), y: 0)
        context.scaleBy(x: -1, y: 1)
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return context.makeImage()
    }

    private func resized(_ image: CGImage, by scale: CGFloat) -> CGImage? {
        guard scale != 1 else { return image }
        let width = Int((CGFloat(image.width) * scale).rounded())
        let height = Int((CGFloat(image.height) * scale).rounded())
        guard width > 0, height > 0,
              let context = CGContext(
                  data: nil, width: width, height: height,
                  bitsPerComponent: 8, bytesPerRow: 0,
                  space: CGColorSpaceCreateDeviceRGB(),
                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              )
        else { return nil }

        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }

    // MARK: Detection

    /// Two-pass face detection: rectangles first (much more permissive), then
    /// landmarks with the found bounding boxes as input hints.
    ///
    /// `VNDetectFaceLandmarksRequest` alone can miss faces that are slightly
    /// angled, have facial hair, or are photographed in certain lighting. By
    /// running `VNDetectFaceRectanglesRequest` first and handing the results
    /// to the landmarks request as `inputFaceObservations`, we dramatically
    /// improve detection on photos from the library.
    ///
    /// Returns the observation AND the orientation Vision succeeded with, so
    /// the caller can use that same orientation for coordinate mapping.
    private func detectFace(
        in image: CGImage,
        preferring preferredOrientation: CGImagePropertyOrientation
    ) throws -> (VNFaceObservation, CGImagePropertyOrientation) {
        // All orientations to try, preferred first.
        let orientationsToTry: [CGImagePropertyOrientation] = {
            var list: [CGImagePropertyOrientation] = [preferredOrientation]
            for o: CGImagePropertyOrientation in [.up, .right, .left, .down] where o != preferredOrientation {
                list.append(o)
            }
            return list
        }()

        // Pass 1: Find face rectangles across all orientations.
        var rectObservations: [VNFaceObservation] = []
        var workingOrientation = preferredOrientation

        print("[Vision] Image: \(image.width)×\(image.height), trying orientations: \(orientationsToTry.map(\.rawValue))")
        for orientation in orientationsToTry {
            let rectRequest = VNDetectFaceRectanglesRequest()
            do {
                try performVisionRequest(rectRequest, on: image, orientation: orientation)
                if let results = rectRequest.results, !results.isEmpty {
                    print("[Vision] ✅ Face found with orientation \(orientation.rawValue): \(results.count) face(s)")
                    rectObservations = results
                    workingOrientation = orientation
                    break
                } else {
                    print("[Vision] ❌ No face for orientation \(orientation.rawValue)")
                }
            } catch {
                print("[Vision] ❌ Request failed for orientation \(orientation.rawValue): \(error)")
            }
        }

        guard !rectObservations.isEmpty else {
            print("[Vision] ❌ No face in ANY orientation — throwing noFaceDetected")
            throw FaceAnalysisError.noFaceDetected
        }

        // Pass 2: Run landmarks request, seeded with the bounding boxes from
        // pass 1. This gives Vision a strong prior and greatly increases the
        // chance it returns landmarks for faces it would otherwise skip.
        let landmarksRequest = VNDetectFaceLandmarksRequest()
        landmarksRequest.inputFaceObservations = rectObservations

        var landmarkFaces: [VNFaceObservation] = []
        if (try? performVisionRequest(landmarksRequest, on: image, orientation: workingOrientation)) != nil {
            landmarkFaces = landmarksRequest.results ?? []
        }

        // Prefer the landmarks result; fall back to the rectangle observation
        // if landmarks still came back empty (the mapper handles a nil .landmarks).
        let faces = landmarkFaces.isEmpty ? rectObservations : landmarkFaces

        guard let largest = faces.max(by: { lhs, rhs in
            lhs.boundingBox.width * lhs.boundingBox.height
                < rhs.boundingBox.width * rhs.boundingBox.height
        }) else {
            throw FaceAnalysisError.noFaceDetected
        }

        return (largest, workingOrientation)
    }

    // MARK: Vision Execution & Device Fallback

    private func performVisionRequest(
        _ request: VNRequest,
        on image: CGImage,
        orientation: CGImagePropertyOrientation
    ) throws {
        configureComputeDevice(for: request)
        let handler = VNImageRequestHandler(cgImage: image, orientation: orientation)
        do {
            try handler.perform([request])
        } catch {
            // Fallback to CPU execution if Neural Engine / GPU fails to create an inference context
            setCPUComputeDevice(on: request)
            let fallbackHandler = VNImageRequestHandler(cgImage: image, orientation: orientation)
            try fallbackHandler.perform([request])
        }
    }

    private func configureComputeDevice(for request: VNRequest) {
        #if targetEnvironment(simulator)
        // Simulator lacks Neural Engine / GPU inference context, so use CPU directly
        setCPUComputeDevice(on: request)
        #endif
    }

    private func setCPUComputeDevice(on request: VNRequest) {
        if #available(iOS 17.0, *) {
            let cpuDevices = MLComputeDevice.allComputeDevices.filter {
                if case .cpu = $0 { return true }
                return false
            }
            if let cpu = cpuDevices.first {
                request.setComputeDevice(cpu, for: .main)
                return
            }
        }
        request.usesCPUOnly = true
    }

    // MARK: Image sanitization

    /// Redraws `image` into a plain sRGB/RGBA-8 `CGContext`.
    ///
    /// Images from `PhotosPickerItem` or `AVCapturePhoto` can carry HDR,
    /// Display-P3, or GPU-backed pixel buffers that Vision's
    /// `VNImageRequestHandler` cannot always process without throwing.
    /// Drawing into a known-good 8-bpc sRGB bitmap is cheap and eliminates
    /// the entire class of colorspace-related `imageUnreadable` failures.
    private func sanitized(_ image: CGImage) -> CGImage? {
        guard image.width > 0, image.height > 0 else { return nil }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let ctx = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }
        ctx.interpolationQuality = .high
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return ctx.makeImage()
    }

    /// One line naming what carries the score, for the Home hero card.
    private func summary(for metrics: [FacialMetric]) -> String {
        guard let strongest = metrics.max(by: { $0.percentile < $1.percentile }) else {
            return DesignContent.Results.summaryFallback
        }
        return DesignContent.Results.summary(
            strongest.kind.shortName,
            topPercentage: strongest.topPercentage
        )
    }
}
