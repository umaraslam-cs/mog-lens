import SwiftUI

/// 10 — Settings. A native sheet with an inset grouped list.
/// Reached only from the Home gear — never a tab.
struct SettingsView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    /// The system review prompt. Apple decides whether it actually appears —
    /// see ``rateApp()``.
    @Environment(\.requestReview) private var requestReview
    @State private var viewModel: SettingsViewModel? = nil
    /// Non-nil while a legal document is presented over the sheet.
    @State private var legalDocument: LegalDocument.Kind? = nil
    /// Drives the system share sheet.
    @State private var isSharing = false
    /// Drives Apple's own manage-subscriptions sheet.
    @State private var isManagingSubscription = false
    /// Raised by Delete All Scan Data. Deleting face data is irreversible, so it
    /// is confirmed before anything leaves the disk.
    @State private var isConfirmingDelete = false

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [AppColor.sheetTop, AppColor.sheetBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                SheetHeader(
                    title: DesignContent.Settings.title,
                    trailingTitle: DesignContent.Settings.done
                ) { dismiss() }

                ScrollView {
                    VStack(spacing: Spacing.group) {
                        ForEach(viewModel?.sections ?? []) { section in
                            SettingsGroup(section: section) { entry in
                                select(entry)
                            }
                        }

                        versionFooter
                    }
                    .padding(.horizontal, Spacing.l)
                    .padding(.vertical, Spacing.xxl)
                }
                .scrollIndicators(.hidden)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(Radius.card)
        .presentationBackground(AppColor.sheetTop)
        .presentationDragIndicator(.hidden)
        .onAppear {
            if viewModel == nil {
                viewModel = SettingsViewModel(dependencies: dependencies)
            }
            viewModel?.load()
        }
        .sheet(item: $legalDocument) { LegalDocumentView(kind: $0) }
        .manageSubscriptionsSheet(isPresented: $isManagingSubscription)
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
        // An alert, not a confirmation dialog: the dialog renders as a narrow
        // centred column on a phone and the body copy ends up in a thin ribbon.
        // Nothing follows this one — the success alert it used to raise is gone,
        // so there are no two alerts left to race.
        .alert(
            DesignContent.Settings.deleteDataConfirmTitle,
            isPresented: $isConfirmingDelete
        ) {
            Button(DesignContent.Settings.deleteDataConfirm, role: .destructive) {
                viewModel?.deleteAllScanData()
            }
            Button(DesignContent.Settings.deleteDataCancel, role: .cancel) {}
        } message: {
            Text(DesignContent.Settings.deleteDataConfirmBody)
        }
        .sheet(isPresented: $isSharing) {
            if let url = DesignContent.Settings.appStoreURL {
                ShareSheet(
                    message: DesignContent.Settings.shareMessage,
                    url: url,
                    subject: DesignContent.Settings.shareSubject
                )
            }
        }
    }

    /// Routes a tapped row. Rows are data, so this is the one place that knows
    /// what any of them do.
    private func select(_ entry: SettingsEntry) {
        switch entry.id {
        case "privacy", "terms":
            legalDocument = LegalDocument.Kind(rawValue: entry.id)
        case "contact":
            contactSupport()
        case "share":
            isSharing = true
        case "rate":
            rateApp()
        case "restore":
            Task { await viewModel?.restorePurchases() }
        case "manage":
            manageSubscription()
        case "delete-data":
            isConfirmingDelete = true
        default:
            break
        }
    }

    /// Opens Apple's manage-subscriptions sheet, falling back to the App Store
    /// account page.
    ///
    /// The sheet is the better experience but it is the one Apple can decline
    /// to present — it needs a StoreKit-visible subscription, so it shows
    /// nothing at all in some sandbox states. `.manageSubscriptionsSheet` gives
    /// no callback for that, so the fallback URL runs whenever the entitlement
    /// isn't active and this device therefore has nothing for the sheet to
    /// show. Both land the user in the same place; only one of them can end in
    /// a tap that does nothing.
    private func manageSubscription() {
        if checkSubscription() {
            isManagingSubscription = true
        } else if let url = DesignContent.Settings.manageSubscriptionsURL {
            openURL(url)
        }
    }

    private func checkSubscription() -> Bool {
        dependencies.checkSubscription()
    }

    /// Opens the mail app on the support address, subject prefilled.
    ///
    /// Percent-encoded because a raw space in a `mailto` query makes the whole
    /// URL fail to build, which would silently do nothing.
    private func contactSupport() {
        let subject = DesignContent.Settings.supportSubject
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        guard let url = URL(
            string: "mailto:\(DesignContent.Settings.supportEmail)?subject=\(subject)"
        ) else { return }
        openURL(url)
    }

    /// Asks for the in-app App Store rating prompt.
    ///
    /// Apple rate-limits this to three prompts a year and ignores it entirely
    /// in some states, so a tap can legitimately show nothing — there is no
    /// callback and no way to detect it. That is why the row exists in Settings
    /// rather than being triggered automatically after a good scan: the user
    /// asked for it, so an occasional no-op reads as nothing happening rather
    /// than as a broken button.
    private func rateApp() {
        requestReview()
    }

    private var versionFooter: some View {
        VStack(spacing: Spacing.xxs) {
            Text(viewModel?.version.displayString ?? "")
                .font(AppFont.footnote)
                .foregroundStyle(AppColor.textSecondary)
            Text(viewModel?.version.disclaimer ?? "")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary.opacity(0.6))
        }
        .padding(.top, Spacing.xxsPlus)
        .accessibilityElement(children: .combine)
    }
}

#Preview("10 Settings") {
    Color.black
        .sheet(isPresented: .constant(true)) {
            SettingsView()
                .environment(PreviewData.dependencies)
        }
        .preferredColorScheme(.dark)
}
