import SwiftUI

/// Motion spec. Every value here comes from the design system's "Motion spec" card.
///
/// All looping animations are gated on Reduce Motion at the call site via
/// ``SwiftUI/View/respectingReduceMotion(_:)``.
enum AppMotion {

    // MARK: Splash

    /// Mark scales 0.92 → 1.
    static let splashMark = Animation.spring(response: 0.6, dampingFraction: 0.7)
    /// The sweep travels the mark once, revealing it as it passes.
    static let splashRevealDuration: Double = 1.1
    /// Hold before cross-fading to onboarding.
    static let splashHold: Double = 1.8

    // MARK: Interaction

    /// Buttons scale to 0.97 on press.
    static let buttonPress = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let pressedScale: CGFloat = 0.97
    /// Onboarding step change — slide + opacity. The design specifies 0.25s;
    /// that was set against a phone frame inside a browser, and reads abrupt
    /// when the same slide moves the whole viewport.
    static let stepTransition = Animation.easeInOut(duration: 0.3)

    // MARK: Appearance

    /// Cards fade in and rise 16pt on first appear only.
    static let cardAppear = Animation.easeOut(duration: 0.35)
    static let cardAppearOffset: CGFloat = 16
    /// Stagger between sibling cards.
    static let cardStagger: Double = 0.06
    /// Text blocks rise 12pt with a 0.05s stagger per line.
    static let textAppearOffset: CGFloat = 12
    static let textStagger: Double = 0.05

    // MARK: Data reveal

    /// Home score ring trims 0 → score.
    static let ringTrim = Animation.easeOut(duration: 0.9)
    /// Results score counts up.
    static let scoreCountDuration: Double = 0.8
    /// Tier badge springs in after the count.
    static let tierBadgeDelay: Double = 0.4
    static let tierBadge = Animation.spring(response: 0.45, dampingFraction: 0.6)
    /// Metric bars fill left to right.
    static let barFill = Animation.easeOut(duration: 0.5)
    static let barStagger: Double = 0.06
    /// Progress step rows swap spinner → checkmark.
    static let stepStateChange = Animation.easeInOut(duration: 0.2)
    /// Gap between analysis steps completing — five steps, so nine seconds total.
    ///
    /// Deliberately longer than the work takes: Vision returns in well under a
    /// second, and the client asked the scan to read as 8–10 seconds so it feels
    /// substantial. The pacing is the product, not a placeholder.
    static let analysisStepInterval: Double = 1.8

    /// Held before the analysis failure alert is raised.
    ///
    /// Vision rejects a photo with no face in it faster than the push onto the
    /// analysing screen finishes animating, and an alert raised mid-transition
    /// is dropped by SwiftUI — the user sees nothing. Waiting out the push is

    // MARK: Ambient loops

    /// Scan sweep travels the frame.
    static let sweepDuration: Double = 2.6
    /// Landmark dots pulse.
    static let landmarkPulseDuration: Double = 2.4
    static let landmarkStagger: Double = 0.2
    /// Radial glows breathe.
    static let breatheDuration: Double = 6
    /// Inline spinners.
    static let spinnerDuration: Double = 0.9
}
