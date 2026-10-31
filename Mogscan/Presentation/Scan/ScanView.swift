import PhotosUI
import SwiftUI

/// 11 — Scan entry. Take Photo opens the camera; Import Photo opens
/// `PhotosPicker`, which needs no library permission prompt. Either one opens
/// the scan flow over the tab shell — see ``flow(_:)``.
struct ScanView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(AppRouter.self) private var router
    @State private var viewModel: ScanViewModel? = nil
    /// Lives in the view because `PhotosPicker` writes straight to a binding.
    @State private var pickedItem: PhotosPickerItem?
    /// Height the guidance slot was actually given. Shorter than the design
    /// assumes inside the tab shell on iPad — see ``EnvironmentValues/designFit``.
    @State private var slotHeight: CGFloat = 0

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
                viewModel = ScanViewModel(dependencies: dependencies)
            }
        }
    }

    private func content(_ viewModel: ScanViewModel) -> some View {
        @Bindable var viewModel = viewModel
        let guideFit = Layout.designFit(
            slot: slotHeight - Spacing.l,
            design: Layout.DesignSlot.scanEntry
        )
        return ZStack {
                ZStack(alignment: .top) {
                    AppBackground()

                    VStack(spacing: 0) {
                        // The capture guidance sits at a fixed 446pt in the
                        // design, which runs under the buttons on a container
                        // shorter than a phone — an iPhone app windowed on iPad
                        // is 647pt tall, and the tab bar takes 49 of them. The
                        // offsets compress to fit and the slot scrolls anyway,
                        // so nothing is cropped or unreachable at any height.
                        ScrollView {
                            DesignOffsetStack(
                                offsets: [Spacing.s, 136, 446],
                                // Less the padding below the stack, which the
                                // stack cannot see but the slot still holds.
                                available: slotHeight - Spacing.l,
                                // Wider than the default: the face guide's glow
                                // paints 16pt outside the frame it reports, so a
                                // 12pt gap lets the first guideline row sit on
                                // top of it.
                                minimumGap: Spacing.screen
                            ) {
                                VStack(alignment: .leading, spacing: Spacing.xxsPlus) {
                                    Text(viewModel.title)
                                        .font(AppFont.screenTitle)
                                        .tracking(Tracking.screenTitle)
                                        .lineHeight(1.1, size: 32)
                                        .foregroundStyle(AppColor.textPrimary)
                                    Text(viewModel.subtitle)
                                        .font(AppFont.subheadline)
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, Layout.horizontal)

                                // The guide is the one block a closed gap
                                // cannot make room for, so it takes the slot's
                                // shortfall directly.
                                FaceGuideView(width: 210 * guideFit, height: 270 * guideFit)
                                    .frame(maxWidth: .infinity)

                                VStack(spacing: Spacing.m) {
                                    ForEach(viewModel.guidelines) { CaptureGuidelineRow(guideline: $0) }
                                }
                                .padding(.horizontal, Layout.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, Spacing.l)
                        }
                        .scrollBounceBehavior(.basedOnSize)
                        .measureHeight { slotHeight = $0 }

                        BottomCTA {
                            PrimaryButton(
                                title: DesignContent.Scan.takePhoto,
                                symbol: AppSymbol.takePhoto,
                                symbolSize: 18
                            ) {
                                Task { await viewModel.takePhoto() }
                            }

                            SecondaryButton(
                                title: DesignContent.Scan.importPhoto,
                                symbol: AppSymbol.importPhoto
                            ) {
                                viewModel.importPhoto()
                            }
                        }
                    }
                }
                .photosPicker(
                    isPresented: $viewModel.isShowingPhotoPicker,
                    selection: $pickedItem,
                    matching: .images,
                    photoLibrary: .shared()
                )
                .task(id: pickedItem) {
                    guard pickedItem != nil else { return }
                    await viewModel.photoPicked(pickedItem)
                    // Consumed. Without this the item outlives the scan, and since
                    // `task` restarts whenever this root reappears, returning here
                    // from analysing pushes the very same photo straight back in.
                    pickedItem = nil
                }
                .alert(
                    DesignContent.Scan.cameraDeniedTitle,
                    isPresented: $viewModel.isShowingCameraDeniedAlert
                ) {
                    Button(DesignContent.Scan.cameraDeniedSettings) { openCameraSettings() }
                    Button(DesignContent.Scan.cameraDeniedCancel, role: .cancel) {}
                } message: {
                    Text(DesignContent.Scan.cameraDeniedBody)
                }

                if let failure = viewModel.analysisFailure, !viewModel.isFlowActive {
                    AnalysisFailureOverlay(error: failure) {
                        viewModel.analysisFailureAcknowledged()
                    }
                    .transition(.opacity)
                }
        }
        .animation(AppMotion.stepTransition, value: viewModel.analysisFailure)
        .fullScreenCover(
            isPresented: Binding(
                get: { viewModel.isFlowActive },
                set: { if !$0 { viewModel.dismissFlow() } }
            ),
            onDismiss: {
                // Landing on a tab waits until the flow is off screen —
                // swapping the shell underneath a dismissing cover strands it.
                if let tab = viewModel.flowDidDismiss() {
                    router.scanFlowDidFinish(landingOn: tab)
                }
            }
        ) {
            flow(viewModel)
        }
    }

    /// The scan flow itself: capture → analysing → paywall → results, shown over
    /// the tab shell. Nothing in here renders the tab bar, so nothing has to
    /// hide it — and Results reads as the standalone screen it is.
    ///
    /// Renders the top of ``ScanViewModel/path`` directly rather than through a
    /// `NavigationStack`. The flow is linear and each screen carries its own way
    /// out, so a stack adds only a back-swipe: one that lands on analysing and
    /// re-runs it, or — once the path is collapsed at the result — on nothing at
    /// all. The path stays the single source of truth either way.
    private func flow(_ viewModel: ScanViewModel) -> some View {
        ZStack {
            AppBackground()

            if let screen = viewModel.screens.last {
                screenView(screen, viewModel: viewModel)
                    .id(screen)
                    .transition(.opacity)
            }

            if let failure = viewModel.analysisFailure {
                // Above the flow, so it covers the analysing screen at any depth.
                AnalysisFailureOverlay(error: failure) {
                    viewModel.analysisFailureAcknowledged()
                }
                .transition(.opacity)
            }
        }
        .animation(AppMotion.stepTransition, value: viewModel.screens)
        .animation(AppMotion.stepTransition, value: viewModel.analysisFailure)
    }

    /// iOS only prompts for camera access once, so a refusal is only reversible
    /// in Settings.
    private func openCameraSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    @ViewBuilder
    private func screenView(
        _ screen: ScanViewModel.Screen,
        viewModel: ScanViewModel
    ) -> some View {
        switch screen {
        case .capture:
            CaptureView(
                onCapture: { await viewModel.captureDidFinish(photo: $0) },
                onCancel: viewModel.dismissFlow
            )
        case .analysing:
            AnalysingView(
                photo: viewModel.sourcePhoto,
                dependencies: dependencies,
                onFinish: { viewModel.analysisDidFinish(scan: $0) },
                onFailure: { viewModel.analysisDidFail($0) }
            )
        case .ratingPrompt:
            AppRatingPromptView(
                onContinue: viewModel.ratingPromptDidFinish
            )
        case .paywall:
            PaywallView(
                onUnlock: viewModel.purchaseDidComplete,
                onClose: viewModel.dismissFlow
            )
        case .results:
            if let scan = viewModel.resultScan {
                // End of the flow. The tab to land on is held until the flow
                // has finished dismissing — see the cover's `onDismiss`.
                ResultsView(scan: scan, photo: viewModel.sourcePhoto) { tab in
                    viewModel.finish(landingOn: tab)
                }
            }
        }
    }
}

#Preview("11 Scan") {
    ScanView()
        .environment(PreviewData.dependencies)
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
