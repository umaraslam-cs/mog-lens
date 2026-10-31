import SwiftUI

extension Color {
    /// Creates a colour from a packed 24-bit RGB literal, e.g. `Color(hex: 0x3FD4D9)`.
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
    static let backgroundMid = Color(hex: 0x06131C)
    static let backgroundBottom = Color(hex: 0x0E1F2E)

    // MARK: Accent

    static let accentStart = Color(hex: 0x3FD4D9)
    static let accentEnd = Color(hex: 0x2A8FD6)
    /// Foreground used on top of the accent gradient.
    static let onAccent = Color(hex: 0x04141B)

    // MARK: Text

    static let textPrimary = Color(hex: 0xEAEAEA)
    static let textSecondary = Color(hex: 0x8B98A3)

    // MARK: Semantic

    /// Excellent — ≥ 75th percentile.
    static let success = Color(hex: 0x37D67A)
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
    static let scoreRingCore = Color(hex: 0x08151E)
    static let tabBarBackground = Color(hex: 0x081017).opacity(0.86)
    static let sheetTop = Color(hex: 0x0B1721)
    static let sheetBottom = Color(hex: 0x0E1F2E)
    /// System alert chrome — matched to iOS, never restyled.
    static let systemAlertSurface = Color(hex: 0x262C32).opacity(0.92)
    static let systemBlue = Color(hex: 0x0A84FF)

    // MARK: Tinted fills

    static func accentTint(_ opacity: Double) -> Color { accentStart.opacity(opacity) }
    static func secondaryTint(_ opacity: Double) -> Color { textSecondary.opacity(opacity) }
}
