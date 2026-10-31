import SwiftUI

/// Shared chrome for every onboarding step: the progress indicator pinned to the
/// top, a bottom CTA 32pt above the home indicator, and a full-bleed content slot.
///
/// Content positions itself from the top of the safe area, matching the design's
/// absolute layout.
///
/// Those absolute offsets only ever fitted a phone — in an iPhone app windowed
/// on iPad the container is 647pt tall, and the last line of copy or the last
/// claim row disappeared behind the CTA (Guideline 4, the ground App Review
/// rejected this app on twice). Two things answer that: the slot scrolls, and
/// the content is handed the height the slot actually got, which it lays itself
/// out against — see ``DesignOffsetStack``. At the design's own height nothing
/// moves, so every supported iPhone is unchanged.
///
/// The height goes into the content closure rather than the environment: the
/// step views build that content, so they sit above this view and an
/// environment value set here would never reach them.
struct OnboardingScaffold<Content: View>: View {
    let step: OnboardingStep
    var ctaTitle: String = DesignContent.Onboarding.continueTitle
    let onContinue: () -> Void
    @ViewBuilder let content: (CGFloat) -> Content

    init(
        step: OnboardingStep,
        ctaTitle: String = DesignContent.Onboarding.continueTitle,
        onContinue: @escaping () -> Void,
        @ViewBuilder content: @escaping (CGFloat) -> Content
    ) {
        self.step = step
        self.ctaTitle = ctaTitle
        self.onContinue = onContinue
        self.content = content
    }

    init(
        step: OnboardingStep,
        ctaTitle: String = DesignContent.Onboarding.continueTitle,
        onContinue: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.step = step
        self.ctaTitle = ctaTitle
        self.onContinue = onContinue
        self.content = { _ in content() }
    }

    /// Height the content slot was actually given, which on a container shorter
    /// than a phone is less than the design assumed.
    @State private var slotHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            AppBackground()

            VStack(spacing: 0) {
                ScrollView {
                    // A hair under the slot: line spacing lets a descender
                    // paint a point or two below the height a text block
                    // reports, and the last line of copy is exactly where that
                    // shows.
                    content(max(0, slotHeight - Spacing.xs))
                        .frame(maxWidth: .infinity, alignment: .top)
                        .padding(.bottom, Spacing.xs)
                }
                // No rubber-band where the content already fits, which is every
                // phone.
                .scrollBounceBehavior(.basedOnSize)
                .measureHeight { slotHeight = $0 }

                // Outside the scroll: Continue stays put at any height.
                BottomCTA {
                    PrimaryButton(title: ctaTitle, action: onContinue)
                }
            }

            // Over the scroll, not in it: the step indicator is chrome.
            OnboardingProgressBar(currentStep: step.stepNumber)
                .padding(.horizontal, Layout.horizontal)
                .padding(.top, Layout.contentTopInset)
        }
    }
}

/// Title + supporting line, the block that opens most onboarding steps.
///
/// Fades in and rises 12pt, with a 0.05s stagger between the two lines.
struct OnboardingHeadline: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    let title: String
    var subtitle: String?
    var eyebrow: String?
    var titleSize: CGFloat = 34
    var titleLineHeight: CGFloat = 1.1
    var subtitleSize: CGFloat = 16
    var subtitleLineHeight: CGFloat = 1.4
    var spacing: CGFloat = Spacing.s

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if let eyebrow {
                EyebrowLabel(text: eyebrow)
                    .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)
            }

            Text(title)
                .font(AppFont.system(titleSize, .bold))
                .tracking(titleSize * -0.02)
                .lineHeight(titleLineHeight, size: titleSize)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .staggeredAppear(hasAppeared, index: eyebrow == nil ? 0 : 1, reduceMotion: reduceMotion)

            if let subtitle {
                Text(subtitle)
                    .font(AppFont.system(subtitleSize))
                    .lineHeight(subtitleLineHeight, size: subtitleSize)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .staggeredAppear(hasAppeared, index: eyebrow == nil ? 1 : 2, reduceMotion: reduceMotion)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { hasAppeared = true }
    }
}

extension View {
    /// Fades in and rises 12pt, staggered by 0.05s per line.
    func staggeredAppear(_ isVisible: Bool, index: Int, reduceMotion: Bool) -> some View {
        opacity(isVisible || reduceMotion ? 1 : 0)
            .offset(y: isVisible || reduceMotion ? 0 : AppMotion.textAppearOffset)
            .animation(
                reduceMotion ? nil : .easeOut(duration: 0.4).delay(Double(index) * AppMotion.textStagger),
                value: isVisible
            )
    }
}
