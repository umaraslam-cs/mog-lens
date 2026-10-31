import SwiftUI

extension Color {
    /// Creates a colour from a packed 24-bit RGB literal, e.g. `Color(hex: 0xC6FF3D)`.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// Colour tokens. Mirrors the "Color tokens" card of the design system 1:1.
///
/// Surfaces are white at 4.5% over the background gradient; hairlines white at 8%.
/// Never a solid grey fill.
enum AppColor {

    // MARK: Background

    static let backgroundTop = Color(hex: 0x000000)
    static let backgroundMid = Color(hex: 0x07130A)
    static let backgroundBottom = Color(hex: 0x0F1A12)

    // MARK: Accent

    static let accentStart = Color(hex: 0xC6FF3D)
    static let accentEnd = Color(hex: 0x3DFF8A)
    /// Foreground used on top of the accent gradient.
    static let onAccent = Color(hex: 0x0A1405)

    // MARK: Text

    static let textPrimary = Color(hex: 0xEAEDEA)
    static let textSecondary = Color(hex: 0x8FA094)

    // MARK: Semantic

    /// Excellent — ≥ 75th percentile. Cyan rather than green so a strong score
    /// never blends into the lime accent it sits beside.
    static let success = Color(hex: 0x3DDCFF)
    /// Average — 40th–74th percentile.
    static let warning = Color(hex: 0xFFB84D)
    /// Needs improvement — < 40th percentile.
    static let negative = Color(hex: 0xFF6B4A)

    // MARK: Surfaces & hairlines

    static let surfaceSubtle = Color.white.opacity(0.03)
    static let surfaceQuiet = Color.white.opacity(0.04)
    static let surface = Color.white.opacity(0.045)
    static let surfaceRaised = Color.white.opacity(0.05)
    static let surfaceStrong = Color.white.opacity(0.06)
    static let surfaceControl = Color.white.opacity(0.07)

    static let hairlineFaint = Color.white.opacity(0.06)
    static let hairlineQuiet = Color.white.opacity(0.07)
    static let hairline = Color.white.opacity(0.08)
    static let hairlineStrong = Color.white.opacity(0.09)
    static let hairlineBold = Color.white.opacity(0.14)

    /// Unfilled portion of any progress track.
    static let track = Color.white.opacity(0.09)

    /// Dims the camera preview outside the face guide.
    static let captureDim = Color.black.opacity(0.32)

    // MARK: Component-specific

    /// Core disc punched out of the home score ring.
    static let scoreRingCore = Color(hex: 0x09150C)
    static let tabBarBackground = Color(hex: 0x08100A).opacity(0.86)
    static let sheetTop = Color(hex: 0x0C170E)
    static let sheetBottom = Color(hex: 0x0F1A12)
    /// System alert chrome — matched to iOS, never restyled.
    static let systemAlertSurface = Color(hex: 0x262C32).opacity(0.92)
    static let systemBlue = Color(hex: 0x0A84FF)

    // MARK: Panels

    /// Opaque card fill laid over photos and video, where a 4.5% white surface
    /// would let the artwork show through. Usually drawn at 75–90% opacity.
    static let panel = Color(hex: 0x0B150E)
    /// Darker panel for floating chips and the expert/social-proof cards.
    static let panelDeep = Color(hex: 0x0D120E)
    /// Near-background fill for inset rows and the scanner readout.
    static let panelInk = Color(hex: 0x08120B)
    /// Bottom of the technology screen's video fade, one step below `panelInk`.
    static let technologyFade = Color(hex: 0x050C07)
    /// Empty photo slot, top to bottom.
    static let photoPlaceholderTop = Color(hex: 0x0B180E)
    static let photoPlaceholderBottom = Color(hex: 0x132B19)
    /// Expert avatar disc, top to bottom.
    static let avatarTop = Color(hex: 0x0F2314)
    static let avatarBottom = Color(hex: 0x07160A)
    /// Filled rating star — the App Store gold, not a brand colour.
    static let ratingStar = Color(hex: 0xFFD700)

    // MARK: Tinted fills

    static func accentTint(_ opacity: Double) -> Color { accentStart.opacity(opacity) }
    static func secondaryTint(_ opacity: Double) -> Color { textSecondary.opacity(opacity) }
}
