import SwiftUI

/// Section header: 20pt semibold title with an optional accent action on the right.
struct SectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppFont.sectionTitle)
                .tracking(Tracking.sectionTitle)
                .foregroundStyle(AppColor.textPrimary)

            if let actionTitle, let action {
                Spacer(minLength: Spacing.xs)
                Button(actionTitle, action: action)
                    .font(AppFont.system(14))
                    .foregroundStyle(AppColor.accentStart)
            }
        }
        .accessibilityAddTraits(.isHeader)
    }
}

/// Uppercased eyebrow, e.g. "THE HALO EFFECT" or "CURRENT TIER".
struct EyebrowLabel: View {
    let text: String
    var color: Color = AppColor.accentStart
    var size: CGFloat = 12
    var tracking: CGFloat = Tracking.eyebrow

    var body: some View {
        Text(text)
            .font(AppFont.system(size, .semibold))
            .tracking(tracking)
            .foregroundStyle(color)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(alignment: .leading, spacing: Spacing.l) {
            SectionHeader(title: "Your metrics", actionTitle: "View") {}
            SectionHeader(title: "History")
            EyebrowLabel(text: "THE HALO EFFECT")
        }
        .padding(Layout.horizontal)
    }
}
