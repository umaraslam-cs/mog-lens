import SwiftUI

/// A single detected landmark, positioned in unit space over its photo.
struct LandmarkPoint: Identifiable, Hashable {
    let id: Int
    /// 0–1 across the frame.
    let x: CGFloat
    /// 0–1 down the frame.
    let y: CGFloat
}

/// A connector drawn between two unit-space points.
struct LandmarkConnector: Identifiable, Hashable {
    let id: Int
    let from: CGPoint
    let to: CGPoint
}

/// Draws Vision landmarks and their connectors over a photo.
///
/// Dots optionally pulse in sequence with a 0.2s stagger; connectors draw with a
/// trim animation. Both are static under Reduce Motion.
struct LandmarkOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPulsing = false
    @State private var connectorProgress: CGFloat = 0

    let points: [LandmarkPoint]
    var connectors: [LandmarkConnector] = []
    var dotSize: CGFloat = 5
    var color: Color = AppColor.accentStart
    var connectorOpacity: Double = 0.45
    /// Sequenced pulse — used while a scan is running.
    var pulses: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(connectors) { connector in
                    Path { path in
                        path.move(to: CGPoint(
                            x: connector.from.x * geometry.size.width,
                            y: connector.from.y * geometry.size.height
                        ))
                        path.addLine(to: CGPoint(
                            x: connector.to.x * geometry.size.width,
                            y: connector.to.y * geometry.size.height
                        ))
                    }
                    .trim(from: 0, to: connectorProgress)
                    .stroke(color.opacity(connectorOpacity), lineWidth: 1)
                }

                ForEach(points) { point in
                    Circle()
                        .fill(color)
                        .frame(width: dotSize, height: dotSize)
                        .shadow(color: color, radius: dotSize * 1.5)
                        .opacity(opacity(for: point))
                        .position(
                            x: point.x * geometry.size.width,
                            y: point.y * geometry.size.height
                        )
                        .animation(pulseAnimation(for: point), value: isPulsing)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else {
                connectorProgress = 1
                return
            }
            withAnimation(.easeOut(duration: 0.6)) { connectorProgress = 1 }
            if pulses { isPulsing = true }
        }
    }

    private func opacity(for point: LandmarkPoint) -> Double {
        guard pulses, !reduceMotion else { return 1 }
        return isPulsing ? 1 : 0.25
    }

    private func pulseAnimation(for point: LandmarkPoint) -> Animation? {
        guard pulses, !reduceMotion else { return nil }
        // Stagger wraps every eight points: a dense mesh staggered by index
        // alone would take a quarter of a minute to finish one pass.
        return .easeInOut(duration: AppMotion.landmarkPulseDuration / 2)
            .repeatForever(autoreverses: true)
            .delay(Double(point.id % 8) * AppMotion.landmarkStagger)
    }
}

#Preview {
    ZStack {
        AppBackground()
        PhotoSlot(placeholder: "Male portrait, front-on, neutral expression")
            .frame(height: 268)
            .overlay {
                LandmarkOverlay(
                    points: LandmarkLayout.analysing,
                    connectors: LandmarkLayout.analysingConnectors,
                    pulses: true
                )
            }
            .roundedClip(Radius.frame)
            .padding(Layout.horizontal)
    }
}
