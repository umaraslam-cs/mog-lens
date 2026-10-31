import SwiftUI
import UIKit

/// Placeholder for imagery that has not shipped yet.
///
/// The design's photo areas are drop targets with no bundled assets, so this
/// renders a subtly striped dark fill with a monospace explainer naming what
/// belongs there. Pass an `imageName` once real assets land in the asset
/// catalogue and the placeholder is replaced with no other change at the call site.
struct PhotoSlot: View {
    /// What should be dropped here, e.g. "Aspirational male portrait — hard light, cool grade".
    let placeholder: String
    /// A photo the user supplied this session. Takes precedence over everything else.
    var image: UIImage?
    /// Asset catalogue name. When present and resolvable, the real image is drawn.
    var imageName: String?
    /// Hides the explainer for very small slots such as history thumbnails.
    var showsLabel: Bool = true

    var body: some View {
        ZStack {
            if let image {
                filling { Image(uiImage: image) }
            } else if let imageName, UIImage(named: imageName) != nil {
                filling { Image(imageName) }
            } else {
                placeholderContent
            }
        }
        .clipped()
        .accessibilityLabel(placeholder)
    }

    /// Fills the slot without letting the photo size it.
    ///
    /// `scaledToFill` reports the *scaled* dimensions, so the image is wider or
    /// taller than the space it was offered. Left as a plain child that measured
    /// size becomes the slot's size and pushes the screen around it out of
    /// place. `Color.clear` takes the offered size instead; an overlay cannot
    /// change its parent's geometry, so the overflow is drawn and then clipped.
    private func filling(_ image: () -> Image) -> some View {
        Color.clear.overlay {
            image()
                .resizable()
                .scaledToFill()
        }
    }

    private var placeholderContent: some View {
        ZStack {
            LinearGradient(
                colors: [AppColor.photoPlaceholderTop, AppColor.photoPlaceholderBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            StripePattern()
                .foregroundStyle(Color.white.opacity(0.035))

            if showsLabel {
                GeometryReader { geometry in
                    if geometry.size.height > 90 {
                        Text(placeholder)
                            .font(.system(size: 11, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppColor.textSecondary.opacity(0.75))
                            .padding(.horizontal, Spacing.l)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    } else {
                        Image(systemName: AppSymbol.faceGuide)
                            .font(.system(size: min(geometry.size.height * 0.42, 22), weight: .light))
                            .foregroundStyle(AppColor.textSecondary.opacity(0.55))
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
        }
    }
}

/// Diagonal hairline stripes — the placeholder texture.
private struct StripePattern: View {
    var spacing: CGFloat = 9

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let diagonal = size.width + size.height
                var offset: CGFloat = 0
                while offset < diagonal {
                    var path = Path()
                    path.move(to: CGPoint(x: offset, y: 0))
                    path.addLine(to: CGPoint(x: offset - size.height, y: size.height))
                    context.stroke(path, with: .color(.white), lineWidth: 1)
                    offset += spacing
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.l) {
            PhotoSlot(placeholder: "Aspirational male portrait — hard light, cool grade")
                .frame(height: 220)
                .roundedClip(Radius.frame)
            PhotoSlot(placeholder: "scan", showsLabel: true)
                .frame(width: 52, height: 52)
                .roundedClip(12)
        }
        .padding(Layout.horizontal)
    }
}
