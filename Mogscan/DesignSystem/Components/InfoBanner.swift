import SwiftUI

/// A leading-icon banner. Two weights: a quiet surface used in onboarding, and
/// an accent-washed one used for the Improve priority callout.
struct InfoBanner: View {
    enum Style {
        /// White 3% fill, white 7% hairline, secondary icon.
        case quiet
        /// Accent gradient wash and border, accent icon.
        case accent
    }

    let symbol: String
    let title: String
    var detail: String?
    var style: Style = .quiet
    var symbolSize: CGFloat = 16

    var body: some View {
        HStack(spacing: detail == nil ? Spacing.s : Spacing.m) {
            Image(systemName: symbol)
                .font(.system(size: symbolSize, weight: .medium))
                .foregroundStyle(style == .accent ? AppColor.accentStart : AppColor.textSecondary)

            if let detail {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.subheadlineEmphasis)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(detail)
                        .font(AppFont.footnote)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text(title)
                    .font(AppFont.system(13.5))
                    .lineHeight(1.35, size: 13.5)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, Spacing.ml)
        .padding(.horizontal, Spacing.l)
        .modifier(BannerBackground(style: style))
        .accessibilityElement(children: .combine)
    }
}

private struct BannerBackground: ViewModifier {
    let style: InfoBanner.Style

    func body(content: Content) -> some View {
        switch style {
        case .quiet:
            content.surfaceCard(
                radius: Radius.card,
                fill: AppColor.surfaceSubtle,
                border: AppColor.hairlineQuiet
            )
        case .accent:
            content.gradientCard(
                AppGradient.accentBanner,
                radius: Radius.button,
                border: AppColor.accentStart.opacity(0.2)
            )
        }
    }
}

/// A hairline rule at the design's standard opacity.
struct HairlineDivider: View {
    var color: Color = AppColor.hairlineQuiet

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.m) {
            InfoBanner(
                symbol: AppSymbol.info,
                title: "Your target sets the gap Mogscan measures you against."
            )
            InfoBanner(
                symbol: AppSymbol.priority,
                title: "Priority: lower third",
                detail: "Chin ratio and jaw definition move your score most.",
                style: .accent,
                symbolSize: 20
            )
        }
        .padding(Layout.horizontal)
    }
}
