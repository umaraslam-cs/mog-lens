import Foundation

/// One row of the Settings sheet.
struct SettingsEntry: Identifiable, Hashable {
    /// Tint of the leading icon tile.
    enum Tint: Hashable {
        case accent
        case neutral
        case warning
        /// Irreversible — currently only Delete All Scan Data.
        case destructive
    }

    let id: String
    let title: String
    let symbol: String
    let tint: Tint
}

/// A grouped section of the Settings sheet.
struct SettingsSection: Identifiable, Hashable {
    let id: String
    /// Uppercased group header, e.g. "SUBSCRIPTION".
    let header: String
    let entries: [SettingsEntry]
}

/// Version footer of the Settings sheet.
struct AppVersionInfo: Hashable {
    let marketingVersion: String
    let buildNumber: String
    let disclaimer: String

    /// e.g. "MogLens 1.0.0 (24)".
    var displayString: String { "MogLens \(marketingVersion) (\(buildNumber))" }
}
