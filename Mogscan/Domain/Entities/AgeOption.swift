import Foundation

/// One detent of the onboarding age wheel.
///
/// Facial ratios are benchmarked against the user's age group, so this is the
/// only demographic the app collects.
struct AgeOption: Identifiable, Hashable {
    let years: Int

    var id: Int { years }

    /// The range offered by the wheel.
    static let all: [AgeOption] = (16...60).map(AgeOption.init(years:))

    /// Centred on the wheel when onboarding opens.
    static let `default` = AgeOption(years: 21)
}
