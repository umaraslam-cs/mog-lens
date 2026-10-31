import SwiftUI

/// 08 / 09 — Home. The dashboard after onboarding, or an elegant empty state
/// when no scan exists yet.
struct HomeView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(AppRouter.self) private var router
    @State private var viewModel: HomeViewModel? = nil
    /// Raised by the locked card. Full-screen rather than a sheet so the paywall
    /// keeps the presentation it has everywhere else in the app.
    @State private var isShowingPaywall = false
    /// The scan whose results are open. Presented over the tab shell rather than
    /// pushed inside it: Results is a standalone screen wherever it opens from,
    /// and pushing it meant the tab bar animating away and back on every visit.
    @State private var presentedScan: FaceScan?
    /// Height the empty state's slot was given. The copy runs under the CTA on
    /// a 4.7-inch phone without it — see ``DesignOffsetStack``.
    @State private var emptySlotHeight: CGFloat = 0

    var body: some View {
        @Bindable var router = router

        return ZStack {
            AppBackground()

            if let viewModel {
                if viewModel.isEmpty {
                    emptyState(viewModel)
                } else {
                    dashboard(viewModel)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $presentedScan) { scan in
            ResultsView(scan: scan, photo: viewModel?.photo(for: scan))
        }
        .sheet(isPresented: $router.isShowingSettings) {
            // A restore inside Settings can raise the entitlement, and closing
            // a sheet does not re-run `onAppear` on what is behind it — without
            // this, Home would still show the locked card after a restore that
            // worked.
            Task { await viewModel?.refreshEntitlement() }
            viewModel?.load()
        } content: {
            SettingsView()
        }
        .fullScreenCover(isPresented: $isShowingPaywall) {
            PaywallView(
                onUnlock: {
                    isShowingPaywall = false
                    viewModel?.load()
                },
                onClose: { isShowingPaywall = false }
            )
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HomeViewModel(dependencies: dependencies)
            }
            viewModel?.load()
        }
        .task {
            await viewModel?.refreshEntitlement()
        }
    }

    // MARK: - Populated

    private func dashboard(_ viewModel: HomeViewModel) -> some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                HomeHeader(greeting: viewModel.greeting) { router.showSettings() }

                if viewModel.isLocked {
                    LockedResultsCard(detail: viewModel.lockedScansCaption) {
                        isShowingPaywall = true
                    }
                } else if let scan = viewModel.latestScan {
                    Button {
                        presentedScan = scan
                    } label: {
                        ScoreSummaryCard(scan: scan, lastScanCaption: viewModel.lastScanCaption)
                    }
                    .buttonStyle(PressableStyle())
                }

                PrimaryButton(
                    title: DesignContent.Home.scanAgain,
                    symbol: AppSymbol.takePhoto
                ) {
                    router.select(.scan)
                }

                // Everything below is result values, so it waits on the
                // entitlement — the locked card is the whole dashboard until
                // then.
                if !viewModel.isLocked, let scan = viewModel.latestScan {
                    MetricsPreviewSection(metrics: scan.previewMetrics)

                    historySection(viewModel)
                }
            }
            .padding(.horizontal, Layout.horizontal)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.section)
        }
        .scrollIndicators(.hidden)
    }

    private func historySection(_ viewModel: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: DesignContent.Home.historySection)

            ForEach(viewModel.history) { scan in
                Button {
                    presentedScan = scan
                } label: {
                    ScanHistoryRow(scan: scan, image: viewModel.thumbnails[scan.id])
                }
                .buttonStyle(PressableStyle())
                // The rows live in a VStack, not a List, so there is no swipe
                // action to hang this off. Settings carries the discoverable
                // delete-all; this is the per-scan one.
                .contextMenu {
                    Button(role: .destructive) {
                        withAnimation(AppMotion.stepTransition) { viewModel.delete(scan) }
                    } label: {
                        Label(DesignContent.Home.deleteScan, systemImage: AppSymbol.delete)
                    }
                }
            }
        }
    }

    // MARK: - Empty

    private func emptyState(_ viewModel: HomeViewModel) -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // Laid out for the same reason as every other absolutely
                // positioned screen: at 196pt plus its copy the empty state ran
                // under the CTA in a 647pt container. The offset closes up to
                // fit; the scroll stays as the fallback at the largest text
                // sizes.
                ScrollView {
                    DesignOffsetStack(offsets: [196], available: emptySlotHeight) {
                        HomeEmptyState()
                    }
                    .padding(.bottom, Spacing.l)
                }
                .scrollBounceBehavior(.basedOnSize)
                .measureHeight { emptySlotHeight = $0 }

                BottomCTA(spacing: Spacing.s) {
                    PrimaryButton(
                        title: DesignContent.Home.emptyCTA,
                        symbol: AppSymbol.takePhoto
                    ) {
                        router.select(.scan)
                    }
                    CTACaption(text: DesignContent.Home.emptyCaption)
                }
            }

            // After the scroll, not before it: a ScrollView takes touches across
            // its whole frame, so a header layered underneath one is visible but
            // untappable — which is exactly what happened to the settings gear.
            // The empty state starts at 196pt, so nothing overlaps visually.
            HomeHeader(greeting: viewModel.greeting) { router.showSettings() }
                .padding(.horizontal, Layout.horizontal)
                .padding(.top, Spacing.s)
        }
    }
}

#Preview("08 Home — dashboard") {
    NavigationStack {
        HomeView()
    }
    .environment(PreviewData.dependencies)
    .environment(AppRouter())
    .preferredColorScheme(.dark)
}

#Preview("08 Home — locked") {
    NavigationStack {
        HomeView()
    }
    .environment(AppDependencies(subscriptionRepository: StaticSubscriptionRepository(subscribed: false)))
    .environment(AppRouter())
    .preferredColorScheme(.dark)
}

#Preview("09 Home — empty state") {
    NavigationStack {
        HomeView()
    }
    .environment(PreviewData.emptyDependencies)
    .environment(AppRouter())
    .preferredColorScheme(.dark)
}
