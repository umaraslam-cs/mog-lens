import SwiftUI

/// 16 — Results, unlocked. Photo with landmark overlay, overall score and tier,
/// then the five geometric metrics with percentiles.
struct ResultsView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ResultsViewModel? = nil

    /// The scan being reported on.
    ///
    /// Held on the view as well as in the view model because everything the
    /// header draws is known before the environment is reachable — only the
    /// advice needs a use case, and that arrives on appear.
    private let scan: FaceScan
    /// Called when the user leaves Results — back lands on Home, "See my plan"
    /// on Improve. `nil` when Results was pushed from Home, where the navigation
    /// stack dismisses itself.
    private let onExit: ((AppRouter.Tab) -> Void)?
    /// The photo this result was produced from, when the scan just happened.
    /// Nil for history, which has no stored imagery yet.
    private let photo: UIImage?

    init(scan: FaceScan, photo: UIImage? = nil, onExit: ((AppRouter.Tab) -> Void)? = nil) {
        self.scan = scan
        self.photo = photo
        self.onExit = onExit
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppBackground()

            // One page-level scroll. The photo, the score header and the
            // metrics used to be three absolutely positioned siblings with a
            // scroll view only around the metrics list; on a container shorter
            // than a phone screen — an iPhone app windowed on iPad — the
            // bottom of the report was simply cut off, which App Review
            // rejected (Guideline 4, submission 0aada89e).
            //
            // The design's offsets are kept: the header block reserves the
            // height the metrics list used to start at, so the phone layout is
            // unchanged, and everything below it now scrolls with the page.
            ScrollView {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        photoHeader

                        ResultsScoreHeader(scan: scan)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 246)
                    }
                    // minHeight, not height: the score header must be free to
                    // grow into the gap rather than clip if its copy wraps.
                    .frame(minHeight: metricsTop, alignment: .top)

                    metricsSection
                }
            }
            // Indicators are left visible: on a short container they are the
            // cue that the report continues below the fold.
            .scrollBounceBehavior(.basedOnSize)
        }
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if viewModel == nil {
                viewModel = ResultsViewModel(scan: scan, dependencies: dependencies)
            }
            viewModel?.load()
        }
    }

    /// The design lands the metrics list at y 432, which sits well below the
    /// score header. When a pose warning leads the list that slack reads as a
    /// gap under the cohort line, so the list starts high enough to keep the
    /// warning tight to it. Without a warning the design offset is unchanged.
    private var metricsTop: CGFloat {
        scan.poseWarning == nil ? 432 : 404
    }

    // MARK: - Header

    private var photoHeader: some View {
        PhotoSlot(placeholder: scan.photoDescription, image: photo)
            .frame(height: 330)
            .frame(maxWidth: .infinity)
            .overlay {
                MeasuredLandmarkOverlay(
                    landmarks: scan.landmarks,
                    imageSize: photo?.size,
                    density: .results,
                    dotSize: 4,
                    connectorOpacity: 0.4
                )
            }
            .overlay(AppGradient.resultsScrim)
            .clipped()
            .overlay(alignment: .top) { backButton }
    }

    /// Shown only when the head was turned far enough at capture to move the
    /// numbers. Leads the metrics list, directly under the cohort line, so it
    /// reads as a caveat on every number below it.
    ///
    /// Not on the photo: the score header starts at y 246, inside the 330pt
    /// photo, and covered it there.
    ///
    /// Deliberately loud — warning colour, icon, opaque backing. The client's
    /// condition for scoring an angled photo instead of refusing it was that the
    /// caveat cannot read as fine print.
    @ViewBuilder
    private var poseWarning: some View {
        if let warning = scan.poseWarning {
            HStack(alignment: .top, spacing: Spacing.xs) {
                Image(systemName: AppSymbol.poseWarning)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.warning)

                Text(warning)
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .background {
                RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                    .fill(.black.opacity(0.72))
                    .overlay {
                        RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                            .strokeBorder(AppColor.warning.opacity(0.55), lineWidth: 1)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// The tier picked in onboarding, set against the one just scored.
    ///
    /// This is what the target question was collected for — the onboarding copy
    /// promises "your target sets the gap Mogscan measures you against", and
    /// until now nothing read the answer back. Sits in the scroll rather than
    /// under the tier badge because the header is absolutely positioned and a
    /// sixth line there runs into the metrics list.
    /// Drawn as two badges rather than a line of text: as a footnote it was the
    /// quietest thing on a screen full of numbers, which is backwards for the one
    /// answer the user gave before scanning.
    @ViewBuilder
    private var targetGap: some View {
        if let target = router.targetRank {
            Group {
                if let reached = viewModel?.targetReachedCaption(target) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: AppSymbol.targetReached)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AppColor.success)

                        Text(reached)
                            .font(AppFont.calloutEmphasis)
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    // A grid, not an HStack of columns: it pins the arrow to the
                    // badge row rather than centring it against label-plus-badge,
                    // and keeps both badges on one baseline whatever the tier
                    // names are — "Chad" and "Chad Lite" are very different widths.
                    Grid(alignment: .leading, horizontalSpacing: Spacing.m, verticalSpacing: Spacing.xxs) {
                        GridRow {
                            EyebrowLabel(
                                text: DesignContent.Results.currentLabel,
                                color: AppColor.textSecondary,
                                size: 10,
                                tracking: Tracking.label
                            )

                            Color.clear.frame(width: 0, height: 0)

                            EyebrowLabel(
                                text: DesignContent.Results.targetLabel,
                                color: AppColor.textSecondary,
                                size: 10,
                                tracking: Tracking.label
                            )
                        }

                        GridRow {
                            TierBadge(tier: scan.tier, size: .medium)

                            Image(systemName: AppSymbol.targetArrow)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppColor.accentStart)

                            TierBadge(tier: target, size: .medium)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.horizontal, Spacing.ml)
            .padding(.vertical, Spacing.m)
            .frame(maxWidth: .infinity)
            .background(AppColor.surface, in: RoundedRectangle(
                cornerRadius: Radius.listCard, style: .continuous
            ))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.listCard, style: .continuous)
                    .strokeBorder(AppColor.accentStart.opacity(0.28), lineWidth: 1)
            }
        }
    }

    /// Back only. The design pairs it with a share button, which is not built:
    /// sharing a result means rendering a card to an image, and that is the
    /// marketing-tool work the client took out of scope.
    private var backButton: some View {
        CircleIconButton(
            symbol: AppSymbol.chevronLeft,
            accessibilityLabelText: "Back"
        ) {
            if let onExit { onExit(.home) } else { dismiss() }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // The 32pt circle sits in a 44pt hit target, so the container is inset
        // by 6pt less than the design's 20 to land the visible chrome exactly.
        .padding(.horizontal, 14)
        .padding(.top, 56)
    }

    /// The weakest metrics, with something to do about them.
    ///
    /// The client's brief for the unlocked report was explicit that a score on
    /// its own would feel like selling a number, so the report itself carries
    /// advice rather than only pointing at the Improve tab. Two cards, then the
    /// CTA to the full plan directly beneath.
    @ViewBuilder
    private var adviceSection: some View {
        if let advice = viewModel?.advice, !advice.isEmpty {
            SectionHeader(title: DesignContent.Results.adviceSection)
                .padding(.top, Spacing.xs)

            ForEach(Array(advice.enumerated()), id: \.element.id) { index, item in
                MetricAdviceCard(advice: item, index: index, showsWhyItMatters: false)
            }
        }
    }

    // MARK: - Metrics

    /// A plain stack, not a scroll view: it is inside the page scroll now, and
    /// nesting two vertical scrolls is what left the report unreachable.
    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            targetGap

            poseWarning

            SectionHeader(title: DesignContent.Results.metricsSection)

            ForEach(Array(scan.metrics.enumerated()), id: \.element.id) { index, metric in
                MetricCard(metric: metric, delay: viewModel?.delay(for: index) ?? 0)
            }

            adviceSection

            PrimaryButton(title: DesignContent.Results.planCTA) {
                if let onExit { onExit(.improve) } else { router.select(.improve) }
            }
            .padding(.top, Spacing.xxsPlus)

            // Only in the scan flow — from Home the back chevron is the way out.
            if let onExit {
                SecondaryButton(title: DesignContent.Results.homeCTA) {
                    onExit(.home)
                }
            }
        }
        .padding(.horizontal, Layout.horizontal)
        .padding(.bottom, Spacing.section)
    }
}

#Preview("16 Results") {
    NavigationStack {
        ResultsView(scan: PreviewData.latestScan)
    }
    .environment(PreviewData.dependencies)
    .environment(PreviewData.routerWithTarget)
    .preferredColorScheme(.dark)
}
