import SwiftUI

/// The one card treatment used across the app: a translucent white surface over
/// the background gradient, with a hairline border. Never a solid grey fill.
struct SurfaceCardModifier: ViewModifier {
    var fill: Color = AppColor.surface
    var border: Color = AppColor.hairline
    var borderWidth: CGFloat = 1
    var radius: CGFloat = Radius.listCard

    func body(content: Content) -> some View {
        content
            .background(fill, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(border, lineWidth: borderWidth)
            }
    }
}

/// A card whose fill is a gradient rather than a flat translucent white.
struct GradientCardModifier: ViewModifier {
    var gradient: LinearGradient
    var border: Color
    var borderWidth: CGFloat = 1
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(gradient, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(border, lineWidth: borderWidth)
            }
    }
}

extension View {
    /// Standard translucent card surface.
    func surfaceCard(
        radius: CGFloat = Radius.listCard,
        fill: Color = AppColor.surface,
        border: Color = AppColor.hairline,
        borderWidth: CGFloat = 1
    ) -> some View {
        modifier(SurfaceCardModifier(fill: fill, border: border, borderWidth: borderWidth, radius: radius))
    }

    /// Card surface filled with a gradient — hero cards, banners, selected plans.
    func gradientCard(
        _ gradient: LinearGradient,
        radius: CGFloat,
        border: Color,
        borderWidth: CGFloat = 1
    ) -> some View {
        modifier(GradientCardModifier(gradient: gradient, border: border, borderWidth: borderWidth, radius: radius))
    }

    /// Clips to a continuous rounded rectangle — matches iOS's squircle corners.
    func roundedClip(_ radius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
