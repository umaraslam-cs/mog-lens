import Foundation

/// Holds the splash hold duration and signals when to advance.
@Observable
final class SplashViewModel {
    let wordmark = DesignContent.Splash.wordmark
    let subtitle = DesignContent.Splash.subtitle
    let footer = DesignContent.Splash.footer

    private(set) var isFinished = false

    /// Auto-advances after 1.8s.
    func startHold() async {
        try? await Task.sleep(for: .seconds(AppMotion.splashHold))
        isFinished = true
    }
}
