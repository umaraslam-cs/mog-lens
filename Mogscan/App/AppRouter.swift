import SwiftUI

/// Drives which top-level surface is on screen.
///
/// Launch → onboarding → scan flow → tabs. The first scan runs standalone, with
/// no tab bar, and hands over to the tab shell on Home once Results is left.
/// Settings is a sheet reachable only from Home.
@Observable
final class AppRouter {

    enum Phase {
        case splash
        case onboarding
        /// The scan flow on its own, outside the tab shell.
        case scan
        case main
    }

    enum Tab: Hashable {
        case home
        case scan
        case improve
    }

    var phase: Phase = .splash
    var selectedTab: Tab = .home
    var isShowingSettings = false

    /// Set once onboarding finishes, and kept across launches.
    ///
    /// `UserDefaults` directly rather than `@AppStorage`, which is a property
    /// wrapper for views and does not belong on an `@Observable` model.
    private(set) var hasOnboarded: Bool {
        didSet { defaults.set(hasOnboarded, forKey: Key.hasOnboarded) }
    }

    /// The tier the user said they were training toward, from onboarding.
    ///
    /// Nil until onboarding completes — Results and the paywall simply omit the
    /// target line rather than inventing one. Stored with ``hasOnboarded``,
    /// because a returning user never sees the question again and the target
    /// would otherwise be lost on the first relaunch.
    private(set) var targetRank: FacialTier? {
        didSet { defaults.set(targetRank?.rawValue, forKey: Key.targetRank) }
    }

    private let defaults: UserDefaults

    private enum Key {
        static let hasOnboarded = "hasOnboarded"
        static let targetRank = "targetRank"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasOnboarded = defaults.bool(forKey: Key.hasOnboarded)
        self.targetRank = defaults.string(forKey: Key.targetRank)
            .flatMap(FacialTier.init(rawValue:))
    }

    func splashDidFinish() {
        phase = hasOnboarded ? .main : .onboarding
    }

    func onboardingDidFinish(with answers: OnboardingAnswers) {
        hasOnboarded = true
        targetRank = answers.targetRank
        phase = .scan
    }

    #if DEBUG
    /// Puts the app back to a first launch, for checking the intro without
    /// reinstalling and losing the scan history with it. Debug builds only.
    func resetOnboarding() {
        hasOnboarded = false
        targetRank = nil
        isShowingSettings = false
        phase = .onboarding
    }
    #endif

    /// Leaving Results ends the scan flow. Shows the tab shell on `tab`, whether
    /// the flow ran standalone after onboarding or inside the Scan tab.
    func scanFlowDidFinish(landingOn tab: Tab = .home) {
        phase = .main
        selectedTab = tab
    }

    func showSettings() {
        isShowingSettings = true
    }

    func select(_ tab: Tab) {
        selectedTab = tab
    }
}
