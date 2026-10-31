import SwiftUI

/// The Mogscan mark: the logo scanned into view.
///
/// The mark sits dim, an accent sweep travels down it once, and everything the
/// sweep has passed is left at full strength — the same gesture the analysing
/// screen makes, so the brand's first moment states what the app does.
///
/// Mark scales 0.92 → 1 with `.spring(response: 0.6, dampingFraction: 0.7)`;
/// the sweep takes ``AppMotion/splashRevealDuration``, well inside the hold.
struct SplashLogoMark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// 0 → 1 as the sweep travels top to bottom. Drives the reveal mask and the
    /// sweep line together, so the line always rides the revealed edge.
    @State private var reveal: CGFloat = 0
    @State private var sweepOpacity: Double = 1
    @State private var hasAppeared = false

    var diameter: CGFloat = 132

    var body: some View {
        ZStack {
            // Unscanned: the mark is present but inert until the sweep reaches it.
            logo.opacity(0.2)

            logo.mask(alignment: .top) { revealMask }

            sweepLine
        }
        .frame(width: diameter, height: diameter)
        // Decorative — as a background it can never widen the mark's layout.
        .background { RadialGlow(opacity: 0.2, diameter: diameter * 1.8, falloff: 0.72) }
        .scaleEffect(hasAppeared ? 1 : 0.92)
        .onAppear(perform: start)
        .accessibilityHidden(true)
    }

    private var logo: some View {
        Image(AppImage.logo)
            .resizable()
            .scaledToFit()
    }

    /// Opaque down to the sweep, with a short gradient at the edge so the
    /// boundary reads as light falling across the mark, not as a cut.
    private var revealMask: some View {
        LinearGradient(
            stops: [
                .init(color: .white, location: 0),
                .init(color: .white, location: 0.78),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: diameter * reveal)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var sweepLine: some View {
        Rectangle()
            .fill(AppGradient.sweepLine)
            .frame(height: 1.5)
            .shadow(color: AppColor.accentStart.opacity(0.9), radius: 9)
            .frame(maxHeight: .infinity, alignment: .top)
            .offset(y: diameter * reveal)
            .opacity(sweepOpacity)
    }

    private func start() {
        withAnimation(reduceMotion ? nil : AppMotion.splashMark) {
            hasAppeared = true
        }

        // Reduce Motion still gets the finished mark, just without the travel.
        guard !reduceMotion else {
            reveal = 1
            sweepOpacity = 0
            return
        }

        let duration = AppMotion.splashRevealDuration
        withAnimation(.easeInOut(duration: duration)) {
            reveal = 1
        }
        withAnimation(.easeOut(duration: 0.28).delay(duration - 0.2)) {
            sweepOpacity = 0
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        SplashLogoMark()
    }
}
