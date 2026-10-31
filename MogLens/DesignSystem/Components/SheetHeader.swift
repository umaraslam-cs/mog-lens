import SwiftUI

/// Fixed 56pt header for a presented sheet: centred title, trailing dismiss
/// button, hairline below and a lighter edge on top so the sheet reads as
/// lifted off the screen behind it.
struct SheetHeader: View {
    let title: String
    let trailingTitle: String
    let onTrailingTap: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            HStack {
                Spacer()
                Button(trailingTitle, action: onTrailingTap)
                    .font(AppFont.system(17))
                    .foregroundStyle(AppColor.accentStart)
                    .padding(.trailing, Spacing.xl)
            }
        }
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .bottom) { HairlineDivider() }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
        }
    }
}

#Preview {
    ZStack(alignment: .top) {
        AppBackground()
        SheetHeader(title: "Settings", trailingTitle: "Done") {}
    }
}
