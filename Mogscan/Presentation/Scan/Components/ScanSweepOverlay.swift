import SwiftUI

/// The sweep line that travels down the analysis frame on a 2.6s loop.
/// Reduce Motion swaps it for a static overlay.
struct ScanSweepOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSweeping = false

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(AppGradient.sweepLine)
                .frame(height: 2)
                .shadow(color: AppColor.accentStart.opacity(0.9), radius: 11)
                .opacity(reduceMotion ? 0.6 : 1)
                .offset(y: isSweeping ? geometry.size.height * 0.92 : geometry.size.height * 0.08)
                .onAppear {
                    guard !reduceMotion else {
                        isSweeping = false
                        return
                    }
                    withAnimation(
                        .easeInOut(duration: AppMotion.sweepDuration).repeatForever(autoreverses: true)
                    ) {
                        isSweeping = true
                    }
                }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// One line of the analysing checklist: completed, in progress or pending.
/// Rows swap spinner → checkmark on real completion, over 0.2s.
struct AnalysisStepRow: View {
    let step: AnalysisStep

    var body: some View {
        HStack(spacing: Spacing.s) {
            indicator
                .frame(width: 15, height: 15)

            Text(step.title)
                .font(AppFont.subheadline)
                .fontWeight(step.state == .inProgress ? .semibold : .regular)
                .foregroundStyle(textColor)

            Spacer(minLength: 0)
        }
        .animation(AppMotion.stepStateChange, value: step.state)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var indicator: some View {
        switch step.state {
        case .completed:
            Image(systemName: AppSymbol.checkmarkCircle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColor.success)
        case .inProgress:
            SpinnerRing(size: 15, lineWidth: 2)
        case .pending:
            Circle()
                .strokeBorder(AppColor.textSecondary.opacity(0.35), lineWidth: 1)
        }
    }

    private var textColor: Color {
        switch step.state {
        case .completed: AppColor.textSecondary.opacity(0.75)
        case .inProgress: AppColor.textPrimary
        case .pending: AppColor.textSecondary.opacity(0.45)
        }
    }

    private var accessibilityLabel: String {
        switch step.state {
        case .completed: "\(step.title) complete"
        case .inProgress: "\(step.title) in progress"
        case .pending: "\(step.title) pending"
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(alignment: .leading, spacing: Spacing.ml) {
            ForEach(DesignContent.Scan.analysisSteps) { AnalysisStepRow(step: $0) }
        }
        .padding(.horizontal, 36)
    }
}
