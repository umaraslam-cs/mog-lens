import SwiftUI
import UIKit

/// The system share sheet, presented from a Settings row.
///
/// `ShareLink` would be the idiomatic choice, but it has to *be* the tappable
/// view, and Settings rows are rendered from `SettingsSection` data through one
/// `onSelect` closure — turning one row into a `ShareLink` would mean giving
/// `SettingsGroup` a second way to build a row. Wrapping
/// `UIActivityViewController` keeps the row list uniform and the data-driven
/// list intact, which is the smaller change.
struct ShareSheet: UIViewControllerRepresentable {
    let message: String
    let url: URL
    let subject: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            // Message first, link second: every target that takes both renders
            // them in this order, and the link is the part being passed on.
            activityItems: [message, ShareSubjectSource(url: url, subject: subject)],
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

/// Carries the link plus the subject line that Mail and Messages read.
///
/// A bare `URL` shares fine but arrives with no subject, so an emailed share
/// lands as an untitled message. `UIActivityItemSource` is the only way to
/// supply one.
private final class ShareSubjectSource: NSObject, UIActivityItemSource {
    private let url: URL
    private let subject: String

    init(url: URL, subject: String) {
        self.url = url
        self.subject = subject
    }

    func activityViewControllerPlaceholderItem(_ controller: UIActivityViewController) -> Any {
        url
    }

    func activityViewController(
        _ controller: UIActivityViewController,
        itemForActivityType type: UIActivity.ActivityType?
    ) -> Any? {
        url
    }

    func activityViewController(
        _ controller: UIActivityViewController,
        subjectForActivityType type: UIActivity.ActivityType?
    ) -> String {
        subject
    }
}
