import SwiftUI

/// Gradient tokens. The app only ever uses two families: the background wash and the accent ramp.
enum AppGradient {

    /// `#000000 0% → #07130A 58% → #0F1A12 100%`, top to bottom.
    static let background = LinearGradient(
        stops: [
            .init(color: AppColor.backgroundTop, location: 0),
            .init(color: AppColor.backgroundMid, location: 0.58),
            .init(color: AppColor.backgroundBottom, location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// `#C6FF3D → #3DFF8A`, top to bottom. Buttons, badges, ring fills.
    static let accent = LinearGradient(
        colors: [AppColor.accentStart, AppColor.accentEnd],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Same ramp laid out horizontally — progress bars and step indicators.
    static let accentHorizontal = LinearGradient(
        colors: [AppColor.accentStart, AppColor.accentEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Pressed state of a primary button: the accent ramp darkened one step.
    static let accentPressed = LinearGradient(
        colors: [Color(hex: 0xA8D934), Color(hex: 0x34D975)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Top tier badge — brighter than the standard accent ramp.
    static let chadBadge = LinearGradient(
        colors: [Color(hex: 0xF4FFE0), AppColor.accentStart],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Hero card wash — `160deg`, accent fading into a bare surface.
    static let heroCard = LinearGradient(
        stops: [
            .init(color: AppColor.accentStart.opacity(0.10), location: 0),
            .init(color: AppColor.accentEnd.opacity(0.05), location: 0.6),
            .init(color: Color.white.opacity(0.03), location: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Banner wash — `150deg`, a quieter version of `heroCard`.
    static let accentBanner = LinearGradient(
        colors: [AppColor.accentStart.opacity(0.12), AppColor.accentEnd.opacity(0.04)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Selected paywall plan wash.
    static let selectedPlan = LinearGradient(
        colors: [AppColor.accentStart.opacity(0.14), AppColor.accentEnd.opacity(0.06)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Scrim that lifts a hero photo into the background gradient.
    static let photoScrim = LinearGradient(
        stops: [
            .init(color: Color.black.opacity(0.35), location: 0),
            .init(color: AppColor.backgroundMid.opacity(0), location: 0.40),
            .init(color: AppColor.backgroundMid, location: 0.96)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Results header scrim — darker at the very top to carry the nav buttons.
    static let resultsScrim = LinearGradient(
        stops: [
            .init(color: Color.black.opacity(0.6), location: 0),
            .init(color: Color.black.opacity(0.1), location: 0.35),
            .init(color: AppColor.backgroundMid, location: 0.98)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Camera preview scrim — dark top and bottom, clear through the middle.
    static let captureScrim = LinearGradient(
        stops: [
            .init(color: Color.black.opacity(0.55), location: 0),
            .init(color: Color.black.opacity(0), location: 0.26),
            .init(color: Color.black.opacity(0), location: 0.62),
            .init(color: Color.black.opacity(0.75), location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Flat tint laid over an analysed photo so landmarks stay legible.
    static let analysisScrim = LinearGradient(
        colors: [Color.black.opacity(0.3), AppColor.backgroundMid.opacity(0.45)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Technology screen scrim.
    static let technologyScrim = LinearGradient(
        colors: [Color.black.opacity(0.25), AppColor.backgroundMid.opacity(0.55)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// The sweep line that travels down the frame while analysing.
    static let sweepLine = LinearGradient(
        colors: [.clear, AppColor.accentStart, .clear],
        startPoint: .leading,
        endPoint: .trailing
    )
}
