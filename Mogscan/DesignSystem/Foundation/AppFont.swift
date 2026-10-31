import SwiftUI

/// Type scale — SF Pro throughout, per the design system's "Type scale" card.
///
/// Every style is built on `Font.system`, so Dynamic Type and the SF Pro optical
/// sizes both apply. Numerals in counters use ``AppFont/mono(_:_:)`` or
/// `.monospacedDigit()` so values don't jitter while they animate.
enum AppFont {

    static func system(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    /// Monospaced numerals for metric values and percentages.
    static func mono(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    // MARK: Scale

    /// 34 / Bold — onboarding questions, the largest title in the app.
    static let largeTitle = system(34, .bold)
    /// 32 / Bold — screen titles and hero statements.
    static let screenTitle = system(32, .bold)
    /// 30 / Bold — paywall headline.
    static let title1 = system(30, .bold)
    /// 28 / Bold — empty state headline.
    static let title2 = system(28, .bold)
    /// 20 / Semibold — section headers.
    static let sectionTitle = system(20, .semibold)
    /// 17 / Semibold — buttons and list headlines.
    static let headline = system(17, .semibold)
    /// 17 / Regular — body copy.
    static let body = system(17)
    /// 16 / Regular.
    static let callout = system(16)
    /// 16 / Semibold — list row titles.
    static let calloutEmphasis = system(16, .semibold)
    /// 15 / Regular.
    static let subheadline = system(15)
    /// 15 / Semibold.
    static let subheadlineEmphasis = system(15, .semibold)
    /// 13 / Regular — captions and footnotes.
    static let footnote = system(13)
    /// 12 / Regular.
    static let caption = system(12)
    /// 12 / Semibold — eyebrows and tier labels, always paired with `.tracking(Tracking.eyebrow)`.
    static let eyebrow = system(12, .semibold)
    /// 10 / Medium — tab bar labels.
    static let tabLabel = system(10, .medium)

    // MARK: One-off sizes used by specific components

    static let heroScore = system(66, .bold)
    static let ringScore = system(32, .bold)
    static let splashWordmark = system(34, .bold)
    static let splashSubtitle = system(14, .medium)
}

/// Letter-spacing tokens. CSS `em` values converted to points at their own size.
enum Tracking {
    /// `-0.02em` on a 34pt title.
    static let largeTitle: CGFloat = -0.68
    /// `-0.02em` on a 32pt title.
    static let screenTitle: CGFloat = -0.64
    /// `-0.02em` on a 30pt title.
    static let title1: CGFloat = -0.6
    /// `-0.02em` on a 28pt title.
    static let title2: CGFloat = -0.56
    /// `-0.04em` on the 66pt results score.
    static let heroScore: CGFloat = -2.64
    /// `-0.01em` on a 20pt section header.
    static let sectionTitle: CGFloat = -0.2
    /// `+0.16em` on a 12pt eyebrow.
    static let eyebrow: CGFloat = 1.92
    /// `+0.16em` on an 11pt label.
    static let label: CGFloat = 1.76
    /// `+0.14em` on a 12pt caption.
    static let caption: CGFloat = 1.68
    /// `+0.06em` on a badge or tier label.
    static let badge: CGFloat = 0.9
    /// `+0.08em` on a settings section header.
    static let settingsHeader: CGFloat = 1.0
    /// `+0.16em` on the splash wordmark.
    static let wordmark: CGFloat = 5.44
    /// `+0.28em` on the splash subtitle.
    static let wordmarkSubtitle: CGFloat = 3.92
}

extension View {
    /// Applies a CSS-style `line-height` multiplier as SwiftUI line spacing.
    ///
    /// SwiftUI's `lineSpacing` is the gap *between* lines, so the leading is
    /// derived from the font size rather than set absolutely.
    func lineHeight(_ multiple: CGFloat, size: CGFloat) -> some View {
        lineSpacing(max(0, size * (multiple - 1)))
    }
}
