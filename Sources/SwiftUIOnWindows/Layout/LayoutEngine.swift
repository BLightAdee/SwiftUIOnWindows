// LayoutEngine.swift - SwiftUI layout engine for view tree sizing
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

/// The layout engine computes sizes and positions for the view tree.
public enum LayoutEngine {
    /// Compute the ideal size of a view given a proposed size from its parent.
    public static func layout<V: View>(_ view: V, proposed: ProposedSize) -> CGSize {
        // 1. Check if view conforms to internal sizing protocol
        if let sizable = view as? _LayoutSizableInternal {
            return sizable._layout(proposed: proposed)
        }

        // 2. Text
        if let text = view as? Text {
            return layoutText(text, proposed: proposed)
        }

        // 3. Leaf views
        if view is Spacer {
            return CGSize(width: proposed.width ?? 0, height: proposed.height ?? 0)
        }
        if view is Divider {
            return CGSize(width: proposed.width ?? 100, height: 1)
        }
        if view is EmptyView {
            return .zero
        }

        // 4. Custom views with body
        if !(V.Body.self == Never.self) {
            return layout(view.body, proposed: proposed)
        }

        // 5. Default fallback: use proposed dimensions or reasonable defaults
        let proposedWidth = proposed.width ?? 300
        let proposedHeight = proposed.height ?? 200
        return CGSize(width: proposedWidth, height: proposedHeight)
    }

    /// Compute the ideal size of an existential `any View`.
    public static func layoutAny(_ view: any View, proposed: ProposedSize) -> CGSize {
        return layout(view, proposed: proposed)
    }

    /// Estimate the size needed for text rendering.
    public static func layoutText(_ text: Text, proposed: ProposedSize) -> CGSize {
        let font = text.resolvedFont
        let str = text.resolvedText
        // Approximate character metrics based on font size
        let charWidth = font.size * 0.6
        let lineHeight = font.size * 1.3

        let maxWidth = proposed.width ?? 10000
        let lines = str.components(separatedBy: "\n")
        var computedMaxWidth: CGFloat = 0
        var totalLines = 0

        for line in lines {
            let lineTextWidth = CGFloat(line.count) * charWidth
            if lineTextWidth <= maxWidth {
                computedMaxWidth = max(computedMaxWidth, lineTextWidth)
                totalLines += 1
            } else {
                let wrapped = Int(ceil(lineTextWidth / maxWidth))
                computedMaxWidth = maxWidth
                totalLines += max(1, wrapped)
            }
        }

        if let limit = text.lineLimit {
            totalLines = min(totalLines, limit)
        }

        let computedHeight = max(lineHeight, CGFloat(totalLines) * lineHeight)
        return CGSize(width: max(charWidth, computedMaxWidth), height: computedHeight)
    }
}
