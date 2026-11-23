// LayoutEngine.swift - SwiftUI layout engine for view tree sizing
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

/// The layout engine computes sizes and positions for the view tree.
public enum LayoutEngine {
    /// Compute the ideal size of a view given a proposed size from its parent.
    public static func layout<V: View>(_ view: V, proposed: ProposedSize) -> CGSize {
        let proposedWidth = proposed.width ?? 300
        let proposedHeight = proposed.height ?? 200

        // Dispatch based on view type
        if let text = view as? Text {
            return layoutText(text, proposed: proposed)
        } else if view is Spacer {
            return CGSize(width: proposedWidth, height: proposedHeight)
        } else if view is Divider {
            return CGSize(width: proposedWidth, height: 1)
        } else if view is EmptyView {
            return .zero
        }

        // Default: use proposed size
        return CGSize(width: proposedWidth, height: proposedHeight)
    }

    /// Estimate the size needed for text rendering.
    private static func layoutText(_ text: Text, proposed: ProposedSize) -> CGSize {
        let font = text.resolvedFont
        let str = text.resolvedText
        // Approximate character metrics based on font size
        let charWidth = font.size * 0.6
        let lineHeight = font.size * 1.2

        let maxWidth = proposed.width ?? 10000
        let textWidth = CGFloat(str.count) * charWidth

        if textWidth <= maxWidth {
            return CGSize(width: textWidth, height: lineHeight)
        } else {
            let lines = Int(ceil(textWidth / maxWidth))
            let actualLines: Int
            if let limit = text.lineLimit {
                actualLines = min(lines, limit)
            } else {
                actualLines = lines
            }
            return CGSize(width: maxWidth, height: CGFloat(actualLines) * lineHeight)
        }
    }
}
