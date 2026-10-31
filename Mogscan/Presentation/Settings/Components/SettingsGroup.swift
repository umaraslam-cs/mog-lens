import SwiftUI

/// One inset-grouped section of the Settings sheet.
struct SettingsGroup: View {
    let section: SettingsSection
    let onSelect: (SettingsEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(section.header)
                .font(AppFont.system(12.5, .semibold))
                .tracking(Tracking.settingsHeader)
                .foregroundStyle(AppColor.textSecondary)
                .padding(.leading, Spacing.xxsPlus)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(section.entries) { entry in
                    SettingsRow(entry: entry) { onSelect(entry) }

                    if entry.id != section.entries.last?.id {
                        HairlineDivider()
                    }
                }
            }
            .surfaceCard(
                radius: Radius.card,
                fill: AppColor.surfaceRaised,
                border: AppColor.hairlineQuiet
            )
            .roundedClip(Radius.card)
        }
    }
}

/// A single settings row: tinted icon tile, title, chevron.
struct SettingsRow: View {
    let entry: SettingsEntry
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.m) {
                IconTile(
                    symbol: entry.symbol,
                    size: 29,
                    radius: Radius.iconTileSmall,
                    symbolSize: 15,
                    tint: tint,
                    fillOpacity: 0.16
                )

                Text(entry.title)
                    .font(AppFont.callout)
                    .foregroundStyle(entry.tint == .destructive ? AppColor.negative : AppColor.textPrimary)

                Spacer(minLength: Spacing.xs)

                Image(systemName: AppSymbol.chevronRight)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(.horizontal, Spacing.ml)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(entry.title)
        .accessibilityAddTraits(.isButton)
    }

    private var tint: Color {
        switch entry.tint {
        case .accent: AppColor.accentStart
        case .neutral: AppColor.textSecondary
        case .warning: AppColor.warning
        case .destructive: AppColor.negative
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.group) {
            ForEach(DesignContent.Settings.sections) { section in
                SettingsGroup(section: section) { _ in }
            }
        }
        .padding(.horizontal, Spacing.l)
    }
}
