import SwiftUI

/// The app's three-tab shell. Settings is deliberately not a tab — it is only
/// reachable from the gear on Home.
struct MainTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(
                    DesignContent.Tabs.home,
                    systemImage: router.selectedTab == .home ? AppSymbol.homeTabSelected : AppSymbol.homeTab
                )
            }
            .tag(AppRouter.Tab.home)

            // Only the entry screen is a tab. The scan flow itself (capture →
            // analysing → paywall → results) is presented over this shell.
            ScanView()
                .tabItem {
                    Label(DesignContent.Tabs.scan, systemImage: AppSymbol.scanTab)
                }
                .tag(AppRouter.Tab.scan)

            NavigationStack {
                ImproveView()
            }
            .tabItem {
                Label(DesignContent.Tabs.improve, systemImage: AppSymbol.improveTab)
            }
            .tag(AppRouter.Tab.improve)
        }
        .tint(AppColor.accentStart)
    }
}

#Preview("Main tabs") {
    MainTabView()
        .environment(PreviewData.dependencies)
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
