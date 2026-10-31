import SwiftUI

/// The tier pill. Its weight rises with the tier: translucent for LTN/MTN,
/// the accent ramp for HTN upward, with a glow from Chad Lite.
struct TierBadge: View {
    enum Size {
        /// Home hero card.
        case medium
        /// Results header.
        case large
        /// Component sheet / inline use.
        case small

        var font: Font {
            switch self {
            case .small: AppFont.system(14, .bold)
            case .medium: AppFont.system(15, .bold)
            case .large: AppFont.system(16, .bold)
            }
        }

        var padding: (horizontal: CGFloat, vertical: CGFloat) {
            switch self {
            case .small: (14, 6)
            case .medium: (14, 6)
            case .large: (18, 7)
            }
        }

        var tracking: CGFloat {
            switch self {
            case .small, .medium: 0.75
            case .large: Tracking.badge
            }
        }
    }

    let tier: FacialTier
    var size: Size = .medium

    var body: some View {
        Text(tier.displayName)
            .font(size.font)
            .tracking(size.tracking)
            .foregroundStyle(foreground)
            .padding(.horizontal, size.padding.horizontal)
            .padding(.vertical, size.padding.vertical)
            .background(background)
            .overlay {
                if let border {
                    Capsule().strokeBorder(border, lineWidth: 1)
                }
            }
            .clipShape(Capsule())
            .shadow(color: glow.color, radius: glow.radius)
            .accessibilityLabel("Tier \(tier.displayName)")
    }

    @ViewBuilder
    private var background: some View {
        switch tier.emphasis {
        case .quiet:
            Capsule().fill(AppColor.surfaceControl)
        case .neutral:
            Capsule().fill(AppColor.hairlineStrong)
        case .accent, .accentGlow:
            Capsule().fill(AppGradient.accent)
        case .peak:
            Capsule().fill(AppGradient.chadBadge)
        }
    }

    private var foreground: Color {
        switch tier.emphasis {
        case .quiet: AppColor.textSecondary
        case .neutral: AppColor.textPrimary
        case .accent, .accentGlow, .peak: AppColor.onAccent
        }
    }

    private var border: Color? {
        switch tier.emphasis {
        case .quiet: AppColor.hairlineBold
        case .neutral: Color.white.opacity(0.2)
        default: nil
        }
    }

    private var glow: (color: Color, radius: CGFloat) {
        switch tier.emphasis {
        case .accentGlow: (AppColor.accentStart.opacity(0.45), 10)
        case .peak: (AppColor.accentStart.opacity(0.6), 14)
        default: (.clear, 0)
        }
    }
}

/// The bare text form of a tier, used in dense history rows.
struct TierLabel: View {
    let tier: FacialTier

    var body: some View {
        Text(tier.displayName.uppercased())
            .font(AppFont.system(11, .bold))
            .tracking(Tracking.badge)
            .foregroundStyle(tier.emphasis == .quiet || tier.emphasis == .neutral
                             ? AppColor.textSecondary
                             : AppColor.accentStart)
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.s) {
            ForEach(FacialTier.allCases) { tier in
                TierBadge(tier: tier, size: .small)
            }
        }
    }
}
