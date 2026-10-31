import SwiftUI

/// A rounded, tinted container for a leading SF Symbol.
/// Used by Improve cards (38pt), Settings rows (29pt) and the paywall lock (56pt).
struct IconTile: View {
    let symbol: String
    var size: CGFloat = 38
    var radius: CGFloat = Radius.iconTile
    var symbolSize: CGFloat = 18
    var tint: Color = AppColor.accentStart
    var fillOpacity: Double = 0.14
    var border: Color?

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: symbolSize, weight: .medium))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(
                tint.opacity(fillOpacity),
                in: RoundedRectangle(cornerRadius: radius, style: .continuous)
            )
            .overlay {
                if let border {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(border, lineWidth: 1)
                }
            }
            .accessibilityHidden(true)
    }
}

/// Small colour-coded chip — difficulty and time commitment on Improve cards.
struct Chip: View {
    let text: String
    var foreground: Color = AppColor.textSecondary
    var background: Color = AppColor.surfaceStrong

    var body: some View {
        Text(text)
            .font(AppFont.system(11, .semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, 3)
            .background(background, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
    }
}

extension Chip {
    /// Difficulty chip, tinted by level.
    init(difficulty: RecommendationDifficulty) {
        let color: Color = switch difficulty {
        case .easy: AppColor.success
        case .medium: AppColor.warning
        case .hard: AppColor.negative
        }
        self.init(text: difficulty.label, foreground: color, background: color.opacity(0.14))
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.l) {
            HStack(spacing: Spacing.m) {
                IconTile(symbol: AppSymbol.skincare)
                IconTile(symbol: AppSymbol.restorePurchases, size: 29, radius: Radius.iconTileSmall, symbolSize: 15)
                IconTile(
                    symbol: AppSymbol.locked,
                    size: 56,
                    radius: Radius.listCard,
                    symbolSize: 24,
                    border: AppColor.accentStart.opacity(0.3)
                )
            }
            HStack(spacing: Spacing.xxsPlus) {
                Chip(difficulty: .easy)
                Chip(difficulty: .medium)
                Chip(difficulty: .hard)
                Chip(text: "5 min / day")
            }
        }
    }
}
