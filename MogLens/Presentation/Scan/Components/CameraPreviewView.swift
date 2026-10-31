import AVFoundation
import SwiftUI

/// Hosts `AVCaptureVideoPreviewLayer` — the one piece of the capture screen
/// SwiftUI cannot draw itself. Everything layered above it stays SwiftUI.
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    /// Backing the layer directly keeps the preview sized by Auto Layout instead
    /// of resized frame-by-frame.
    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

        var previewLayer: AVCaptureVideoPreviewLayer {
            // Safe: `layerClass` above guarantees the type.
            layer as! AVCaptureVideoPreviewLayer
        }

        /// Portrait-locked, matching the pinned angle on the photo connection.
        ///
        /// Set on layout, not at creation: attaching a running session builds the
        /// layer's connection asynchronously on the session queue, so right after
        /// `session` is assigned `connection` is nil and the write is swallowed by
        /// the optional chain. The connection then arrives at the sensor's native
        /// angle — landscape right — and the preview renders sideways inside a
        /// portrait app. By first layout the connection is there.
        /// Guarded because an unsupported angle raises an Objective-C exception
        /// rather than a catchable Swift error.
        override func layoutSubviews() {
            super.layoutSubviews()
            guard let connection = previewLayer.connection,
                  connection.isVideoRotationAngleSupported(Self.portraitAngle)
            else { return }
            connection.videoRotationAngle = Self.portraitAngle
        }

        private static let portraitAngle: CGFloat = 90
    }
}
