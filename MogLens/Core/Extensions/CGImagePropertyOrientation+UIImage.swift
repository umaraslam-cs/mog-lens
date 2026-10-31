import ImageIO
import UIKit

extension CGImagePropertyOrientation {
    /// A `CGImage` carries no orientation, so Vision has to be told the one its
    /// `UIImage` wrapper was holding. Skipping this rotates every landmark by 90°
    /// on camera photos while still returning perfectly plausible numbers.
    init(_ orientation: UIImage.Orientation) {
        self = switch orientation {
        case .up: .up
        case .upMirrored: .upMirrored
        case .down: .down
        case .downMirrored: .downMirrored
        case .left: .left
        case .leftMirrored: .leftMirrored
        case .right: .right
        case .rightMirrored: .rightMirrored
        @unknown default: .up
        }
    }
}
