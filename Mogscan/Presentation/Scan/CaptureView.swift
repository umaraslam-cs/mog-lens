import SwiftUI

/// 13 — Facial capture.
///
/// Live front-camera preview under the design's guide and scrim. The
/// ``PhotoSlot`` placeholder still renders until the session is running, which is
/// what `#Preview` and the Simulator fall back to.
///
/// Stripped to what actually works: preview, framing oval, shutter, cancel. The
/// design also carried a flash button, a camera-flip button, a library shortcut
/// and a "Face detected · hold still" pill, none of which were wired — the flip
/// and flash did nothing, the library icon secretly fired the shutter, and the
/// pill claimed a detection that no request was running. They are out rather
/// than faked; add them back with the behaviour attached.
struct CaptureView: View {
    let onCapture: (UIImage) async -> Void
    let onCancel: () -> Void

    @State private var camera = CameraSession()
    /// Guards the shutter against a double tap while a capture is in flight.
    @State private var isCapturing = false

    var body: some View {
        ZStack {
            if camera.isRunning {
                CameraPreviewView(session: camera.session)
                    .ignoresSafeArea()
            } else {
                PhotoSlot(placeholder: DesignContent.Scan.capturePhoto)
                    .ignoresSafeArea()
            }

            faceGuide

            AppGradient.captureScrim
                .ignoresSafeArea()
                .allowsHitTesting(false)

            ZStack(alignment: .top) {
                topBar
                    // 38pt circles in 44pt hit targets — inset 3pt less than the
                    // design's 20 / 8 so the visible chrome lands exactly.
                    .padding(.horizontal, 17)
                    .padding(.top, 5)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    ShutterButton(action: capture)
                        .padding(.bottom, 30)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
        .statusBarHidden(false)
        .task { camera.start() }
        .onDisappear { camera.stop() }
    }

    /// Takes the still and hands it to the flow. A failed capture leaves the user
    /// on this screen to try again rather than pushing an empty analysis.
    private func capture() {
        guard !isCapturing else { return }
        isCapturing = true

        Task {
            defer { isCapturing = false }
            guard let photo = try? await camera.capturePhoto() else { return }
            await onCapture(photo)
        }
    }

    /// Title stays centred on the screen, not on what is left of the row, now
    /// that the flip button no longer balances the close button.
    private var topBar: some View {
        HStack {
            CircleIconButton(
                symbol: AppSymbol.close,
                diameter: 38,
                symbolSize: 16,
                accessibilityLabelText: "Cancel",
                action: onCancel
            )

            Spacer(minLength: 0)
        }
        .overlay {
            Text(DesignContent.Scan.captureTitle)
                .font(AppFont.subheadlineEmphasis)
                .foregroundStyle(.white)
        }
    }

    /// 250 × 330, centred horizontally and sitting 51pt above the screen centre.
    private var guideSize: CGSize { CGSize(width: 250, height: 330) }
    private var guideOffsetY: CGFloat { -51 }

    /// The dimmed surround and the ring that outlines the hole in it.
    ///
    /// One stack, ignoring the safe area once at the end, because the two have to
    /// share a coordinate space. Previously the dim ignored the safe area and the
    /// ring did not, so the dim was centred on the screen while the ring was
    /// centred on the safe area between the insets — 6.5pt apart on a device with
    /// a 47pt top and 34pt bottom inset, which read as a misaligned halo. The
    /// screen is also the right basis: the design places the guide against the
    /// screen centre, not the safe area's.
    ///
    /// A static framing aid. The ring used to switch colour on a hardcoded
    /// `isFaceDetected`, which meant it only ever rendered the "detected" state.
    private var faceGuide: some View {
        ZStack {
            AppColor.captureDim
                .reverseMask {
                    FaceGuideShape()
                        .frame(width: guideSize.width, height: guideSize.height)
                        .offset(y: guideOffsetY)
                }

            FaceGuideShape()
                .stroke(AppColor.accentStart.opacity(0.9), lineWidth: 2)
                .frame(width: guideSize.width, height: guideSize.height)
                .shadow(color: AppColor.accentStart.opacity(0.35), radius: 20)
                .offset(y: guideOffsetY)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

extension View {
    /// Punches the given shape out of the receiver.
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: .center) {
                    mask().blendMode(.destinationOut)
                }
                .compositingGroup()
        }
    }
}

#Preview("13 Facial capture") {
    CaptureView(onCapture: { _ in }, onCancel: {})
        .preferredColorScheme(.dark)
}
