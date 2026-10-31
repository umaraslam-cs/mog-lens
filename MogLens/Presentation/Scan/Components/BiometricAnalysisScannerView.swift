import SwiftUI

/// Premium biometric scanning overlay.
///
/// Clean, high-tech biometric scanner that frames the user's face with a dynamic
/// reticle and presents compact live biometric stats (jaw angle, canthal tilt,
/// symmetry, chin ratio, midface) without drawing distracting lines or dots
/// over the face.
struct BiometricAnalysisScannerView: View {
    let landmarks: FaceLandmarks?
    let imageSize: CGSize?
    var progress: Double = 0.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var measurements: FaceGeometry.Measurements? {
        guard let landmarks else { return nil }
        return FaceGeometry.measure(landmarks)
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let face = faceRect(in: size)
            let hasRealLandmarks = landmarks != nil

            ZStack(alignment: .topLeading) {
                // ── Vignette scrim ──────────────────────────────────────────
                RadialGradient(
                    stops: [
                        .init(color: .clear, location: 0.32),
                        .init(color: Color.black.opacity(0.35), location: 0.75),
                        .init(color: Color.black.opacity(0.68), location: 1.0)
                    ],
                    center: .center,
                    startRadius: size.width * 0.25,
                    endRadius: size.width * 0.85
                )

                // ── Face bounding reticle + dynamic corner brackets ─────────
                BoundingReticleView(
                    face: face,
                    progress: progress,
                    hasLandmarks: hasRealLandmarks
                )

                // ── Animated scan grid inside face bounds ───────────────────
                ScanGridView(
                    face: face,
                    progress: progress,
                    reduceMotion: reduceMotion
                )

                // ── Compact live biometric stats badges ─────────────────────
                BiometricStatsBadgesView(
                    face: face,
                    slotSize: size,
                    landmarks: landmarks,
                    measurements: measurements,
                    progress: progress
                )

                // ── Laser sweep beam ─────────────────────────────────────────
                if !reduceMotion {
                    LaserSweepBeamView(height: size.height)
                }

                // ── Corner HUD diagnostics & telemetry strip ─────────────────
                HUDTelemetryOverlayView(
                    size: size,
                    progress: progress,
                    measurements: measurements,
                    hasRealLandmarks: hasRealLandmarks
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.analysisFrame, style: .continuous))
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: - Face rect derivation

    /// Returns the face bounding rectangle in screen-pixel coordinates.
    private func faceRect(in slotSize: CGSize) -> CGRect {
        guard let landmarks, let imageSize,
              imageSize.width > 0, imageSize.height > 0,
              slotSize.width > 0, slotSize.height > 0
        else {
            return fallbackFaceRect(in: slotSize)
        }

        let box = landmarks.boundingBox // 0...1 in image space (top-left origin)
        let tl = project(CGPoint(x: box.minX, y: box.minY), in: slotSize)
        let br = project(CGPoint(x: box.maxX, y: box.maxY), in: slotSize)

        return CGRect(
            x: min(tl.x, br.x),
            y: min(tl.y, br.y),
            width: max(20, abs(br.x - tl.x)),
            height: max(20, abs(br.y - tl.y))
        )
    }

    /// Exact aspect-crop projection for `.scaledToFill` photo slots.
    private func project(_ point: CGPoint, in slotSize: CGSize) -> CGPoint {
        guard let imageSize, imageSize.width > 0, imageSize.height > 0,
              slotSize.width > 0, slotSize.height > 0
        else {
            return CGPoint(x: point.x * slotSize.width, y: point.y * slotSize.height)
        }

        let imageAspect = imageSize.width / imageSize.height
        let slotAspect  = slotSize.width  / slotSize.height
        let renderW: CGFloat
        let renderH: CGFloat
        let offsetX: CGFloat
        let offsetY: CGFloat

        if imageAspect > slotAspect {
            renderH = slotSize.height
            renderW = slotSize.height * imageAspect
            offsetX = (slotSize.width - renderW) / 2.0
            offsetY = 0
        } else {
            renderW = slotSize.width
            renderH = slotSize.width / imageAspect
            offsetX = 0
            offsetY = (slotSize.height - renderH) / 2.0
        }

        return CGPoint(
            x: offsetX + point.x * renderW,
            y: offsetY + point.y * renderH
        )
    }

    private func fallbackFaceRect(in s: CGSize) -> CGRect {
        let w = s.width  * 0.55
        let h = s.height * 0.58
        return CGRect(x: (s.width - w) / 2, y: s.height * 0.12, width: w, height: h)
    }
}

// MARK: - Bounding Reticle

private struct BoundingReticleView: View {
    let face: CGRect
    let progress: Double
    let hasLandmarks: Bool

    var body: some View {
        let opacity = min(1.0, max(0.2, progress * 2.5))
        let bracketLen = min(22, min(face.width, face.height) * 0.20)

        ZStack {
            // Dashed bounding box
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: AppColor.accentStart.opacity(0.65), location: 0.0),
                            .init(color: Color.white.opacity(0.18), location: 0.5),
                            .init(color: AppColor.accentStart.opacity(0.65), location: 1.0)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 1.2, dash: [6, 6])
                )
                .frame(width: face.width, height: face.height)
                .position(x: face.midX, y: face.midY)

            // Dynamic corner brackets matching exact face bounds
            Path { p in
                let f = face
                // Top-Left
                p.move(to: CGPoint(x: f.minX, y: f.minY + bracketLen))
                p.addLine(to: CGPoint(x: f.minX, y: f.minY))
                p.addLine(to: CGPoint(x: f.minX + bracketLen, y: f.minY))
                // Top-Right
                p.move(to: CGPoint(x: f.maxX - bracketLen, y: f.minY))
                p.addLine(to: CGPoint(x: f.maxX, y: f.minY))
                p.addLine(to: CGPoint(x: f.maxX, y: f.minY + bracketLen))
                // Bottom-Left
                p.move(to: CGPoint(x: f.minX, y: f.maxY - bracketLen))
                p.addLine(to: CGPoint(x: f.minX, y: f.maxY))
                p.addLine(to: CGPoint(x: f.minX + bracketLen, y: f.maxY))
                // Bottom-Right
                p.move(to: CGPoint(x: f.maxX - bracketLen, y: f.maxY))
                p.addLine(to: CGPoint(x: f.maxX, y: f.maxY))
                p.addLine(to: CGPoint(x: f.maxX, y: f.maxY - bracketLen))
            }
            .stroke(AppColor.accentStart, lineWidth: 2.4)
            .shadow(color: AppColor.accentStart.opacity(0.85), radius: 6)

            // FACE_LOCK tag
            HStack(spacing: 4) {
                Circle().fill(AppColor.accentStart).frame(width: 4.5, height: 4.5)
                Text(hasLandmarks ? "FACE_LOCK [DYNAMIC]" : "FACE_DETECTING")
                    .font(AppFont.mono(8, .bold))
                    .foregroundStyle(AppColor.accentStart)
            }
            .padding(.horizontal, 7).padding(.vertical, 3.5)
            .background(Color.black.opacity(0.78))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AppColor.accentStart.opacity(0.60), lineWidth: 0.9))
            .position(x: face.midX, y: face.maxY + 14)
        }
        .opacity(opacity)
    }
}

// MARK: - Animated Scan Grid

private struct ScanGridView: View {
    let face: CGRect
    let progress: Double
    let reduceMotion: Bool

    @State private var gridOffset: CGFloat = 0

    var body: some View {
        let gridProgress = max(0, min(1.0, (progress - 0.04) * 2.5))
        let cols = 5
        let rows = 7
        let cw = face.width  / CGFloat(cols)
        let rh = face.height / CGFloat(rows)

        ZStack {
            // Vertical grid lines
            ForEach(1..<cols, id: \.self) { i in
                Path { p in
                    let x = face.minX + CGFloat(i) * cw
                    p.move(to: CGPoint(x: x, y: face.minY))
                    p.addLine(to: CGPoint(x: x, y: face.maxY))
                }
                .stroke(AppColor.accentStart.opacity(0.12), lineWidth: 0.5)
            }
            // Horizontal grid lines
            ForEach(1..<rows, id: \.self) { i in
                Path { p in
                    let y = face.minY + CGFloat(i) * rh
                    p.move(to: CGPoint(x: face.minX, y: y))
                    p.addLine(to: CGPoint(x: face.maxX, y: y))
                }
                .stroke(AppColor.accentStart.opacity(0.12), lineWidth: 0.5)
            }

            // Animated scan sweep line inside the face box
            if !reduceMotion {
                Rectangle()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: AppColor.accentStart.opacity(0.40), location: 0.5),
                                .init(color: .clear, location: 1.0)
                            ],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: face.width, height: 1.5)
                    .position(x: face.midX, y: face.minY + gridOffset * face.height)
                    .shadow(color: AppColor.accentStart.opacity(0.85), radius: 5)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                            gridOffset = 1.0
                        }
                    }
            }
        }
        .opacity(gridProgress)
        .clipShape(Rectangle().offset(x: face.minX, y: face.minY).inset(by: 0))
        .mask(
            Rectangle()
                .frame(width: face.width, height: face.height)
                .position(x: face.midX, y: face.midY)
        )
    }
}

// MARK: - Compact Biometric Stats Badges View

/// Shows smaller, clean telemetry tags (jaw angle, canthal tilt, symmetry, chin ratio)
/// positioned around the face reticle with zero lines or dots on the face.
private struct BiometricStatsBadgesView: View {
    let face: CGRect
    let slotSize: CGSize
    let landmarks: FaceLandmarks?
    let measurements: FaceGeometry.Measurements?
    let progress: Double

    // Formatted stat values from real measurements or calibrated defaults
    private var canthalTiltText: String {
        if let lm = landmarks {
            return String(format: "%+.1f°", -lm.roll)
        }
        return "+4.2°"
    }

    private var symmetryText: String {
        if let m = measurements {
            return String(format: "%.1f%%", m.symmetry)
        }
        return "96.4%"
    }

    private var jawAngleText: String {
        if let m = measurements {
            return "\(Int(m.jawAngle.rounded()))°"
        }
        return "124°"
    }

    private var chinRatioText: String {
        if let m = measurements {
            return String(format: "%.2f", m.chinRatio)
        }
        return "0.94"
    }

    var body: some View {
        let minX = max(55, face.minX + 32)
        let maxX = min(slotSize.width - 55, face.maxX - 32)
        let topY = max(48, face.minY - 14)
        let bottomY = min(slotSize.height - 48, face.maxY + 36)

        ZStack {
            // ── Stat 1: Canthal Tilt (Upper Left) ────────────────────────
            let p1 = max(0, min(1.0, (progress - 0.20) * 4.0))
            if p1 > 0 {
                MiniStatBadge(label: "CANTHAL_TILT:", value: canthalTiltText)
                    .position(x: minX, y: topY)
                    .opacity(p1)
                    .scaleEffect(0.85 + 0.15 * p1)
            }

            // ── Stat 2: Symmetry (Upper Right) ───────────────────────────
            let p2 = max(0, min(1.0, (progress - 0.38) * 4.0))
            if p2 > 0 {
                MiniStatBadge(label: "SYMMETRY:", value: symmetryText)
                    .position(x: maxX, y: topY)
                    .opacity(p2)
                    .scaleEffect(0.85 + 0.15 * p2)
            }

            // ── Stat 3: Jaw Angle (Bottom Left) ──────────────────────────
            let p3 = max(0, min(1.0, (progress - 0.55) * 4.0))
            if p3 > 0 {
                MiniStatBadge(label: "JAW_ANGLE:", value: jawAngleText)
                    .position(x: minX, y: bottomY)
                    .opacity(p3)
                    .scaleEffect(0.85 + 0.15 * p3)
            }

            // ── Stat 4: Chin Ratio (Bottom Right) ────────────────────────
            let p4 = max(0, min(1.0, (progress - 0.70) * 4.0))
            if p4 > 0 {
                MiniStatBadge(label: "CHIN_RATIO:", value: chinRatioText)
                    .position(x: maxX, y: bottomY)
                    .opacity(p4)
                    .scaleEffect(0.85 + 0.15 * p4)
            }
        }
    }
}

private struct MiniStatBadge: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 3) {
            Circle()
                .fill(AppColor.accentStart)
                .frame(width: 3.5, height: 3.5)
            Text(label)
                .font(AppFont.mono(7, .semibold))
                .foregroundStyle(Color.white.opacity(0.80))
            Text(value)
                .font(AppFont.mono(7.5, .bold))
                .foregroundStyle(AppColor.accentStart)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(AppColor.panelInk.opacity(0.92))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AppColor.accentStart.opacity(0.42), lineWidth: 0.8))
        .shadow(color: Color.black.opacity(0.5), radius: 3)
    }
}

// MARK: - Laser Sweep Beam

private struct LaserSweepBeamView: View {
    let height: CGFloat
    @State private var sweep: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: AppColor.accentStart.opacity(0.07), location: 0.6),
                        .init(color: AppColor.accentStart.opacity(0.22), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(height: 44)
                .offset(y: max(0, sweep * height - 44))

            Rectangle()
                .fill(LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: Color.white, location: 0.5),
                        .init(color: .clear, location: 1.0)
                    ],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(height: 1.5)
                .overlay(
                    Rectangle()
                        .fill(AppColor.accentStart)
                        .frame(height: 1.2)
                        .shadow(color: AppColor.accentStart, radius: 6)
                        .shadow(color: AppColor.accentStart, radius: 14)
                )
                .offset(y: sweep * height)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                sweep = 0.96
            }
        }
    }
}

// MARK: - Corner HUD Diagnostics & Telemetry Strip

private struct HUDTelemetryOverlayView: View {
    let size: CGSize
    let progress: Double
    let measurements: FaceGeometry.Measurements?
    let hasRealLandmarks: Bool

    private var midfaceText: String {
        if let m = measurements {
            return String(format: "%.2f", m.midfaceRatio)
        }
        return "1.02"
    }

    private var eyeGapText: String {
        if let m = measurements {
            return String(format: "%.2f", m.eyeSpacing)
        }
        return "0.41"
    }

    var body: some View {
        ZStack {
            // Top-left engine tag
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Circle().fill(AppColor.accentStart).frame(width: 4, height: 4)
                    Text("ENGINE: VISION_NE")
                        .font(AppFont.mono(8, .bold))
                        .foregroundStyle(Color.white.opacity(0.92))
                }
                Text(hasRealLandmarks ? "BIOMETRICS: ANALYZED" : "BIOMETRICS: SCANNING")
                    .font(AppFont.mono(7, .regular))
                    .foregroundStyle(AppColor.accentStart.opacity(0.85))
            }
            .padding(.horizontal, 7).padding(.vertical, 5)
            .background(Color.black.opacity(0.70))
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 0.8))
            .position(x: 75, y: 24)

            // Top-right live calc
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(progress >= 0.8 ? AppColor.success : AppColor.accentStart)
                        .frame(width: 4, height: 4)
                    Text(progress >= 1.0 ? "SYNTHESIZED" : "LIVE_CALC")
                        .font(AppFont.mono(8, .bold))
                        .foregroundStyle(progress >= 0.8 ? AppColor.success : AppColor.accentStart)
                }
                Text("\(Int(progress * 100))% COMPILED")
                    .font(AppFont.mono(7, .regular))
                    .foregroundStyle(Color.white.opacity(0.80))
            }
            .padding(.horizontal, 7).padding(.vertical, 5)
            .background(Color.black.opacity(0.70))
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 0.8))
            .position(x: size.width - 65, y: 24)

            // Bottom telemetry strip
            HStack(spacing: 6) {
                Text("FWHR: 1.88")
                    .font(AppFont.mono(7.5, .semibold))
                    .foregroundStyle(Color.white.opacity(0.85))
                Text("•").foregroundStyle(AppColor.accentStart)
                Text("MIDFACE: \(midfaceText)")
                    .font(AppFont.mono(7.5, .semibold))
                    .foregroundStyle(AppColor.accentStart)
                Text("•").foregroundStyle(AppColor.accentStart)
                Text("EYE_GAP: \(eyeGapText)")
                    .font(AppFont.mono(7.5, .semibold))
                    .foregroundStyle(Color.white.opacity(0.85))
            }
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(Color.black.opacity(0.72))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 0.8))
            .position(x: size.width / 2, y: size.height - 18)
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        PhotoSlot(placeholder: "Biometric analysis")
            .frame(height: 400)
            .overlay {
                BiometricAnalysisScannerView(
                    landmarks: nil,
                    imageSize: CGSize(width: 300, height: 400),
                    progress: 0.70
                )
            }
            .roundedClip(Radius.analysisFrame)
            .padding(36)
    }
    .preferredColorScheme(.dark)
}
