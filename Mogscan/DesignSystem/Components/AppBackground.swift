import SwiftUI

/// The app-wide background wash. Every screen sits on this.
struct AppBackground: View {
    var body: some View {
        AppGradient.background
            .ignoresSafeArea()
    }
}

/// A soft radial accent glow. Used behind logos, empty states and paywall headers.
struct RadialGlow: View {
    var color: Color = AppColor.accentStart
    var opacity: Double = 0.16
    var diameter: CGFloat
    /// Where the gradient reaches full transparency, 0–1.
    var falloff: Double = 0.68

    var body: some View {
        RadialGradient(
            stops: [
                .init(color: color.opacity(opacity), location: 0),
                .init(color: color.opacity(0), location: falloff)
            ],
            center: .center,
            startRadius: 0,
            endRadius: diameter / 2
        )
        .frame(width: diameter, height: diameter)
        .allowsHitTesting(false)
    }
}

/// A ``RadialGlow`` that slowly breathes between 18% and 42% opacity.
/// Falls back to a static glow under Reduce Motion.
struct BreathingGlow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var color: Color = AppColor.accentStart
    var opacity: Double = 0.16
    var diameter: CGFloat
    var duration: Double = AppMotion.breatheDuration

    var body: some View {
        RadialGlow(color: color, opacity: opacity, diameter: diameter)
            .opacity(isExpanded ? 0.42 : 0.18)
            .onAppear {
                guard !reduceMotion else {
                    isExpanded = true
                    return
                }
                withAnimation(.easeInOut(duration: duration / 2).repeatForever(autoreverses: true)) {
                    isExpanded = true
                }
            }
    }
}

#Preview {
    ZStack {
        AppBackground()
        BreathingGlow(diameter: 320)
    }
}
