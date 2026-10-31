import SwiftUI

/// A selectable subscription plan. The chosen plan carries the accent wash, a
/// 1.5pt accent border and a filled radio; the badge floats above its top edge.
struct PaywallPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.ml) {
                radio

                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.title)
                        .font(AppFont.system(16.5, .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                    Text(plan.priceCaption)
                        .font(AppFont.footnote)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: 0)
            }
            .padding(Spacing.l)
            .modifier(PlanCardBackground(isSelected: isSelected))
            .overlay(alignment: .topTrailing) {
                if let badge = plan.badge {
                    Text(badge)
                        .font(AppFont.system(10.5, .bold))
                        .tracking(Tracking.badge)
                        .foregroundStyle(AppColor.onAccent)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(AppGradient.accent, in: Capsule())
                        .offset(x: -Spacing.ml, y: -9)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    @ViewBuilder
    private var radio: some View {
        if isSelected {
            ZStack {
                Circle().fill(AppGradient.accent)
                Image(systemName: AppSymbol.checkmark)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColor.onAccent)
            }
            .frame(width: 22, height: 22)
        } else {
            Circle()
                .strokeBorder(AppColor.textSecondary.opacity(0.5), lineWidth: 1.5)
                .frame(width: 22, height: 22)
        }
    }
}

private struct PlanCardBackground: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        if isSelected {
            content.gradientCard(
                AppGradient.selectedPlan,
                radius: Radius.listCard,
                border: AppColor.accentStart,
                borderWidth: 1.5
            )
        } else {
            content.surfaceCard(
                radius: Radius.listCard,
                fill: AppColor.surface,
                border: Color.white.opacity(0.1)
            )
        }
    }
}

/// One unlocked capability, ticked in green (compact legacy row).
struct BenefitRow: View {
    let benefit: PaywallBenefit

    var body: some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: AppSymbol.checkmarkCircle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.success)

            Text(benefit.text)
                .font(AppFont.system(15.5))
                .foregroundStyle(AppColor.textPrimary)

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

/// An expandable accordion card presenting a paywall benefit with interactive details and highlights.
struct AccordionBenefitCard: View {
    let benefit: PaywallBenefit
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 0) {
                // Header row: Icon + Title & Subtitle + Chevron
                HStack(spacing: Spacing.m) {
                    // Feature Icon inside accent badge
                    ZStack {
                        Circle()
                            .fill(AppColor.accentStart.opacity(isExpanded ? 0.20 : 0.12))
                            .frame(width: 36, height: 36)
                            .overlay {
                                Circle()
                                    .strokeBorder(
                                        AppColor.accentStart.opacity(isExpanded ? 0.45 : 0.22),
                                        lineWidth: 1
                                    )
                            }

                        Image(systemName: benefit.symbol)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColor.accentStart)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(benefit.title)
                            .font(AppFont.system(15, .semibold))
                            .foregroundStyle(AppColor.textPrimary)

                        if !benefit.subtitle.isEmpty {
                            Text(benefit.subtitle)
                                .font(AppFont.system(12))
                                .foregroundStyle(AppColor.textSecondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 8)

                    // Rotating Chevron
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(isExpanded ? AppColor.accentStart : AppColor.textSecondary.opacity(0.6))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)

                // Expanded content
                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Divider()
                            .overlay(Color.white.opacity(0.08))
                            .padding(.bottom, 2)

                        if !benefit.detail.isEmpty {
                            Text(benefit.detail)
                                .font(AppFont.system(13))
                                .lineHeight(1.38, size: 13)
                                .foregroundStyle(AppColor.textSecondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }

                        if !benefit.highlights.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(benefit.highlights, id: \.self) { highlight in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: AppSymbol.checkmark)
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(AppColor.accentStart)
                                            .padding(.top, 3)

                                        Text(highlight)
                                            .font(AppFont.system(12.5, .medium))
                                            .foregroundStyle(Color.white.opacity(0.90))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 15)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColor.panel.opacity(isExpanded ? 0.90 : 0.75))
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppColor.surface)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(isExpanded ? 0.20 : 0.10), location: 0),
                                .init(color: AppColor.accentStart.opacity(isExpanded ? 0.35 : 0.12), location: 0.3),
                                .init(color: Color.white.opacity(0.03), location: 1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isExpanded ? 1.25 : 1
                    )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        AppBackground()
        // Benefit rows only: a plan card needs a priced `SubscriptionPlan`, and
        // the only source of prices is the RevenueCat store product — nothing
        // in this app fabricates one, previews included.
        VStack(spacing: Spacing.s) {
            ForEach(PreviewData.benefits) { BenefitRow(benefit: $0) }
        }
        .padding(.horizontal, Spacing.section)
    }
}
