import SwiftUI
import UIKit

/// Configures the native tab bar to the design's chrome: a translucent
/// `#081017` at 86% over a dark blur, a white 8% hairline on top, and 10pt
/// medium labels in the accent / secondary pair.
enum TabBarAppearance {
    static func apply() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterialDark)
        appearance.backgroundColor = UIColor(AppColor.tabBarBackground)
        appearance.shadowColor = UIColor(AppColor.hairline)

        let itemAppearance = UITabBarItemAppearance()
        configure(itemAppearance.normal, color: UIColor(AppColor.textSecondary))
        configure(itemAppearance.selected, color: UIColor(AppColor.accentStart))

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private static func configure(_ appearance: UITabBarItemStateAppearance, color: UIColor) {
        appearance.iconColor = color
        appearance.titleTextAttributes = [
            .foregroundColor: color,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
    }
}
