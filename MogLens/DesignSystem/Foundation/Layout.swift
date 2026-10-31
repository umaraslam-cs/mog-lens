import SwiftUI

/// 8pt spacing system, per the design system's "8pt spacing & radii" card.
enum Spacing {
    /// 4 — icon to label.
    static let xxs: CGFloat = 4
    /// 6 — chip gutters.
    static let xxsPlus: CGFloat = 6
    /// 8 — inside a card.
    static let xs: CGFloat = 8
    /// 10 — tight stacks.
    static let s: CGFloat = 10
    /// 12 — between sibling cards.
    static let m: CGFloat = 12
    /// 14 — icon to text block.
    static let ml: CGFloat = 14
    /// 16 — card padding.
    static let l: CGFloat = 16
    /// 18 — generous card padding.
    static let xl: CGFloat = 18
    /// 20 — screen side margin.
    static let screen: CGFloat = 20
    /// 22 — sheet padding.
    static let xxl: CGFloat = 22
    /// 24 — between sections.
    static let section: CGFloat = 24
    /// 26 — between settings groups.
    static let group: CGFloat = 26
    /// 32 — above a bottom CTA.
    static let bottomCTA: CGFloat = 32
}

/// Corner radii: 10 controls · 16 buttons & cards · 18 list cards · 24 hero cards.
enum Radius {
    static let chip: CGFloat = 6
    static let iconTileSmall: CGFloat = 8
    /// 10 — controls and selection bands.
    static let control: CGFloat = 10
    static let iconTile: CGFloat = 11
    /// 14 — grouped lists and sheets.
    static let card: CGFloat = 14
    /// 16 — buttons and metric cards.
    static let button: CGFloat = 16
    /// 18 — list cards and plan cards.
    static let listCard: CGFloat = 18
    /// 20 — wheel picker wells.
    static let well: CGFloat = 20
    /// 22 — framed imagery.
    static let frame: CGFloat = 22
    /// 24 — hero cards.
    static let hero: CGFloat = 24
    /// 26 — the analysis frame.
    static let analysisFrame: CGFloat = 26
    /// Fully rounded.
    static let pill: CGFloat = 999
}

/// Fixed geometry shared across screens.
enum Layout {
    /// Screen side margin.
    static let horizontal: CGFloat = 20
    /// Minimum hit target, per HIG.
    static let minimumTouchTarget: CGFloat = 44
    /// Primary button height — above the 44pt minimum.
    static let buttonHeight: CGFloat = 54
    /// Paywall CTA is one step taller.
    static let prominentButtonHeight: CGFloat = 56
    /// Tab bar content height, excluding the bottom safe area.
    static let tabBarHeight: CGFloat = 49
    /// Bottom CTAs sit 32pt above the home indicator, i.e. 12pt inside the safe area.
    static let bottomCTAInset: CGFloat = 12
    /// Gap between the top safe area and the first element on most screens.
    static let contentTopInset: CGFloat = 8
    /// Height of a circular overlay button on a photo.
    static let overlayButton: CGFloat = 32

    /// The height each screen's fixed-size imagery was drawn against: what an
    /// iPhone leaves that screen once the safe areas, the tab bar and the pinned
    /// CTA are taken out. ``designFit(slot:design:)`` clamps at 1, so every
    /// supported iPhone renders its imagery at the designed size and only a
    /// 4.7-inch phone or an iPad compatibility window shrinks it.
    enum DesignSlot {
        /// An iPhone 13 mini's 728pt content, less a 66pt Continue and the
        /// slot's own bottom margin — the shortest notched phone, so nothing
        /// above it compresses.
        static let onboarding: CGFloat = 662
        /// The content area an iPhone 17 Pro leaves once the tab bar and the
        /// two-button CTA are out, with a little headroom so the largest phones
        /// land safely on 1.
        static let scanEntry: CGFloat = 575
        /// The whole content area, less the padding under it — Analysing has no
        /// CTA.
        static let analysing: CGFloat = 704
    }
}

/// Shadow tokens.
enum AppShadow {
    /// Primary button — `0 10px 34px rgba(42,143,214,.34)`.
    static let primaryButton = (color: AppColor.accentEnd.opacity(0.34), radius: CGFloat(17), y: CGFloat(10))
    /// Paywall CTA — a touch stronger.
    static let prominentButton = (color: AppColor.accentEnd.opacity(0.4), radius: CGFloat(17), y: CGFloat(10))
    /// Accent glow with no offset.
    static func glow(_ opacity: Double, radius: CGFloat) -> (color: Color, radius: CGFloat, y: CGFloat) {
        (AppColor.accentStart.opacity(opacity), radius, 0)
    }
}

extension View {
    /// Applies a shadow tuple from ``AppShadow``.
    func appShadow(_ shadow: (color: Color, radius: CGFloat, y: CGFloat)) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
    }
}
