import Foundation

/// A purchasable plan shown on the paywall. Two products ship: monthly and
/// annual. The weekly plan the design shipped with was dropped by the client on
/// 15 Aug 2026 — a single short plan cannibalised the annual without adding
/// reach.
struct SubscriptionPlan: Identifiable, Hashable {
    enum Period: String, CaseIterable, Hashable {
        case monthly, annual
    }

    let period: Period
    let title: String
    /// Ready to render, e.g. "$39.99 / year · $3.33 per month".
    ///
    /// Composed from the store product wherever the store answers, so a price
    /// change or a foreign currency needs no code change. The bundled copy is
    /// the fallback for a paywall shown before the offering loads.
    let priceCaption: String
    /// e.g. "SAVE 72%". Optional.
    let badge: String?

    var id: Period { period }
}

/// An unlocked capability with expandable accordion details on the paywall.
struct PaywallBenefit: Identifiable, Hashable {
    let id: Int
    let symbol: String
    let title: String
    let subtitle: String
    let detail: String
    let highlights: [String]

    var text: String { title }

    init(
        id: Int,
        symbol: String = "checkmark.circle.fill",
        title: String,
        subtitle: String = "",
        detail: String = "",
        highlights: [String] = []
    ) {
        self.id = id
        self.symbol = symbol
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.highlights = highlights
    }

    init(id: Int, text: String) {
        self.init(id: id, title: text)
    }
}
