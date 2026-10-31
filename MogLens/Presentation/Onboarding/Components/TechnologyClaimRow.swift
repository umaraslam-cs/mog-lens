import SwiftUI

/// One claim card on the Technology step: icon badge, number tag, title, and descriptive detail.
struct TechnologyClaimRow: View {
    let claim: TechnologyClaim

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.m) {
            // Left circular icon badge
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 44, height: 44)
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.10), lineWidth: 1))

                Image(systemName: claim.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColor.accentStart)
            }
            .padding(.top, 2)

            // Right text stack
            VStack(alignment: .leading, spacing: 3) {
                if let number = claim.number {
                    Text(number)
                        .font(AppFont.mono(11, .bold))
                        .foregroundStyle(AppColor.accentStart.opacity(0.85))
                }

                Text(claim.title)
                    .font(AppFont.system(15, .bold))
                    .foregroundStyle(Color.white)

                Text(claim.detail)
                    .font(AppFont.system(13, .regular))
                    .lineHeight(1.35, size: 13)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColor.panel.opacity(0.85))
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColor.surface)
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.m) {
            ForEach(DesignContent.Onboarding.technologyClaims) { claim in
                TechnologyClaimRow(claim: claim)
            }
        }
        .padding(.horizontal, Layout.horizontal)
    }
}
