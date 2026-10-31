import Foundation

/// SF Symbols used by the app.
///
/// This is the "Icon map → SF Symbols" handoff table from the design, resolved.
/// One library only, no mixing.
enum AppSymbol {

    // MARK: Navigation

    static let homeTab = "house"
    static let homeTabSelected = "house.fill"
    /// Face in a frame — reads as "scan your face" rather than a generic camera.
    static let scanTab = "person.crop.square"
    static let improveTab = "chart.line.uptrend.xyaxis"
    static let settings = "gearshape"

    // MARK: Chrome

    static let chevronRight = "chevron.right"
    static let chevronLeft = "chevron.left"
    static let close = "xmark"
    static let checkmark = "checkmark"
    static let checkmarkCircle = "checkmark.circle.fill"

    // MARK: Scan

    static let takePhoto = "camera.fill"
    static let importPhoto = "photo.on.rectangle"
    static let faceGuide = "person.crop.square"
    static let evenLight = "sun.max"
    static let neutralExpression = "face.dashed"
    static let eyesLevel = "eye"

    // MARK: Technology

    static let landmarks = "square.dashed.inset.filled"
    static let geometry = "ruler"
    static let noFakeScores = "nosign"

    // MARK: Onboarding

    static let readInSeconds = "stopwatch"
    static let opportunities = "briefcase"
    static let confidence = "checkmark.shield"
    static let info = "info.circle"
    static let poseWarning = "exclamationmark.triangle.fill"
    static let urgency = "hourglass"

    // MARK: Results

    /// The tier picked in onboarding, shown against the one scored.
    static let target = "scope"
    /// Points from the tier reached to the tier being trained for.
    static let targetArrow = "arrow.right"
    /// Same line once the target has been reached.
    static let targetReached = "checkmark.circle.fill"

    // MARK: Paywall

    static let locked = "lock.fill"

    // MARK: Improve

    static let priority = "scope"

    // MARK: Metrics

    static let symmetry = "square.split.2x1"
    static let jawAngle = "angle"
    static let chinRatio = "arrow.up.and.down.text.horizontal"
    static let eyeSpacing = "eyes"
    static let midfaceRatio = "rectangle.compress.vertical"
    static let skincare = "drop.fill"
    static let posture = "figure.stand"
    static let jawExercises = "waveform.path.ecg"
    static let sleep = "moon.stars.fill"
    static let hydration = "cup.and.saucer.fill"
    static let grooming = "scissors"
    static let lifestyle = "flame.fill"

    // MARK: Settings

    static let restorePurchases = "arrow.clockwise"
    static let manageSubscription = "creditcard"
    static let privacyPolicy = "lock.shield"
    static let termsOfService = "doc.text"
    static let rateApp = "star"
    static let shareApp = "square.and.arrow.up"
    static let contactSupport = "envelope"
    /// Both the Settings row and the per-scan delete in the history menu.
    static let delete = "trash"
}
