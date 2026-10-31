import SwiftUI

/// A number that counts up as it animates. Monospaced digits keep it from
/// jittering while the value changes.
struct AnimatedNumberText: View, Animatable {
    var value: Double
    var font: Font = AppFont.heroScore
    var tracking: CGFloat = Tracking.heroScore
    var color: Color = AppColor.textPrimary

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text("\(Int(value.rounded()))")
            .font(font)
            .tracking(tracking)
            .monospacedDigit()
            .foregroundStyle(color)
    }
}

#Preview {
    struct Wrapper: View {
        @State private var value: Double = 0

        var body: some View {
            ZStack {
                AppBackground()
                AnimatedNumberText(value: value)
                    .onAppear {
                        withAnimation(.easeOut(duration: AppMotion.scoreCountDuration)) { value = 81 }
                    }
            }
        }
    }
    return Wrapper()
}
