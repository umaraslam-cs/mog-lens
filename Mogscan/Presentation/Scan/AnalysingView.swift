import SwiftUI

/// 14 — Analysing. The sweep runs on a 2.6s loop with landmark dots fading in
/// behind it. The tab bar is hidden for the duration.
struct AnalysingView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: AnalysingViewModel?
    /// Height this screen was actually given — see ``EnvironmentValues/designFit``.
    @State private var slotHeight: CGFloat = 0
    /// The photo being analysed, captured or imported.
    var photo: UIImage?
    /// Handed the scored scan once the checklist and the analysis have both run.
    let onFinish: (FaceScan) -> Void
    /// Nothing measurable in the photo. Handed up rather than shown here: the
    /// alert has to be presented by the screen that owns the photo picker, or
    /// UIKit drops it while that sheet is still dismissing.
    var onFailure: (FaceAnalysisError) -> Void = { _ in }

    init(
        photo: UIImage? = nil,
        dependencies: AppDependencies? = nil,
        onFinish: @escaping (FaceScan) -> Void,
        onFailure: @escaping (FaceAnalysisError) -> Void = { _ in }
    ) {
        self.photo = photo
        if let dependencies {
            self._viewModel = State(initialValue: AnalysingViewModel(dependencies: dependencies))
        }
        self.onFinish = onFinish
        self.onFailure = onFailure
    }

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                AppBackground()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = AnalysingViewModel(dependencies: dependencies)
            }
        }
    }

    private func content(_ viewModel: AnalysingViewModel) -> some View {
        // The photo is the one block a closed gap cannot make room for, so it
        // takes the slot's shortfall directly.
        let fit = Layout.designFit(slot: slotHeight, design: Layout.DesignSlot.analysing)

        return ZStack(alignment: .top) {
            AppBackground()

            // The step checklist starts at 546pt, past the bottom of a 647pt
            // container — an iPhone app windowed on iPad — so its last rows
            // were cut off mid-scan. The offsets compress to fit that container
            // and the screen scrolls as well, which is belt and braces at the
            // largest accessibility text sizes.
            ScrollView {
                DesignOffsetStack(
                    offsets: [32, 464, 546],
                    // Less the padding below the stack, which the stack itself
                    // cannot see but the slot still has to hold.
                    available: slotHeight - Spacing.section
                ) {
                    analysisFrame(viewModel, fit: fit)
                        .padding(.horizontal, 36)

                    progressSection(viewModel)
                        .padding(.horizontal, 36)

                    VStack(alignment: .leading, spacing: Spacing.ml) {
                        ForEach(viewModel.steps) { AnalysisStepRow(step: $0) }
                    }
                    .padding(.horizontal, 36)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, Spacing.section)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .measureHeight { slotHeight = $0 }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: viewModel.scan) { _, scan in
            if let scan { onFinish(scan) }
        }
        .onChange(of: viewModel.failure) { _, failure in
            guard let failure else { return }
            // Defer the state mutation out of the onChange handler to avoid
            // "multiple updates per frame" — setting failure = nil inside the
            // change handler for `failure` triggers a second synchronous update.
            Task { @MainActor in
                viewModel.failureAcknowledged()
            }
            onFailure(failure)
        }
        .task {
            await viewModel.run(photo: photo)
        }
    }

    private func analysisFrame(_ viewModel: AnalysingViewModel, fit: CGFloat) -> some View {
        PhotoSlot(placeholder: DesignContent.Scan.analysingPhoto, image: photo)
            .frame(height: 400 * fit)
            .overlay {
                BiometricAnalysisScannerView(
                    landmarks: viewModel.landmarks,
                    imageSize: photo?.size,
                    progress: viewModel.progress
                )
            }
            .roundedClip(Radius.analysisFrame)
            .overlay {
                RoundedRectangle(cornerRadius: Radius.analysisFrame, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            stops: [
                                .init(color: AppColor.accentStart.opacity(0.60), location: 0.0),
                                .init(color: Color.white.opacity(0.12), location: 0.40),
                                .init(color: AppColor.accentStart.opacity(0.30), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            }
            .shadow(color: AppColor.accentStart.opacity(0.20), radius: 25)
    }

    private func progressSection(_ viewModel: AnalysingViewModel) -> some View {
        VStack(spacing: Spacing.ml) {
            HStack(alignment: .firstTextBaseline) {
                Text(DesignContent.Scan.analysingTitle)
                    .font(AppFont.sectionTitle)
                    .tracking(Tracking.sectionTitle)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer(minLength: Spacing.xs)

                Text(viewModel.progressLabel)
                    .font(AppFont.mono(16))
                    .foregroundStyle(AppColor.accentStart)
            }

            ProgressBarView(
                progress: viewModel.progress,
                height: 5,
                fill: AnyShapeStyle(AppGradient.accentHorizontal),
                glow: true
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(DesignContent.Scan.analysingTitle), \(viewModel.progressLabel)")
    }
}

#Preview("14 Analysing") {
    AnalysingView { _ in }
        .environment(PreviewData.dependencies)
        .preferredColorScheme(.dark)
}
