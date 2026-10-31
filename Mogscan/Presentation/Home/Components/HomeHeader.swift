import SwiftUI

/// Welcome header with the Settings gear. Settings is reachable from here only —
/// never a tab.
struct HomeHeader: View {
    let greeting: String
    var title: String = DesignContent.Home.title
    let onOpenSettings: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(AppFont.system(14))
                    .foregroundStyle(AppColor.textSecondary)
                Text(title)
                    .font(AppFont.screenTitle)
                    .tracking(Tracking.screenTitle)
                    .lineHeight(1.1, size: 32)
                    .foregroundStyle(AppColor.textPrimary)
            }

            Spacer(minLength: Spacing.m)

            Button(action: onOpenSettings) {
                Image(systemName: AppSymbol.settings)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(AppColor.surfaceControl, in: Circle())
            }
            .buttonStyle(PressableStyle())
            .frame(width: Layout.minimumTouchTarget, height: Layout.minimumTouchTarget, alignment: .trailing)
            .contentShape(Rectangle())
            .padding(.bottom, Spacing.xxs)
            .accessibilityLabel("Settings")
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    ZStack {
        AppBackground()
        HomeHeader(greeting: DesignContent.Home.welcomeReturning) {}
            .padding(.horizontal, Layout.horizontal)
    }
}
