import SwiftUI

@main
struct MogscanApp: App {
    @State private var dependencies = AppDependencies()

    init() {
        TabBarAppearance.apply()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
                .preferredColorScheme(.dark)
                .tint(AppColor.accentStart)
        }
    }
}
