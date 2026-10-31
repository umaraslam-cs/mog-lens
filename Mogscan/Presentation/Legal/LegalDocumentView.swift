import SwiftUI

/// Privacy Policy and Terms of Use. Not in the 17-screen design set — the
/// two documents read the same, so one sheet renders either, matching the
/// Settings sheet it is presented from.
struct LegalDocumentView: View {
    let kind: LegalDocument.Kind

    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: LegalDocumentViewModel? = nil

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
                    title: viewModel?.document?.title ?? "",
                    trailingTitle: DesignContent.Legal.done
                ) { dismiss() }

                ScrollView {
                    if let document = viewModel?.document {
                        documentBody(document)
                    }
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
                viewModel = LegalDocumentViewModel(dependencies: dependencies)
            }
            viewModel?.load(kind)
        }
    }

    private func documentBody(_ document: LegalDocument) -> some View {
        VStack(alignment: .leading, spacing: Spacing.section) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text(document.lastUpdated)
                    .font(AppFont.eyebrow)
                    .tracking(Tracking.eyebrow)
                    .foregroundStyle(AppColor.textSecondary)

                Text(document.summary)
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textPrimary)
            }

            ForEach(document.sections) { section in
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(section.heading)
                        .font(AppFont.calloutEmphasis)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(section.body)
                        .font(AppFont.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.vertical, Spacing.xxl)
    }
}

#Preview("Legal — Privacy") {
    Color.black
        .sheet(isPresented: .constant(true)) {
            LegalDocumentView(kind: .privacy)
                .environment(PreviewData.dependencies)
        }
        .preferredColorScheme(.dark)
}

#Preview("Legal — Terms") {
    Color.black
        .sheet(isPresented: .constant(true)) {
            LegalDocumentView(kind: .terms)
                .environment(PreviewData.dependencies)
        }
        .preferredColorScheme(.dark)
}
