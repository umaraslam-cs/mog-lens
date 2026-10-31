import SwiftUI

/// Fitting the design's absolute layouts into a container shorter than the
/// phone they were drawn for.
///
/// Onboarding, Scan and Analysing place their content at fixed offsets from the
/// top safe area — the prototype's own numbers. Two containers are shorter than
/// the phone those numbers assume: an iPhone-only app on iPad, which iPadOS
/// gives a 375x647pt compatibility window, and the 4.7-inch iPhones still on
/// iOS 17. In both, the last rows ended up under the pinned CTA. Making the
/// screens scroll put them in reach but left them looking cropped at rest,
/// which is what App Review screenshots — twice now, under Guideline 4.
///
/// Two pieces do the fitting: ``DesignOffsetStack`` closes the gaps between
/// blocks, and ``Layout/designFit(slot:design:)`` shrinks the fixed-height
/// imagery that no gap can make room for. Both are inert at the design's own
/// height, so every supported iPhone renders exactly as before.
extension Layout {
    /// How much of the design's height the container actually has, capped at 1.
    ///
    /// Multiplies the fixed heights the design gives its imagery — the halo
    /// portrait, the landmark frame, the analysis photo. Offsets are left to
    /// ``DesignOffsetStack``, which can close a gap but cannot shrink a photo.
    static func designFit(slot: CGFloat, design: CGFloat) -> CGFloat {
        guard slot > 0, design > 0 else { return 1 }
        return min(1, slot / design)
    }
}

/// Stacks blocks at the design's absolute offsets from the top, and closes the
/// gaps between them — never the blocks themselves — when the height available
/// is less than those offsets need.
///
/// At or above the design's own height every block sits exactly where the
/// prototype put it. Below it, the offsets shrink by as much as it takes, with
/// each block still kept ``minimumGap`` clear of the one above: blocks can move
/// up but they can never run into each other, which a plain scale factor on the
/// offsets cannot promise — the copy standing at those offsets keeps its own
/// height whatever happens to the space above it.
///
/// ``available`` is passed in rather than read from the proposal because these
/// stacks live inside scroll views, which propose unbounded height. The owning
/// screen measures its slot and hands the number down.
///
/// Conforms to `SwiftUI.Layout` spelled in full — ``Layout`` in this app is the
/// design system's own geometry namespace.
struct DesignOffsetStack: SwiftUI.Layout {
    /// One design offset per block, top of the stack to top of the block.
    let offsets: [CGFloat]
    /// Height the stack has to fit into, or `nil` to use the design's offsets
    /// as they are.
    var available: CGFloat?
    var minimumGap: CGFloat = Spacing.m

    struct Cache {
        var heights: [CGFloat] = []
        var positions: [CGFloat] = []
    }

    func makeCache(subviews: LayoutSubviews) -> Cache { Cache() }

    func sizeThatFits(proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout Cache) -> CGSize {
        let width = proposal.width ?? 0
        cache.heights = subviews.map {
            $0.sizeThatFits(ProposedViewSize(width: width, height: nil)).height
        }
        cache.positions = positions(heights: cache.heights)
        let bottom = zip(cache.positions, cache.heights).map(+).max() ?? 0
        return CGSize(width: width, height: bottom)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: LayoutSubviews,
        cache: inout Cache
    ) {
        for (index, subview) in subviews.enumerated() where index < cache.positions.count {
            subview.place(
                at: CGPoint(x: bounds.minX, y: bounds.minY + cache.positions[index]),
                proposal: ProposedViewSize(width: bounds.width, height: cache.heights[index])
            )
        }
    }

    /// The offsets as laid out, squeezed only as far as the available height
    /// requires.
    ///
    /// The squeeze factor is found by bisection rather than solved for: each
    /// block's floor depends on the block above it, so the height the stack
    /// ends up at is not a straight line in the factor.
    private func positions(heights: [CGFloat]) -> [CGFloat] {
        let natural = placed(heights: heights, scale: 1)
        guard let available, available > 0,
              let naturalBottom = zip(natural, heights).map(+).max(),
              naturalBottom > available
        else { return natural }

        var low: CGFloat = 0
        var high: CGFloat = 1
        var best = placed(heights: heights, scale: 0)
        for _ in 0..<20 {
            let mid = (low + high) / 2
            let candidate = placed(heights: heights, scale: mid)
            let bottom = zip(candidate, heights).map(+).max() ?? 0
            if bottom <= available {
                best = candidate
                low = mid
            } else {
                high = mid
            }
        }
        return best
    }

    private func placed(heights: [CGFloat], scale: CGFloat) -> [CGFloat] {
        var result: [CGFloat] = []
        result.reserveCapacity(offsets.count)
        for (index, offset) in offsets.enumerated() {
            guard index > 0 else {
                result.append(offset * scale)
                continue
            }
            let floor = result[index - 1] + heights[index - 1] + minimumGap
            result.append(max(offset * scale, floor))
        }
        return result
    }
}

/// Carries a laid-out height up the view tree.
struct HeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

extension View {
    /// Reports the height this view was laid out at.
    ///
    /// Read from a `background`, so it measures the frame the parent gave the
    /// view rather than anything the view's own content asks for. A scroll view
    /// fills the space left over whatever it holds, so nothing here can feed
    /// back into the offsets it goes on to size.
    func measureHeight(_ onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: HeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
    }
}
