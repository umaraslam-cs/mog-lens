import SwiftUI

/// A rounded progress track. The unfilled portion is always white at 9%.
///
/// Fills animate 0 → value with `.easeOut(0.5)`; callers stagger siblings by 0.06s.
struct ProgressBarView: View {
    /// 0–1.
    let progress: Double
    var height: CGFloat = 6
    var fill: AnyShapeStyle = AnyShapeStyle(AppColor.success)
    /// Adds a soft accent glow beneath the fill — used by the analysing bar.
    var glow: Bool = false
    /// Set false to render at full width immediately (previews, Reduce Motion).
    var animatesOnAppear: Bool = true
    var delay: Double = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(AppColor.track)
                Capsule(style: .continuous)
                    .fill(fill)
                    .frame(width: geometry.size.width * clamped)
                    .shadow(color: glow ? AppColor.accentStart.opacity(0.5) : .clear, radius: 7)
            }
        }
        .frame(height: height)
        .onAppear {
            guard animatesOnAppear, !reduceMotion else {
                animatedProgress = progress
                return
            }
            withAnimation(AppMotion.barFill.delay(delay)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(reduceMotion ? nil : AppMotion.barFill) {
                animatedProgress = newValue
            }
        }
        .accessibilityHidden(true)
    }

    private var clamped: Double {
        min(max(animatedProgress, 0), 1)
    }
}

extension ProgressBarView {
    /// Convenience for the common case of a flat colour fill.
    init(
        progress: Double,
        height: CGFloat = 6,
        color: Color,
        glow: Bool = false,
        animatesOnAppear: Bool = true,
        delay: Double = 0
    ) {
        self.init(
            progress: progress,
            height: height,
            fill: AnyShapeStyle(color),
            glow: glow,
            animatesOnAppear: animatesOnAppear,
            delay: delay
        )
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.m) {
            ProgressBarView(progress: 0.88, color: AppColor.success)
            ProgressBarView(progress: 0.57, color: AppColor.warning)
            ProgressBarView(progress: 0.29, color: AppColor.negative)
            ProgressBarView(progress: 0.64, height: 5, fill: AnyShapeStyle(AppGradient.accentHorizontal), glow: true)
        }
        .padding(Layout.horizontal)
    }
}
