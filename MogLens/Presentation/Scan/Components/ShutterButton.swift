import SwiftUI

/// The 76pt shutter: a white ring around a solid disc.
/// Scales to 0.9 on press with an `.impact(.medium)` haptic.
struct ShutterButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(.white.opacity(0.9), lineWidth: 4)
                Circle()
                    .fill(.white)
                    .padding(8)
            }
            .frame(width: 76, height: 76)
        }
        .buttonStyle(ShutterButtonStyle())
        .accessibilityLabel("Take photo")
    }
}

private struct ShutterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(AppMotion.buttonPress, value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .medium), trigger: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.black
        ShutterButton(action: {})
    }
}
