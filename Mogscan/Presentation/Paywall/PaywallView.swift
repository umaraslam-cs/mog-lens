import SwiftUI

/// 15 — Paywall. Appears after scanning.
///
/// Features an interactive expandable/accordion feature list detailing all unlocked
/// biometric analysis tools, score tiers, and trajectory tracking.
struct PaywallView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(AppRouter.self) private var router
    @State private var viewModel: PaywallViewModel? = nil
    /// Non-nil while a legal document is presented over the paywall.
    @State private var legalDocument: LegalDocument.Kind? = nil
    /// Tracks which accordion feature items are currently expanded. First is open by default.
    @State private var expandedBenefitIds: Set<Int> = [0]

    let onUnlock: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackground()

            // Decorative background radial glow
            Color.clear
                .overlay(alignment: .top) {
                    RadialGlow(opacity: 0.16, diameter: 460, falloff: 0.7)
                        .offset(y: -290)
                }

            // Scrollable paywall content: header, expandable accordion features, and plan selector
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.l) {
                    header
                        .padding(.top, 52)

                    benefitAccordionList

                    planList

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, Layout.horizontal)
                .padding(.bottom, Layout.bottomCTAInset + 140)
            }

            // Pinned bottom CTA footer with smooth gradient fade
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                footer
                    .background {
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: AppColor.backgroundMid.opacity(0.85), location: 0.25),
                                .init(color: AppColor.backgroundMid, location: 0.55)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    }
            }

            // Floating Close button
            CircleIconButton(
                symbol: AppSymbol.close,
                symbolSize: 13,
                background: AppColor.hairline,
                foreground: AppColor.textSecondary,
                accessibilityLabelText: "Close",
                action: onClose
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.leading, 14)
            .padding(.top, 2)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if viewModel == nil {
                viewModel = PaywallViewModel(dependencies: dependencies)
            }
            // Already entitled — never show the ask. `load()` refreshes the
            // entitlement before it fetches the offer for exactly this case.
            if await viewModel?.load() == true { onUnlock() }
        }
        .sheet(item: $legalDocument) { LegalDocumentView(kind: $0) }
        .alert(
            DesignContent.Paywall.noticeTitle,
            isPresented: Binding(
                get: { viewModel?.message != nil },
                set: { if !$0 { viewModel?.message = nil } }
            ),
            presenting: viewModel?.message
        ) { _ in
            Button(DesignContent.Paywall.errorDismiss, role: .cancel) {}
        } message: { text in
            Text(text)
        }
    }

    /// True while a store call is in flight — the CTA and the restore link are
    /// both inert until it settles, so a slow App Store sheet cannot be tapped
    /// into two purchases.
    private var isBusy: Bool { viewModel?.isBusy == true }

    // MARK: - Sections

    /// Reflects the onboarding target back just before the ask, so the purchase
    /// is framed as closing a gap the user named themselves.
    @ViewBuilder
    private var targetTeaser: some View {
        if let target = router.targetRank {
            Text(DesignContent.Paywall.targetTeaser(target.displayName))
                .font(AppFont.footnote)
                .foregroundStyle(AppColor.accentStart)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var header: some View {
        VStack(spacing: Spacing.m) {
            IconTile(
                symbol: AppSymbol.locked,
                size: 56,
                radius: Radius.listCard,
                symbolSize: 24,
                fillOpacity: 0.14,
                border: AppColor.accentStart.opacity(0.3)
            )

            Text(DesignContent.Paywall.title)
                .font(AppFont.title1)
                .tracking(Tracking.title1)
                .lineHeight(1.12, size: 30)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(DesignContent.Paywall.subtitle)
                .font(AppFont.callout)
                .lineHeight(1.4, size: 16)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            targetTeaser
        }
        .frame(maxWidth: .infinity)
    }

    /// Expandable / accordion feature list showcasing everything unlocked with a subscription
    private var benefitAccordionList: some View {
        VStack(spacing: Spacing.s) {
            // Header with interactive Expand/Collapse All toggle
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppColor.accentStart)
                        .frame(width: 5, height: 5)
                        .shadow(color: AppColor.accentStart.opacity(0.8), radius: 3)

                    Text("WHAT'S INCLUDED")
                        .font(AppFont.mono(11, .bold))
                        .tracking(1.0)
                        .foregroundStyle(AppColor.accentStart)
                }

                Spacer()

                let totalCount = viewModel?.benefits.count ?? 0
                if totalCount > 0 {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if expandedBenefitIds.count == totalCount {
                                expandedBenefitIds.removeAll()
                            } else {
                                expandedBenefitIds = Set((viewModel?.benefits ?? []).map(\.id))
                            }
                        }
                    } label: {
                        Text(expandedBenefitIds.count == totalCount ? "COLLAPSE ALL" : "EXPAND ALL")
                            .font(AppFont.mono(10.5, .semibold))
                            .tracking(0.7)
                            .foregroundStyle(AppColor.accentStart.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 2)

            // Accordion benefit cards
            ForEach(viewModel?.benefits ?? []) { benefit in
                AccordionBenefitCard(
                    benefit: benefit,
                    isExpanded: expandedBenefitIds.contains(benefit.id)
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        if expandedBenefitIds.contains(benefit.id) {
                            expandedBenefitIds.remove(benefit.id)
                        } else {
                            expandedBenefitIds.insert(benefit.id)
                        }
                    }
                }
            }
        }
    }

    /// Whether there is something real to buy.
    private var canPurchase: Bool { viewModel?.canPurchase == true }

    @ViewBuilder
    private var planList: some View {
        switch viewModel?.planState ?? .loading {
        case .ready:
            plans
        case .loading:
            planPlaceholder(DesignContent.Paywall.plansLoading, retry: false)
        case .unavailable:
            planPlaceholder(DesignContent.Paywall.plansUnavailable, retry: true)
        }
    }

    private func planPlaceholder(_ text: String, retry: Bool) -> some View {
        VStack(spacing: Spacing.s) {
            Text(text)
                .font(AppFont.footnote)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if retry {
                Button(DesignContent.Paywall.plansRetry) {
                    Task { if await viewModel?.retryLoadingPlans() == true { onUnlock() } }
                }
                .font(AppFont.system(13.5, .semibold))
                .foregroundStyle(AppColor.accentStart)
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var plans: some View {
        VStack(spacing: Spacing.s) {
            ForEach(viewModel?.plans ?? []) { plan in
                PaywallPlanCard(
                    plan: plan,
                    isSelected: viewModel?.selectedPlan == plan.period
                ) {
                    viewModel?.select(plan.period)
                }
            }
        }
    }

    private var footer: some View {
        BottomCTA(spacing: Spacing.ml) {
            PrimaryButton(
                title: DesignContent.Paywall.cta,
                height: Layout.prominentButtonHeight,
                font: AppFont.system(17.5, .semibold),
                shadow: AppShadow.prominentButton
            ) {
                Task { if await viewModel?.purchase() == true { onUnlock() } }
            }
            .disabled(!canPurchase)
            .opacity(canPurchase ? 1 : 0.6)

            CTACaption(
                text: DesignContent.Paywall.disclaimer,
                size: 12,
                color: AppColor.textSecondary.opacity(0.8)
            )

            HStack(spacing: Spacing.ml) {
                Button(DesignContent.Paywall.restore) {
                    Task { if await viewModel?.restorePurchases() == true { onUnlock() } }
                }
                .disabled(isBusy)
                Text("·").opacity(0.4)
                Button(DesignContent.Paywall.terms) { legalDocument = .terms }
                Text("·").opacity(0.4)
                Button(DesignContent.Paywall.privacy) { legalDocument = .privacy }
            }
            .font(AppFont.system(12.5))
            .foregroundStyle(AppColor.textSecondary)
            .buttonStyle(.plain)
        }
    }
}

#Preview("15 Paywall") {
    PaywallView(onUnlock: {}, onClose: {})
        .environment(PreviewData.lockedDependencies)
        .environment(PreviewData.routerWithTarget)
        .preferredColorScheme(.dark)
}
