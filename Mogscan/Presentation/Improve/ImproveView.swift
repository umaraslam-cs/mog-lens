import SwiftUI

/// 17 — Improve. The client's advice table, one card per metric weakest first,
/// then seven general habit categories ordered by that same weakest metric. No
/// generated text — every word ships in the bundle.
struct ImproveView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: ImproveViewModel? = nil
    @State private var isShowingPaywall = false

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    header

                    if viewModel?.isLocked == true {
                        // Same gate as Home: the advice order and the priority
                        // region are measured results, so neither is shown
                        // before the subscription is.
                        LockedResultsCard(detail: DesignContent.Improve.lockedDetail) {
                            isShowingPaywall = true
                        }
                    }

                    if let focus = viewModel?.priorityFocus {
                        InfoBanner(
                            symbol: AppSymbol.priority,
                            title: focus.title,
                            detail: focus.detail,
                            style: .accent,
                            symbolSize: 20
                        )
                    }

                    if let advice = viewModel?.advice, !advice.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            SectionHeader(title: DesignContent.Improve.adviceSection)

                            ForEach(Array(advice.enumerated()), id: \.element.id) { index, item in
                                MetricAdviceCard(advice: item, index: index)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: Spacing.s) {
                        SectionHeader(title: DesignContent.Improve.habitsSection)

                        ForEach(Array((viewModel?.recommendations ?? []).enumerated()), id: \.element.id) { index, item in
                            RecommendationCard(recommendation: item, index: index)
                        }
                    }
                }
                .padding(.horizontal, Layout.horizontal)
                .padding(.top, Spacing.s)
                .padding(.bottom, Spacing.section)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
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
                viewModel = ImproveViewModel(dependencies: dependencies)
            }
            viewModel?.load()
        }
        .task {
            await viewModel?.refreshEntitlement()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(DesignContent.Improve.title)
                .font(AppFont.screenTitle)
                .tracking(Tracking.screenTitle)
                .lineHeight(1.1, size: 32)
                .foregroundStyle(AppColor.textPrimary)

            if let subtitle = viewModel?.subtitle {
                Text(subtitle)
                    .font(AppFont.system(14.5))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview("17 Improve") {
    NavigationStack {
        ImproveView()
    }
    .environment(PreviewData.dependencies)
    .environment(PreviewData.routerWithTarget)
    .preferredColorScheme(.dark)
}
