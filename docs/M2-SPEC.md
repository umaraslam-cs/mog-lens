# M2 — Vision, measurement, scoring

Implementation spec for Milestone 2. Contract scope: Vision framework
integration, facial landmark detection and overlay, scan animation with progress
states, facial measurements, and score / percentile / tier calculation.

Read `docs/IMPLEMENTATION.md` first for the UI this plugs into, and `CLAUDE.md`
for the client's constraints. Where this spec and `IMPLEMENTATION.md` disagree,
this spec wins for M2 work.

## Decisions taken

| Question | Decision |
|---|---|
| No face / unusable photo | Native alert, dismiss returns to the Scan entry screen. No inline retry state. |
| Off-angle photos | Score anyway, surface a warning on results. No hard pose gate. |
| Percentile thresholds | Provisional values authored here, clearly flagged, in one editable file. Client signs off later. |
| Persistence | In memory for M2. Real scans do not reach Home history until M3. |

Two follow-ons the client must be told before the M2 review:

- **The numbers are provisional.** He supplied one datapoint (jaw angle > 125° =
  Top 10%). Everything else is authored. He must not read the review build's
  scores as calibrated.
- **Reproducibility is bounded by pose.** He asked for two scans under similar
  conditions to land within a point or two. Roll correction and interocular
  normalization deliver that for front-on captures. A visibly turned head will
  still drift, and we warn rather than block.

## Scope audit

M2 on the contract is five lines. Every work item below traces to one of them,
or to the smallest prerequisite that makes one of them possible.

| Contract line | Work item |
|---|---|
| Vision framework integration | 2 |
| Facial landmark detection and overlay | 2, 5 |
| Scan animation with progress states | 6 |
| Facial measurements | 3 |
| Score, percentile and tier calculation | 4 |

Three items are **prerequisites, not contract lines**, and are in only because
the milestone cannot be demonstrated without them:

- **1, camera capture.** Vision needs an image. Import already works, so M2 could
  technically ship import-only — but "Photo capture/import" is MVP feature 2 and
  has no other milestone to live in. Kept, scoped to the minimum: session,
  permission, shutter.
- **7, failure handling.** Without it a photo with no face hangs the analysing
  screen. Minimal per the decision: one alert, dismiss to Scan entry.
- **8, results wiring.** "Results functionality" is M3. M2 only needs the scored
  result to *reach* the results screen, otherwise none of the scoring is
  reviewable. Nothing beyond that.

Cut as out of scope after this audit, previously drafted into item 1:

- Flip-camera button action (`CaptureView.swift:84` is `{}`) — UI polish, M4.
- Live `VNDetectFaceRectanglesRequest` on preview frames driving the oval
  (`CaptureView.swift:13` is hardcoded `true`) — a nicety the design implies but
  no contract line asks for. Revisit in M4 if time allows.

## Non-goals for M2

Explicitly out, to keep the milestone honest:

- StoreKit / RevenueCat, real entitlement. The paywall stays a UI stub and keeps
  gating results (`SubscriptionRepositoryProtocol.isSubscribed()`).
- Persisting scans, Home history from real data, delete/reset.
- The advice lookup table (client's JSON) — that is M3.
- Staggered metric reveal and the per-metric percentile bar. Client asked for
  both; they belong with results work in M3.
- The agreed "what's your main goal?" onboarding step. Small, unrelated to
  Vision; slot into M3 or M4.

## Architecture

Existing rules hold: `Domain` imports nothing but Foundation, view models take
use cases, `AppDependencies` is the only composition root. **Vision and
AVFoundation are confined to `Data/`.** No `VN*` type crosses into `Domain` or
`Presentation`.

```
CaptureView ──▶ CameraSession (Data, AVFoundation)
                    │ UIImage
ScanViewModel ──────┘
     │
AnalysingViewModel ──AnalyseFaceUseCase──▶ FaceAnalysisRepositoryProtocol
                                                    │
                                          VisionFaceAnalyser (Data)
                                          ├── VNDetectFaceLandmarksRequest
                                          ├── FaceGeometry   (measurement)
                                          └── ScoringTable   (percentile, tier)
                                                    │ FaceScan + FaceLandmarks
                                          AnalysingViewModel ──▶ ResultsView
```

### New domain types

`Domain/Entities/FaceLandmarks.swift`

```swift
/// Landmark geometry in view-normalized space: origin top-left, x and y in 0...1
/// relative to the source image. Vision's bottom-left space is converted at the
/// boundary so nothing downstream has to think about it.
struct FaceLandmarks: Hashable {
    struct Region: Hashable {
        let kind: Kind
        let points: [CGPoint]
        enum Kind { case faceContour, leftEye, rightEye, leftEyebrow, rightEyebrow,
                         nose, noseCrest, medianLine, outerLips, innerLips }
    }
    let boundingBox: CGRect
    let regions: [Region]
    let leftPupil: CGPoint
    let rightPupil: CGPoint
    /// Roll in degrees, from the interpupillary line. Applied, not just reported.
    let roll: Double
    /// Estimated yaw in degrees. Drives the off-angle warning.
    let yaw: Double

    func region(_ kind: Region.Kind) -> [CGPoint]
}
```

`Domain/Entities/FaceAnalysisError.swift`

```swift
enum FaceAnalysisError: Error, Hashable {
    case noFaceDetected
    case landmarksUnavailable   // face found, landmark request returned nothing usable
    case imageUnreadable
}
```

Multiple faces is **not** an error: pick the largest bounding box and proceed.

`FaceScan` gains two stored properties, both defaulted so existing fixtures and
`SampleScans` keep compiling:

```swift
/// Landmark geometry for the results overlay. Nil for sample data.
let landmarks: FaceLandmarks?
/// Set when yaw exceeded the warning threshold at capture time.
let poseWarning: String?
```

### New protocol, use case, DI

`Domain/Repositories/Repositories.swift`

```swift
/// Runs the on-device Vision pipeline and returns a scored result.
protocol FaceAnalysisRepositoryProtocol {
    func analyse(_ image: UIImage) async throws -> FaceScan
}
```

`UIImage` in a Domain protocol technically drags UIKit in. Take a
`CGImage` plus orientation instead — Domain stays UIKit-free and the call site
is unchanged in practice.

`Domain/UseCases/ScanUseCases.swift` gains `AnalyseFaceUseCase`
(`callAsFunction(image:) async throws -> FaceScan`), and `AppDependencies` gains
`faceAnalysisRepository` plus an `analyseFace` computed property, matching the
existing pattern exactly.

## Work items

Ordered by dependency. 1 and 2 are the critical path.

### 1. Camera capture

`CaptureView.swift:17` renders `PhotoSlot`, a placeholder. Replace only that
layer; the guide, scrim, and controls are already correct.

- `Data/Camera/CameraSession.swift` — `AVCaptureSession`, front camera,
  `AVCapturePhotoOutput`, mirrored preview. `@Observable`, exposes
  `isFaceDetected` and the captured image.
- `UIViewRepresentable` wrapper for `AVCaptureVideoPreviewLayer`.
- Real permission via `AVCaptureDevice.requestAccess(for: .video)`, replacing the
  simulated `CameraPermissionAlertView` path. `permissionDenied()` already routes
  back to Scan entry with Import only — keep that.
- `NSCameraUsageDescription` in Info.plist. Copy: explains the photo is analysed
  on device and never uploaded.
- Captured `UIImage` lands on `ScanViewModel` beside `importedPhoto`.

`isFaceDetected` stays hardcoded and the flip-camera button stays inert — both
cut in the scope audit above.

**Acceptance:** front camera preview fills the frame, shutter produces an image
that reaches the analysing screen, denying permission leaves Import Photo
working.

### 2. Vision analysis

`Data/Analysis/VisionFaceAnalyser.swift` implementing
`FaceAnalysisRepositoryProtocol`:

1. `VNDetectFaceLandmarksRequest` on the still image, correct
   `CGImagePropertyOrientation` for the source (camera vs library differ).
2. No observations → `.noFaceDetected`. Observations but nil `landmarks` →
   `.landmarksUnavailable`. Several faces → largest bounding box.
3. Convert every region from Vision's normalized bottom-left space, which is
   *relative to the face bounding box*, into image-normalized top-left space.
   This is the step that silently corrupts everything downstream if it is wrong —
   verify by drawing the overlay before trusting any measurement.
4. Compute roll from the interpupillary line and **rotate the whole point set**
   so that line is horizontal. Estimate yaw from the horizontal offset of the
   nose crest against the face-contour midpoint.
5. Hand the normalized set to `FaceGeometry`, then `ScoringTable`.

**Acceptance:** a front-on photo yields a populated `FaceLandmarks` whose
overlay lands on the actual features; a photo of a wall raises `.noFaceDetected`.

### 3. Measurement

`Data/Analysis/FaceGeometry.swift`. Pure functions over `FaceLandmarks`, no
Vision types, no state. **Every distance divides by interocular distance**
(pupil to pupil) so results are scale-invariant — this plus roll correction is
what makes the score reproducible.

The five metrics already declared in `FacialMetric.Kind` all get real values:

| Metric | Definition | Unit |
|---|---|---|
| `facialSymmetry` | Mirror paired landmarks (eyes, brows, mouth corners, contour) across the midline; mean absolute perpendicular-distance difference, normalized. Reported as `100 − k·meanDiff`. | `%`, 1 dp |
| `jawAngle` | Angle at the menton between left and right gonion, from `faceContour`. The client's named three-point calculation. | `°`, 0 dp |
| `chinRatio` | Lower third (subnasale → menton) over middle third (nasion → subnasale). His "chin-to-nose ratio". | bare ratio, 2 dp |
| `eyeSpacing` | Intercanthal distance over mean eye width. Neutral ideal is 1.0. | bare ratio, 2 dp |
| `midfaceRatio` | Pupil-line-to-lip-centre height over bizygomatic width. | bare ratio, 2 dp |

Landmark indices into Vision's regions are fixed per region and must be named
constants with a comment, not magic numbers scattered through the math.

**Acceptance:** measurements on a known front-on photo are stable across repeated
runs to the displayed precision, and change in the expected direction on a
deliberately asymmetric input.

### 4. Scoring

`Data/Analysis/ScoringTable.swift`. **This is the file the client edits**, so it
carries the provisional warning at the top and nothing else lives in it.

- Per metric: an ascending array of `(rawValue, percentile)` anchors.
  Percentile is **piecewise-linear interpolated** between anchors, not bucketed —
  buckets make the score jump on tiny input changes, which reads as instability.
- Jaw angle is anchored to the client's one real datapoint: 125° → 90th
  percentile (his "Top 10%").
- Overall score: mean of metric percentiles, symmetry and jaw angle weighted
  double — they are the two he named first and the two users recognise.
- Tier from overall score. Provisional bands: `LTN` <30, `MTN` 30–54,
  `HTN` 55–74, `Chad Lite` 75–89, `Chad` 90+. Order matches `FacialTier`.
- **No randomness anywhere in this file or `FaceGeometry`.** Determinism is the
  contractual requirement; a single `Double.random` would violate it.

**Acceptance:** re-importing the *same* photo twice produces byte-identical
scores. Two live captures under similar conditions land within two points.

### 5. Overlay on real landmarks

`LandmarkLayout.swift` holds fixed design coordinates for the analysing and
results overlays. Both become real.

- `LandmarkOverlay` already takes `[LandmarkPoint]` and `[LandmarkConnector]` —
  the view does not change. Add a mapper from `FaceLandmarks` to those two.
- Connectors trace what is actually being measured: the interpupillary line, the
  midline, and the jaw triangle. The overlay should visibly correspond to the
  metrics, since that is the whole "measured, not guessed" claim.
- Points must track the photo through aspect-fill cropping, or they drift off the
  features on non-4:3 images.
- **Keep the existing static layout** for `PreviewData` and `SampleScans` so
  every `#Preview` still renders without a camera.

### 6. Scan animation with real progress

`AnalysingViewModel.swift:26` sleeps 1s per step, five steps, 5s total. Client
wants 8–10s.

- Kick off the real analysis concurrently on task start.
- Advance the checklist on a **minimum dwell per step** (`AppMotion
  .analysisStepInterval` → 1.8s, giving 9s) rather than on request completion,
  since the real work finishes in well under a second.
- If analysis finishes early, hold the remaining dwell — this padding is
  deliberate, per the client's brief.
- If analysis throws, stop the checklist immediately and surface the alert.
- Keep the five existing step titles in `DesignContent.swift:150`. The client's
  example list has four; his first one, "Mapping facial landmarks…", is already
  ours verbatim.

### 7. Failure handling

Per the decision: a native alert on the analysing screen, whose only action
dismisses the whole scan flow back to the Scan entry screen via the existing
`dismissFlow()`. No new navigation mechanism — `AppRouter` and
`ScanViewModel.path` stay the single source of truth.

Copy lives in `DesignContent`, one message per `FaceAnalysisError` case.

### 8. Results wiring

The analysed `FaceScan` reaches `ResultsView` in memory for the session. The
paywall still renders before any result value reaches a view model — preserve
that ordering exactly; it is a stated invariant.

`poseWarning`, when set, renders as an `InfoBanner` above the metrics.

## Verification

Face landmark detection does not work in Simulator — simulator runs prove nothing
about scoring. Everything in items 2–5 is verified on the iPhone 14 registered on
the development profile.

Manual pass before the M2 review build:

1. Camera capture, front-on, good light → plausible metrics, overlay on features.
2. Same photo imported twice → identical scores.
3. Deliberately turned head → pose warning appears, no crash.
4. Photo with no face → alert, returns to Scan entry.
5. Permission denied → Import Photo still works end to end.
6. Reduce Motion on → scan animation settles, no looping.
7. Every `#Preview` still renders.

## Answered by the client, Aug 15 2026

- **Five metrics**, as already built. Advice copy for Eye Spacing and Midface
  Ratio supplied and recorded in `CLAUDE.md`; it is M3 content.
- **Provisional thresholds in one config file are fine.** He will scan real
  faces once the build lands and send adjustments.
- **Warn, don't block, on angled photos** — with a hard paywall and no free
  trial he wants no friction before purchase. His condition: the note must be
  **clearly visible**, not fine print, so the score cannot read as misleading.
  Hence the warning-coloured banner on the results photo rather than a caption.

## Open items for the client

- **Percentile wording.** His brief specifies "a percentile ranking, such as
  *Top X%*". The built UI renders `88th percentile · Excellent`
  (`FacialMetric.percentileCaption`). Same number, different phrasing. Either is
  a one-line change; ask which he wants before M3 locks the results copy.
- Sign-off on the threshold table and tier bands once he sees real scores.
