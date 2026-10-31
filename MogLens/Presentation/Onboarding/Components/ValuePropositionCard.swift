import SwiftUI

/// Enhanced reason-why card on the "Why it matters" step.
/// Features generous spacing, larger bold typography, glowing telemetry icon chip,
/// and a refined specular glassmorphic surface.
struct ValuePropositionCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    let proposition: ValueProposition
    var index: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            // Icon + Eyebrow Header
            if let eyebrow = proposition.eyebrow {
                HStack(spacing: Spacing.s) {
                    // Glowing Icon Chip
                    ZStack {
                        Circle()
                            .fill(AppColor.accentStart.opacity(0.14))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Circle()
                                    .strokeBorder(AppColor.accentStart.opacity(0.35), lineWidth: 1)
                            }

                        Image(systemName: proposition.symbol)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColor.accentStart)
                    }

                    Text(eyebrow)
                        .font(AppFont.mono(12, .semibold))
                        .tracking(1.0)
                        .foregroundStyle(AppColor.accentStart)
                }
            }

            // Title
            Text(proposition.title)
                .font(AppFont.system(18, .bold))
                .lineHeight(1.25, size: 18)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            // Detail
            Text(proposition.detail)
                .font(AppFont.system(15))
                .lineHeight(1.45, size: 15)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background {
            // Refined dark glassmorphic surface with subtle specular gradient
            RoundedRectangle(cornerRadius: Radius.listCard, style: .continuous)
                .fill(AppColor.panel.opacity(0.80))
                .background(
                    RoundedRectangle(cornerRadius: Radius.listCard, style: .continuous)
                        .fill(AppColor.surface)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.listCard, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.16), location: 0),
                                    .init(color: AppColor.accentStart.opacity(0.24), location: 0.2),
                                    .init(color: Color.white.opacity(0.04), location: 1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .opacity(hasAppeared || reduceMotion ? 1 : 0)
        .offset(y: hasAppeared || reduceMotion ? 0 : AppMotion.cardAppearOffset)
        .onAppear {
            withAnimation(
                reduceMotion ? nil : AppMotion.cardAppear.delay(Double(index) * AppMotion.cardStagger)
            ) {
                hasAppeared = true
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ZStack {
        AppBackground()
        ScrollView {
            VStack(spacing: Spacing.m) {
                ForEach(Array(DesignContent.Onboarding.valuePropositions.enumerated()), id: \.element.id) { index, item in
                    ValuePropositionCard(proposition: item, index: index)
                }
            }
            .padding(Layout.horizontal)
        }
    }
}
