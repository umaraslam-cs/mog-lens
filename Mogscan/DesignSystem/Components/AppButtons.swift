import SwiftUI

// MARK: - Styles

/// Primary action: accent gradient, 54pt tall, `#04141B` label.
/// Pressed → scale 0.97 with a darkened ramp; disabled → 35% opacity.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var height: CGFloat = Layout.buttonHeight
    var font: Font = AppFont.headline
    var shadow: (color: Color, radius: CGFloat, y: CGFloat) = AppShadow.primaryButton

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundStyle(AppColor.onAccent)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                configuration.isPressed ? AppGradient.accentPressed : AppGradient.accent,
                in: RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
            )
            .appShadow(configuration.isPressed ? pressedShadow : shadow)
            .opacity(isEnabled ? 1 : 0.35)
            .scaleEffect(configuration.isPressed ? AppMotion.pressedScale : 1)
            .animation(AppMotion.buttonPress, value: configuration.isPressed)
    }

    /// The glow recedes while the button is held.
    private var pressedShadow: (color: Color, radius: CGFloat, y: CGFloat) {
        (color: shadow.color.opacity(0.2), radius: shadow.radius, y: shadow.y)
    }
}

/// Secondary action: translucent surface with a hairline border.
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var height: CGFloat = Layout.buttonHeight

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.headline)
            .foregroundStyle(AppColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .surfaceCard(radius: Radius.button, fill: AppColor.surfaceStrong, border: AppColor.hairlineBold)
            .opacity(isEnabled ? 1 : 0.35)
            .scaleEffect(configuration.isPressed ? AppMotion.pressedScale : 1)
            .animation(AppMotion.buttonPress, value: configuration.isPressed)
    }
}

/// Tertiary action: accent text, no chrome.
struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.system(17, .medium))
            .foregroundStyle(AppColor.accentStart)
            .frame(maxWidth: .infinity)
            .frame(height: Layout.buttonHeight)
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(AppMotion.buttonPress, value: configuration.isPressed)
    }
}

/// A plain tappable region that still gives press feedback — used for cards and rows.
struct PressableStyle: ButtonStyle {
    var scale: CGFloat = AppMotion.pressedScale

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(AppMotion.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - Buttons

/// Primary CTA. Optionally leads with an SF Symbol, and can show a loading spinner.
struct PrimaryButton: View {
    let title: String
    var symbol: String?
    var symbolSize: CGFloat = 17
    var height: CGFloat = Layout.buttonHeight
    var font: Font = AppFont.headline
    var shadow: (color: Color, radius: CGFloat, y: CGFloat) = AppShadow.primaryButton
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if isLoading {
                    SpinnerRing(size: 17, lineWidth: 2, color: AppColor.onAccent, trackOpacity: 0.3)
                } else if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: symbolSize, weight: .semibold))
                }
                Text(title)
            }
        }
        .buttonStyle(PrimaryButtonStyle(height: height, font: font, shadow: shadow))
        .disabled(isLoading)
        .accessibilityLabel(title)
    }
}

/// Secondary CTA.
struct SecondaryButton: View {
    let title: String
    var symbol: String?
    var symbolSize: CGFloat = 17
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: symbolSize, weight: .semibold))
                }
                Text(title)
            }
        }
        .buttonStyle(SecondaryButtonStyle())
        .accessibilityLabel(title)
    }
}

/// A circular icon button laid over imagery — close, back, share, camera flip.
struct CircleIconButton: View {
    let symbol: String
    var diameter: CGFloat = Layout.overlayButton
    var symbolSize: CGFloat = 14
    var background: Color = Color.black.opacity(0.45)
    var foreground: Color = .white
    var accessibilityLabelText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: symbolSize, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(width: diameter, height: diameter)
                .background(background, in: Circle())
        }
        .buttonStyle(PressableStyle())
        // Keeps the 44pt minimum target without inflating the visual chrome.
        .frame(width: Layout.minimumTouchTarget, height: Layout.minimumTouchTarget)
        .contentShape(Rectangle())
        .accessibilityLabel(accessibilityLabelText)
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.s) {
            PrimaryButton(title: "Continue") {}
            PrimaryButton(title: "Scan Again", symbol: AppSymbol.takePhoto) {}
            PrimaryButton(title: "Loading", isLoading: true) {}
            PrimaryButton(title: "Disabled") {}.disabled(true)
            SecondaryButton(title: "Import Photo", symbol: AppSymbol.importPhoto) {}
            Button("Tertiary / text") {}.buttonStyle(TertiaryButtonStyle())
        }
        .padding(Layout.horizontal)
    }
}
