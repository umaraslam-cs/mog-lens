import SwiftUI

/// Bottom-anchored call to action.
///
/// Sits 32pt above the home indicator — 12pt inside the bottom safe area — and
/// stacks any supporting copy underneath the button.
struct BottomCTA<Content: View>: View {
    var horizontalPadding: CGFloat = Layout.horizontal
    var bottomInset: CGFloat = Layout.bottomCTAInset
    var spacing: CGFloat = Spacing.m
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, bottomInset)
    }
}

/// Supporting caption under a CTA, e.g. "Analysis runs on-device.".
struct CTACaption: View {
    let text: String
    var size: CGFloat = 12.5
    var color: Color = AppColor.textSecondary

    var body: some View {
        Text(text)
            .font(AppFont.system(size))
            .foregroundStyle(color)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        AppBackground()
        BottomCTA {
            PrimaryButton(title: "Run Your First Scan", symbol: AppSymbol.takePhoto) {}
            CTACaption(text: "Analysis runs on-device.")
        }
    }
}
