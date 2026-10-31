import SwiftUI

/// Top-level container. Cross-fades splash → onboarding → tabs.
struct RootView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var router = AppRouter()

    var body: some View {
        ZStack {
            AppBackground()

            switch router.phase {
            case .splash:
                SplashView { router.splashDidFinish() }
                    .transition(.opacity)
            case .onboarding:
                OnboardingFlowView { router.onboardingDidFinish(with: $0) }
                    .transition(.opacity)
            case .scan:
                // First scan, outside the tab shell — no tab bar until Results.
                ScanView()
                    .transition(.opacity)
            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .environment(router)
        .animation(.easeInOut(duration: 0.35), value: router.phase)
        .task {
            // Warms the entitlement cache while the splash is up. It starts
            // locked every cold launch, and the first scan reads it
            // synchronously — without this a subscriber would be shown the
            // paywall for something they already own.
            await dependencies.refreshEntitlement()
        }
    }
}

#Preview("Root") {
    RootView()
        .environment(PreviewData.dependencies)
}
