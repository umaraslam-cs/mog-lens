import AVFoundation
import UIKit

/// Front-camera capture for the scan flow.
///
/// Owns the `AVCaptureSession` that ``CameraPreviewView`` renders. Configuration
/// and start/stop run off the main thread on purpose: `startRunning()` blocks for
/// long enough on device to stutter the push animation into the capture screen.
@Observable
final class CameraSession: NSObject, @unchecked Sendable {

    enum Failure: Error {
        /// No usable front camera, or the session refused the input.
        case unavailable
        /// The photo output came back empty or errored.
        case captureFailed
    }

    /// True once frames are flowing. The capture screen falls back to the design
    /// placeholder until then, which is also what keeps `#Preview` looking right.
    private(set) var isRunning = false

    /// Handed to the preview layer, and to nothing else.
    @ObservationIgnored let session = AVCaptureSession()

    @ObservationIgnored private let output = AVCapturePhotoOutput()
    @ObservationIgnored private let queue = DispatchQueue(label: "com.mogscan.camera.session")
    @ObservationIgnored private var isConfigured = false
    @ObservationIgnored private var pendingCapture: CheckedContinuation<UIImage, Error>?

    /// Configures once, then starts. Safe to call on every appear.
    func start() {
        queue.async { [self] in
            if !isConfigured {
                guard (try? configure()) != nil else { return }
            }
            guard !session.isRunning else { return }
            session.startRunning()
            let running = session.isRunning
            Task { @MainActor in self.isRunning = running }
        }
    }

    func stop() {
        queue.async { [self] in
            guard session.isRunning else { return }
            session.stopRunning()
            Task { @MainActor in self.isRunning = false }
        }
    }

    /// Captures a still, mirrored to match what the user just saw in the preview.
    func capturePhoto() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [self] in
                guard session.isRunning else {
                    continuation.resume(throwing: Failure.unavailable)
                    return
                }
                pendingCapture = continuation
                output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            }
        }
    }

    private func configure() throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input),
            session.canAddOutput(output)
        else {
            throw Failure.unavailable
        }

        session.addInput(input)
        session.addOutput(output)

        // The app is portrait-locked, so the angle is pinned rather than observed.
        if let connection = output.connection(with: .video) {
            connection.videoRotationAngle = 90
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
        }

        isConfigured = true
    }
}

extension CameraSession: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        // AVFoundation picks the callback queue, so the continuation is only ever
        // touched on ours.
        queue.async { [self] in
            let continuation = pendingCapture
            pendingCapture = nil

            guard error == nil,
                  let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data)
            else {
                continuation?.resume(throwing: Failure.captureFailed)
                return
            }
            continuation?.resume(returning: image)
        }
    }
}
