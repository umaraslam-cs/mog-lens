import Foundation

/// Why an analysis could not produce a score.
///
/// Every case ends the scan flow the same way — an alert, then back to the Scan
/// entry screen — but they carry different copy, so the user knows whether to
/// retake the photo or pick a different one.
enum FaceAnalysisError: Error, Hashable {
    /// Vision found no face at all.
    case noFaceDetected
    /// A face was found, but without landmarks there is nothing to measure.
    case landmarksUnavailable
    /// The image could not be read — an unsupported or corrupt file.
    case imageUnreadable
}
