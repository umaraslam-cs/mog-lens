import SwiftUI
import StoreKit
import UIKit

/// Pre-paywall prompt encouraging users to rate MogScan on the App Store.
/// Handles both the native StoreKit `requestReview` prompt and direct App Store fallback,
/// with simulator-safe handling to prevent "invalid URL" errors during testing.
struct AppRatingPromptView: View {
    let onContinue: () -> Void

    @Environment(\.requestReview) private var requestReview
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedStars: Int = 5
    @State private var hasAppeared: Bool = false
    @State private var isSubmitted: Bool = false

    private let appStoreURL = URL(string: DesignContent.RatingPrompt.appStoreURLString)

    var body: some View {
        ZStack {
            AppBackground()

            // Ambient background glow
            RadialGlow(
                color: AppColor.accentStart,
                opacity: 0.22,
                diameter: 420,
                falloff: 0.75
            )
            .offset(y: -60)

            VStack(spacing: 0) {
                // Top Skip Bar
                HStack {
                    Spacer()
                    Button {
                        onContinue()
                    } label: {
                        Text("Skip")
                            .font(AppFont.system(14, .medium))
                            .foregroundStyle(Color.white.opacity(0.55))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white.opacity(0.06)))
                    }
                }
                .padding(.horizontal, Layout.horizontal)
                .padding(.top, 14)

                Spacer(minLength: 20)

                // Main Prompt Content Card
                VStack(spacing: Spacing.l) {
                    // 1. App Icon with glowing cyan rim
                    ZStack {
                        Image(AppImage.logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 92, height: 92)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .strokeBorder(AppColor.accentStart.opacity(0.7), lineWidth: 1.5)
                            )
                            .shadow(color: AppColor.accentStart.opacity(0.35), radius: 16, x: 0, y: 4)
                    }
                    .staggeredAppear(hasAppeared, index: 0, reduceMotion: reduceMotion)

                    // 2. Eyebrow Capsule
                    Text(DesignContent.RatingPrompt.eyebrow)
                        .font(AppFont.mono(10.5, .bold))
                        .tracking(1.4)
                        .foregroundStyle(AppColor.accentStart)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(AppColor.accentStart.opacity(0.12)))
                        .overlay(Capsule().strokeBorder(AppColor.accentStart.opacity(0.3), lineWidth: 1))
                        .staggeredAppear(hasAppeared, index: 1, reduceMotion: reduceMotion)

                    // 3. Headline & Description
                    VStack(spacing: Spacing.s) {
                        Text(DesignContent.RatingPrompt.title)
                            .font(AppFont.system(28, .heavy))
                            .tracking(-0.4)
                            .lineHeight(1.15, size: 28)
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 2)

                        Text(DesignContent.RatingPrompt.subtitle)
                            .font(AppFont.system(14.5, .regular))
                            .lineHeight(1.4, size: 14.5)
                            .foregroundStyle(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    .staggeredAppear(hasAppeared, index: 2, reduceMotion: reduceMotion)

                    // 4. Interactive 5 Stars
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                selectedStars = star
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            } label: {
                                Image(systemName: star <= selectedStars ? "star.fill" : "star")
                                    .font(.system(size: 34, weight: .semibold))
                                    .foregroundStyle(
                                        star <= selectedStars
                                            ? Color(hex: 0xFFD700)
                                            : Color.white.opacity(0.2)
                                    )
                                    .shadow(
                                        color: star <= selectedStars
                                            ? Color(hex: 0xFFD700).opacity(0.4)
                                            : Color.clear,
                                        radius: 6,
                                        x: 0,
                                        y: 2
                                    )
                                    .scaleEffect(star == selectedStars ? 1.08 : 1.0)
                                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selectedStars)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                    .staggeredAppear(hasAppeared, index: 3, reduceMotion: reduceMotion)

                    // 5. Social Proof Trust Badge
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColor.accentStart)

                        Text(DesignContent.RatingPrompt.trustBadge)
                            .font(AppFont.system(12.5, .semibold))
                            .foregroundStyle(Color.white.opacity(0.85))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.06)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.10), lineWidth: 1))
                    .staggeredAppear(hasAppeared, index: 4, reduceMotion: reduceMotion)
                }
                .padding(.horizontal, Layout.horizontal)

                Spacer(minLength: 24)

                // Bottom CTAs
                VStack(spacing: 12) {
                    if isSubmitted {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(AppColor.accentStart)

                            Text("Thank you for your rating! ⭐")
                                .font(AppFont.system(16, .bold))
                                .foregroundStyle(Color.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppColor.accentStart.opacity(0.18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(AppColor.accentStart.opacity(0.5), lineWidth: 1)
                                )
                        )
                    } else {
                        // Primary Rate CTA
                        PrimaryButton(
                            title: selectedStars >= 4 ? "SUBMIT \(selectedStars)-STAR RATING" : "SUBMIT FEEDBACK",
                            action: submitRating
                        )
                    }

                    // Secondary Continue to Results Button
                    Button {
                        onContinue()
                    } label: {
                        Text(DesignContent.RatingPrompt.continueCTA)
                            .font(AppFont.system(15, .semibold))
                            .foregroundStyle(Color.white.opacity(0.70))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Layout.horizontal)
                .padding(.bottom, Layout.bottomCTAInset)
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }

    /// Submits rating, triggers native StoreKit review prompt, and advances to the paywall.
    private func submitRating() {
        guard !isSubmitted else { return }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        withAnimation(.easeInOut(duration: 0.25)) {
            isSubmitted = true
        }

        // Trigger native StoreKit in-app prompt
        requestReview()

        #if !targetEnvironment(simulator)
        // On physical devices, also open App Store review page if 5 stars
        if selectedStars >= 5, let appStoreURL {
            UIApplication.shared.open(appStoreURL)
        }
        #endif

        // Advance to paywall after brief delay so user sees confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onContinue()
        }
    }
}

#Preview("Rating Prompt") {
    AppRatingPromptView(onContinue: {})
        .preferredColorScheme(.dark)
}
