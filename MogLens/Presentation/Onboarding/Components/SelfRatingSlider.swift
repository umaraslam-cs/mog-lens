import SwiftUI
import UIKit

/// Custom interactive step slider (1...10) for the Self Rating onboarding screen.
/// Features a glowing cyan target thumb, discrete tick marks along the track,
/// tactile haptic feedback on step changes, and anchor perception labels.
struct SelfRatingSlider: View {
    @Binding var rating: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let minRating: Int = 1
    private let maxRating: Int = 10

    var body: some View {
        VStack(spacing: Spacing.l) {
            // Slider Track & Thumb Area
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let thumbDiameter: CGFloat = 32
                let trackPadding = thumbDiameter / 2
                let usableWidth = max(0, totalWidth - thumbDiameter)
                let stepFraction = CGFloat(rating - minRating) / CGFloat(maxRating - minRating)
                let thumbX = trackPadding + (stepFraction * usableWidth)

                ZStack(alignment: .leading) {
                    // 1. Inactive Track Base
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.14))
                        .frame(height: 4)
                        .padding(.horizontal, trackPadding)

                    // 2. Discrete Step Tick Marks
                    HStack(spacing: 0) {
                        ForEach(0..<(maxRating - minRating + 1), id: \.self) { index in
                            Rectangle()
                                .fill(
                                    index <= (rating - minRating)
                                        ? AppColor.accentStart.opacity(0.80)
                                        : Color.white.opacity(0.20)
                                )
                                .frame(width: 1.5, height: 10)
                                .clipShape(Capsule())

                            if index < (maxRating - minRating) {
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .padding(.horizontal, trackPadding)

                    // 3. Active Track Overlay
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentStart, AppColor.accentEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, thumbX - trackPadding), height: 4)
                        .padding(.leading, trackPadding)

                    // 4. Interactive Glowing Target Thumb
                    ZStack {
                        // Outer Glow
                        Circle()
                            .fill(AppColor.accentStart.opacity(0.20))
                            .frame(width: thumbDiameter + 10, height: thumbDiameter + 10)
                            .blur(radius: 5)

                        // Outer Ring
                        Circle()
                            .strokeBorder(AppColor.accentStart, lineWidth: 2.5)
                            .background(Circle().fill(Color(hex: 0x06141D)))
                            .frame(width: thumbDiameter, height: thumbDiameter)
                            .shadow(color: AppColor.accentStart.opacity(0.65), radius: 8)

                        // Center Target Dot
                        Circle()
                            .fill(AppColor.accentStart)
                            .frame(width: 7, height: 7)
                    }
                    .position(x: thumbX, y: geometry.size.height / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateRating(with: value.location.x, usableWidth: usableWidth, trackPadding: trackPadding)
                            }
                    )
                }
            }
            .frame(height: 44)

            // Anchor Labels using standard typography
            HStack {
                Text(DesignContent.Onboarding.selfRatingNeedsWork)
                    .font(AppFont.system(11, .semibold))
                    .tracking(Tracking.label)
                    .foregroundStyle(rating <= 3 ? AppColor.accentStart : AppColor.textSecondary)

                Spacer()

                Text(DesignContent.Onboarding.selfRatingAverage)
                    .font(AppFont.system(11, .semibold))
                    .tracking(Tracking.label)
                    .foregroundStyle(rating >= 4 && rating <= 7 ? AppColor.accentStart : AppColor.textSecondary)

                Spacer()

                Text(DesignContent.Onboarding.selfRatingFlawless)
                    .font(AppFont.system(11, .semibold))
                    .tracking(Tracking.label)
                    .foregroundStyle(rating >= 8 ? AppColor.accentStart : AppColor.textSecondary)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
        .background {
            // Glassmorphic card surface
            RoundedRectangle(cornerRadius: Radius.hero, style: .continuous)
                .fill(Color(hex: 0x0A141D).opacity(0.80))
                .background(
                    RoundedRectangle(cornerRadius: Radius.hero, style: .continuous)
                        .fill(AppColor.surface)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.hero, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.16), location: 0),
                                    .init(color: AppColor.accentStart.opacity(0.24), location: 0.2),
                                    .init(color: Color.white.opacity(0.04), location: 1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
    }

    private func updateRating(with touchX: CGFloat, usableWidth: CGFloat, trackPadding: CGFloat) {
        guard usableWidth > 0 else { return }
        let clampedX = min(max(0, touchX - trackPadding), usableWidth)
        let fraction = clampedX / usableWidth
        let newRating = Int(round(Double(minRating) + fraction * Double(maxRating - minRating)))
        let boundedRating = min(max(minRating, newRating), maxRating)

        if boundedRating != rating {
            rating = boundedRating
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}

#Preview("Self Rating Slider") {
    ZStack {
        AppBackground()
        SelfRatingSlider(rating: .constant(6))
            .padding(Layout.horizontal)
    }
    .preferredColorScheme(.dark)
}
