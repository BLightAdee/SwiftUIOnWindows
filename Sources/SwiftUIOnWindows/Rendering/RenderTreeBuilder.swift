// RenderTreeBuilder.swift - Builds a render tree from SwiftUI views
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

/// Represents a rendered element in the view tree.
public enum RenderNode {
    case text(String, Font, Color, CGRect)
    case rect(Color, CGRect, CGFloat) // color, rect, cornerRadius
    case border(Color, CGRect, CGFloat, CGFloat) // color, rect, cornerRadius, width
    case group([RenderNode])
    case empty
}

/// Builds a flat list of render commands from a SwiftUI view tree.
public final class RenderTreeBuilder: @unchecked Sendable {
    public static let shared = RenderTreeBuilder()

    private var nodes: [RenderNode] = []

    private init() {}

    /// Clear render tree for new frame.
    public func beginFrame() {
        nodes.removeAll()
    }

    /// Get all render nodes for the current frame.
    public func endFrame() -> [RenderNode] {
        return nodes
    }

    /// Render any view by dispatching on its type.
    public func renderView<V: View>(_ view: V, in context: inout RenderContext) {
        // Text
        if let text = view as? Text {
            renderText(text, in: context)
            return
        }

        // Color (as background fill)
        if let color = view as? Color {
            let rect = CGRect(origin: context.origin, size: context.size)
            nodes.append(.rect(color, rect, 0))
            return
        }

        // EmptyView
        if view is EmptyView { return }

        // Spacer
        if view is Spacer { return }

        // Divider
        if view is Divider {
            let rect = CGRect(origin: context.origin,
                              size: CGSize(width: context.size.width, height: 1))
            nodes.append(.rect(Color.gray.opacity(0.3), rect, 0))
            return
        }

        // For all other views, recurse into body
        if !(V.Body.self == Never.self) {
            var childCtx = context
            childCtx.render(view.body)
        }
    }

    private func renderText(_ text: Text, in context: RenderContext) {
        let font = text.resolvedFont
        let color = text.foregroundColor ?? context.foregroundColor
        let rect = CGRect(origin: context.origin, size: context.size)
        nodes.append(.text(text.resolvedText, font, color, rect))
    }
}
