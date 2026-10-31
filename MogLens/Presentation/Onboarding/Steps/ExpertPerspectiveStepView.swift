import SwiftUI

/// Onboarding — Expert Perspective Step.
/// Displays multiple clinical expert cards with quotes on facial harmony and structural symmetry.
struct ExpertPerspectiveStepView: View {
    var onBack: (() -> Void)? = nil
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    private let experts = DesignContent.Onboarding.expertCards

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                topNavBar
                    .padding(.horizontal, Layout.horizontal)
                    .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {
                        headlineBlock
                            .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                        // Expert cards
                        VStack(spacing: Spacing.m) {
                            ForEach(Array(experts.enumerated()), id: \.element.id) { index, expert in
                                expertCard(expert, index: index)
                                    .staggeredAppear(hasAppeared, index: index + 1, reduceMotion: reduceMotion)
                            }
                        }
                        .padding(.horizontal, Layout.horizontal)

                        Spacer(minLength: 20)
                    }
                    .padding(.top, Spacing.l)
                    .padding(.bottom, Layout.bottomCTAInset + 80)
                }
            }

            VStack(spacing: 0) {
                Spacer()
                BottomCTA {
                    PrimaryButton(
                        title: DesignContent.Onboarding.expertPerspectiveCTA,
                        action: onContinue
                    )
                }
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }

    // MARK: - Top Navigation Bar

    private var topNavBar: some View {
        HStack(alignment: .center) {
            Spacer()

            Text(DesignContent.Onboarding.expertPerspectiveEyebrow)
                .font(AppFont.system(13, .bold))
                .tracking(1.8)
                .foregroundStyle(Color.white.opacity(0.72))

            Spacer()
        }
    }

    // MARK: - Headline Block

    private var headlineBlock: some View {
        VStack(spacing: Spacing.s) {
            VStack(spacing: 2) {
                Text("FACIAL HARMONY IS")
                    .font(AppFont.system(26, .bold))
                    .foregroundStyle(Color.white)

                Text("ABOUT HOW YOUR")
                    .font(AppFont.system(26, .bold))
                    .foregroundStyle(Color.white)

                HStack(spacing: 0) {
                    Text("FEATURES ")
                        .font(AppFont.system(26, .bold))
                        .foregroundStyle(Color.white)

                    Text("WORK")
                        .font(AppFont.system(26, .bold))
                        .foregroundStyle(AppColor.accentStart)
                }

                Text("TOGETHER.")
                    .font(AppFont.system(26, .bold))
                    .foregroundStyle(AppColor.accentStart)
            }
            .tracking(-0.5)
            .multilineTextAlignment(.center)
            .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 2)

            Text(DesignContent.Onboarding.expertPerspectiveSubtitle)
                .font(AppFont.system(15, .regular))
                .lineHeight(1.35, size: 15)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.textSecondary)
                .padding(.horizontal, Layout.horizontal)
                .padding(.top, Spacing.xs)
        }
        .padding(.horizontal, Layout.horizontal)
    }

    // MARK: - Expert Card

    @ViewBuilder
    private func expertCard(_ expert: ExpertCard, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Avatar + Info + Watermark quote mark
            ZStack(alignment: .topTrailing) {
                Text("\u{201C}")
                    .font(.system(size: 84, weight: .black, design: .serif))
                    .foregroundStyle(Color.white.opacity(0.045))
                    .offset(x: 4, y: -24)

                HStack(alignment: .center, spacing: 14) {
                    // Avatar — photo portrait when available, styled initials fallback
                    if let imageName = expert.imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 58, height: 58)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(AppColor.accentStart, lineWidth: 2)
                            )
                            .shadow(color: AppColor.accentStart.opacity(0.25), radius: 8, x: 0, y: 2)
                    } else {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [AppColor.avatarTop, AppColor.avatarBottom],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 58, height: 58)

                            // Initials
                            Text(initials(for: expert.name))
                                .font(AppFont.system(20, .bold))
                                .foregroundStyle(AppColor.accentStart)
                        }
                        .overlay(
                            Circle()
                                .strokeBorder(AppColor.accentStart, lineWidth: 2)
                        )
                        .shadow(color: AppColor.accentStart.opacity(0.2), radius: 8, x: 0, y: 2)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 5) {
                            Text(expert.name)
                                .font(AppFont.system(16, .bold))
                                .foregroundStyle(Color.white)

                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppColor.accentStart)
                        }

                        Text(expert.role)
                            .font(AppFont.system(13, .semibold))
                            .foregroundStyle(AppColor.accentStart)

                        Text(expert.credentials)
                            .font(AppFont.mono(10.5, .medium))
                            .tracking(0.6)
                            .foregroundStyle(Color.white.opacity(0.5))
                    }

                    Spacer(minLength: 0)
                }
            }

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.09))
                .frame(height: 1)
                .padding(.vertical, 16)

            // Quote
            Text(expert.quote)
                .font(AppFont.system(14.5, .regular))
                .italic()
                .lineSpacing(4)
                .foregroundStyle(Color.white.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColor.panelDeep.opacity(0.92))
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppColor.surfaceStrong)
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.09), lineWidth: 1)
        }
    }

    // MARK: - Helpers

    private func initials(for name: String) -> String {
        let parts = name
            .components(separatedBy: " ")
            .filter { !$0.hasPrefix("Dr") && !$0.hasSuffix(".") && !$0.isEmpty }
        return parts.prefix(2).compactMap { $0.first.map(String.init) }.joined()
    }
}

#Preview("Expert Perspective") {
    ExpertPerspectiveStepView(onBack: {}, onContinue: {})
        .preferredColorScheme(.dark)
}
