import SwiftUI

/// Tells the user their photo could not be scored.
///
/// Drawn by the app rather than presented as a `.alert`, and that is the whole
/// point. A system alert is a UIKit presentation, so it only appears if nothing
/// else is presenting or dismissing at that moment — and this message is raised
/// at exactly the wrong moment every time: the photo picker is still sliding
/// away, or the analysing screen is being popped. Twice it was fixed by
/// resequencing, and twice a different route into the failure found a new race.
/// It was traced on device with the binding going true and no alert appearing.
///
/// As an ordinary view in the scan screen's stack there is nothing to race. It
/// renders whenever there is a failure to show, from any depth, under any
/// transition.
struct AnalysisFailureOverlay: View {
    let error: FaceAnalysisError
    let onDismiss: () -> Void

    var body: some View {
        let copy = DesignContent.Scan.analysisFailure(error)

        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 0) {
                VStack(spacing: Spacing.xxsPlus) {
                    Text(copy.title)
                        .font(AppFont.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(copy.body)
                        .font(AppFont.footnote)
                        .lineHeight(1.35, size: 13)
                        .foregroundStyle(.white.opacity(0.82))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.screen)
                .padding(.bottom, Spacing.l)

                Rectangle()
                    .fill(.white.opacity(0.22))
                    .frame(height: 0.5)

                Button(action: onDismiss) {
                    Text(DesignContent.Scan.analysisFailureDismiss)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColor.systemBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.m)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .background(
                AppColor.systemAlertSurface,
                in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
            )
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
            )
            .shadow(color: .black.opacity(0.6), radius: 30, y: 24)
            .padding(.horizontal, 52)
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}

#Preview("Analysis failure") {
    ZStack {
        AppBackground()
        AnalysisFailureOverlay(error: .noFaceDetected, onDismiss: {})
    }
    .preferredColorScheme(.dark)
}
