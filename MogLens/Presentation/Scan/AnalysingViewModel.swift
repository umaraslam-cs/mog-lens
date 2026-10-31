import SwiftUI
import UIKit

/// Runs the analysis, then paces the checklist over the finished result.
///
/// The Vision work finishes in well under a second, but the client asked the
/// scan to read as 8–10 seconds of work — five steps at
/// `AppMotion.analysisStepInterval` land at nine.
///
/// Analysis runs *first*, not alongside, for two reasons. A photo with no face
/// in it fails straight away instead of making the user watch the whole
/// checklist before being told; and the landmarks are in hand for the entire
/// animation, so the overlay has real dots to draw rather than appearing in the
/// last instant. Navigation still waits for the checklist — ``scan`` is what
/// the view watches, and it is only set at the end.
@Observable
final class AnalysingViewModel {
    private(set) var steps: [AnalysisStep] = DesignContent.Scan.analysisSteps
    /// Detected geometry, available as soon as Vision returns so the overlay can
    /// draw over the checklist. Set well before ``scan``.
    private(set) var landmarks: FaceLandmarks?
    /// The finished scan, once the checklist has run out. Setting this is what
    /// moves the flow on, so it stays nil for the length of the animation.
    private(set) var scan: FaceScan?
    /// Set instead of ``scan`` when there was nothing measurable in the photo.
    private(set) var failure: FaceAnalysisError?
    private var cachedResult: FaceScan?
    private var activePacingTask: Task<Void, Never>?
    private var isAnalysing = false

    private let analyseFace: AnalyseFaceUseCaseProtocol

    init(analyseFace: AnalyseFaceUseCaseProtocol) {
        self.analyseFace = analyseFace
    }

    convenience init(dependencies: AppDependencies) {
        self.init(analyseFace: dependencies.analyseFace)
    }

    /// Share of the checklist that is done — the bar and the percentage both read it.
    var progress: Double {
        let completed = steps.filter { $0.state == .completed }.count
        return Double(completed) / Double(steps.count)
    }

    /// e.g. "60%".
    var progressLabel: String { "\(Int(progress * 100))%" }

    var isComplete: Bool { steps.allSatisfy { $0.state == .completed } }

    /// Analyses the photo, then walks the checklist to the end over the result.
    @MainActor
    func run(photo: UIImage?) async {
        if isComplete || scan != nil { return }
        if let existing = activePacingTask {
            await existing.value
            return
        }

        if cachedResult == nil {
            guard !isAnalysing else { return }
            isAnalysing = true
            defer { isAnalysing = false }
            reset()

            guard let source = photo,
                  let cgImage = source.guaranteedCGImage ?? source.cgImage else {
                print("[AnalysingVM] ❌ Could not obtain CGImage from photo")
                await raise(.imageUnreadable)
                return
            }

            let orientation = CGImagePropertyOrientation(source.imageOrientation)
            print("[AnalysingVM] CGImage size: \(cgImage.width)×\(cgImage.height), orientation: \(orientation.rawValue)")

            let result: FaceScan
            do {
                result = try await analyseFace(image: cgImage, orientation: orientation)
                print("[AnalysingVM] ✅ analyseFace succeeded")
            } catch let error as FaceAnalysisError {
                print("[AnalysingVM] ❌ FaceAnalysisError: \(error)")
                await raise(error)
                return
            } catch {
                print("[AnalysingVM] ❌ Unknown error: \(error)")
                await raise(.landmarksUnavailable)
                return
            }

            landmarks = result.landmarks
            cachedResult = result
        }

        guard let result = cachedResult else { return }

        let pacing = Task { @MainActor [weak self] in
            guard let self else { return }
            while !self.isComplete {
                try? await Task.sleep(for: .seconds(AppMotion.analysisStepInterval))
                self.completeCurrentStep()
                print("[AnalysingVM] Step advanced: \(self.progressLabel)")
            }
            self.scan = result
            self.activePacingTask = nil
        }
        activePacingTask = pacing
        await pacing.value
    }

    /// Puts every field back to its starting value before a run.
    private func reset() {
        steps = DesignContent.Scan.analysisSteps
        landmarks = nil
        scan = nil
        failure = nil
        cachedResult = nil
        activePacingTask?.cancel()
        activePacingTask = nil
    }

    /// Reports that there was nothing measurable in the photo.
    ///
    /// Raised immediately. The pause before the message reaches the user belongs
    /// to the scan flow, which has to leave this screen first — see
    /// ``ScanViewModel/analysisDidFail(_:)``.
    private func raise(_ error: FaceAnalysisError) async {
        failure = error
    }

    /// Clears the failure once it has been handed to the scan flow, which owns
    /// the alert. Leaving it set would suppress the next one, since the view
    /// reports failures on change.
    func failureAcknowledged() {
        failure = nil
    }

    /// Marks the next outstanding step complete and starts the one after it.
    private func completeCurrentStep() {
        guard let index = steps.firstIndex(where: { $0.state != .completed }) else { return }
        steps[index].state = .completed
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        if index + 1 < steps.count {
            steps[index + 1].state = .inProgress
        }
    }
}
