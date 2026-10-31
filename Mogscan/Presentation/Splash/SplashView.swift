import SwiftUI

/// 01 — Splash. Logo, wordmark and a dark animated background.
struct SplashView: View {
    @State private var viewModel = SplashViewModel()
    let onFinish: () -> Void

    var body: some View {
        ZStack {
            AppBackground()

            BreathingGlow(diameter: 520)
                .offset(y: -380)
                .frame(maxHeight: .infinity, alignment: .top)

            VStack(spacing: 26) {
                SplashLogoMark()

                VStack(spacing: Spacing.xs) {
                    Text(viewModel.wordmark)
                        .font(AppFont.splashWordmark)
                        .tracking(Tracking.wordmark)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(viewModel.subtitle.uppercased())
                        .font(AppFont.splashSubtitle)
                        .tracking(Tracking.wordmarkSubtitle)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }

            VStack {
                Spacer()
                Text(viewModel.footer)
                    .font(AppFont.caption)
                    .tracking(Tracking.caption)
                    .foregroundStyle(AppColor.textSecondary.opacity(0.65))
                    .padding(.bottom, Spacing.xl)
            }
        }
        .task {
            await viewModel.startHold()
            onFinish()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.wordmark). \(viewModel.subtitle).")
    }
}

#Preview("01 Splash") {
    SplashView {}
}
