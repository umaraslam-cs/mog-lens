import SwiftUI
import UIKit

/// Visual configuration for ``WheelPicker``. Two presets ship: the neutral age
/// wheel and the accent-tinted target rank wheel.
struct WheelPickerAppearance {
    var wellHeight: CGFloat
    var rowHeight: CGFloat
    var selectedFont: Font
    var nearFont: Font
    var farFont: Font
    var selectedColor: Color
    var nearColor: Color
    var farColor: Color
    var bandFill: Color
    var bandBorder: Color?
    var wellFill: Color = AppColor.surfaceQuiet
    var wellBorder: Color = AppColor.hairline
    var wellRadius: CGFloat = Radius.well
    var bandInset: CGFloat = Spacing.l
    /// Degrees of 3D rotation applied per row away from centre, for wheel feel.
    var curvature: Double = 14

    /// Onboarding age wheel — white 7% selection band.
    static let age = WheelPickerAppearance(
        wellHeight: 236,
        rowHeight: 44,
        selectedFont: AppFont.system(25, .medium),
        nearFont: AppFont.system(23),
        farFont: AppFont.system(23),
        selectedColor: AppColor.textPrimary,
        nearColor: AppColor.textSecondary.opacity(0.62),
        farColor: AppColor.textSecondary.opacity(0.32),
        bandFill: AppColor.surfaceControl,
        bandBorder: nil
    )

    /// Target rank wheel — accent-tinted selection band, accent selected row.
    static let targetRank = WheelPickerAppearance(
        wellHeight: 250,
        rowHeight: 48,
        selectedFont: AppFont.system(25, .semibold),
        nearFont: AppFont.system(21),
        farFont: AppFont.system(20),
        selectedColor: AppColor.accentStart,
        nearColor: AppColor.textSecondary.opacity(0.6),
        farColor: AppColor.textSecondary.opacity(0.3),
        bandFill: AppColor.accentStart.opacity(0.10),
        bandBorder: AppColor.accentStart.opacity(0.25)
    )
}

/// A wheel selector matching the design's picker well.
///
/// Behaves like `UIPickerView.wheel`: rows snap to the selection band, the
/// centred row animates up in weight and colour, and each detent fires a
/// `.selection` haptic.
struct WheelPicker<Item: Identifiable & Hashable>: View {
    let items: [Item]
    @Binding var selection: Item
    var appearance: WheelPickerAppearance = .age
    let title: (Item) -> String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scrolledID: Item.ID?
    /// Only a drag or a tap may change the selection. The scroll to the seeded
    /// position on first layout reports positions too, and without this it
    /// lands on the wrong row.
    @State private var isUserDriven = false

    private let haptics = UISelectionFeedbackGenerator()

    var body: some View {
        ZStack {
            selectionBand

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    // Not lazy: `scrollTo` can only reach rows that exist, and
                    // the age wheel opens on 21 of 45. They are plain text rows.
                    VStack(spacing: 0) {
                        ForEach(items) { item in
                            row(for: item)
                                .id(item.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrolledID, anchor: .center)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 1).onChanged { _ in isUserDriven = true }
                )
                .safeAreaPadding(.vertical, (appearance.wellHeight - appearance.rowHeight) / 2)
                .frame(height: appearance.wellHeight)
                // Open on the current selection rather than the first row.
                .onAppear { proxy.scrollTo(selection.id, anchor: .center) }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: appearance.wellHeight)
        .surfaceCard(
            radius: appearance.wellRadius,
            fill: appearance.wellFill,
            border: appearance.wellBorder
        )
        .roundedClip(appearance.wellRadius)
        .onAppear { haptics.prepare() }
        .onChange(of: scrolledID) { _, newValue in
            guard isUserDriven,
                  let newValue,
                  let item = items.first(where: { $0.id == newValue }),
                  item != selection else { return }
            haptics.selectionChanged()
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                selection = item
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selection wheel")
        .accessibilityValue(title(selection))
    }

    private var selectionBand: some View {
        RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
            .fill(appearance.bandFill)
            .overlay {
                if let border = appearance.bandBorder {
                    RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                        .strokeBorder(border, lineWidth: 1)
                }
            }
            .frame(height: appearance.rowHeight)
            .padding(.horizontal, appearance.bandInset)
            .allowsHitTesting(false)
    }

    private func row(for item: Item) -> some View {
        let distance = distanceFromSelection(item)
        return Text(title(item))
            .font(font(for: distance))
            .foregroundStyle(color(for: distance))
            .frame(maxWidth: .infinity)
            .frame(height: appearance.rowHeight)
            .contentShape(Rectangle())
            .rotation3DEffect(
                .degrees(reduceMotion ? 0 : Double(distance) * appearance.curvature),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.5
            )
            .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: distance)
            .onTapGesture {
                isUserDriven = true
                withAnimation { scrolledID = item.id }
            }
    }

    private func distanceFromSelection(_ item: Item) -> Int {
        guard let selectedIndex = items.firstIndex(of: selection),
              let index = items.firstIndex(of: item) else { return 0 }
        return index - selectedIndex
    }

    private func font(for distance: Int) -> Font {
        switch abs(distance) {
        case 0: appearance.selectedFont
        case 1: appearance.nearFont
        default: appearance.farFont
        }
    }

    private func color(for distance: Int) -> Color {
        switch abs(distance) {
        case 0: appearance.selectedColor
        case 1: appearance.nearColor
        default: appearance.farColor
        }
    }
}

#Preview {
    struct Wrapper: View {
        @State private var age = AgeOption.default
        @State private var tier = FacialTier.htn

        var body: some View {
            ZStack {
                AppBackground()
                VStack(spacing: Spacing.section) {
                    WheelPicker(items: AgeOption.all, selection: $age, appearance: .age) { "\($0.years)" }
                    WheelPicker(items: FacialTier.allCases, selection: $tier, appearance: .targetRank) { $0.displayName }
                }
                .padding(.horizontal, Layout.horizontal)
            }
        }
    }
    return Wrapper()
}
