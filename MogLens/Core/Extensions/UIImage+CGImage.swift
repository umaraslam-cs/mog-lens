import CoreGraphics
import ImageIO
import UIKit

extension UIImage {
    /// Extracts or renders a guaranteed non-nil standard CGImage.
    var guaranteedCGImage: CGImage? {
        if let cgImage = self.cgImage {
            return cgImage
        }
        if let ciImage = self.ciImage {
            let context = CIContext(options: nil)
            if let cg = context.createCGImage(ciImage, from: ciImage.extent) {
                return cg
            }
        }
        guard size.width > 0, size.height > 0 else { return nil }

        let width = max(1, Int(size.width * (scale > 0 ? scale : 1.0)))
        let height = max(1, Int(size.height * (scale > 0 ? scale : 1.0)))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }

        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context)
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()

        return context.makeImage()
    }

    /// Normalizes image orientation to `.up` and guarantees a backing `CGImage`.
    ///
    /// Uses `UIGraphicsImageRenderer` rather than a manual `CGContext` because
    /// `UIImage.draw(in:)` silently produces a blank bitmap when the context uses
    /// a non-native byte order (`byteOrder32Big` on little-endian iOS). The
    /// renderer always uses the correct BGRA format and handles every
    /// `UIImage.imageOrientation` value automatically.
    func normalizedUpImage() -> UIImage {
        let renderScale = scale > 0 ? scale : 1.0
        let pixelSize = CGSize(
            width: (size.width * renderScale).rounded(),
            height: (size.height * renderScale).rounded()
        )
        guard pixelSize.width >= 1, pixelSize.height >= 1 else { return self }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0   // 1 pt == 1 px, so size equals pixel count
        format.opaque = true
        return UIGraphicsImageRenderer(size: pixelSize, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: pixelSize))
        }
    }
}
