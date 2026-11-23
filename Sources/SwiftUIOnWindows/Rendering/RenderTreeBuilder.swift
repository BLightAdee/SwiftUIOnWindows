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

/// Represents an interactive region (e.g. button) that responds to click events.
public struct InteractiveTarget {
    public let rect: CGRect
    public let action: () -> Void

    public init(rect: CGRect, action: @escaping () -> Void) {
        self.rect = rect
        self.action = action
    }
}

/// Builds a flat list of render commands from a SwiftUI view tree.
public final class RenderTreeBuilder: @unchecked Sendable {
    public static let shared = RenderTreeBuilder()

    private var nodes: [RenderNode] = []
    private var clickTargets: [InteractiveTarget] = []

    private init() {}

    /// Clear render tree and interactive targets for new frame.
    public func beginFrame() {
        nodes.removeAll()
        clickTargets.removeAll()
        StateManager.shared.beginFrame()
    }

    /// Get all render nodes for the current frame.
    public func endFrame() -> [RenderNode] {
        return nodes
    }

    /// Append a render node directly.
    public func appendNode(_ node: RenderNode) {
        nodes.append(node)
    }

    /// Register an interactive click target region.
    public func registerClickTarget(rect: CGRect, action: @escaping () -> Void) {
        clickTargets.append(InteractiveTarget(rect: rect, action: action))
    }

    /// Process a mouse click at the given point (in window client coordinates).
    public func handleClick(at point: CGPoint) {
        // Reverse iterate so the top-most (most recently rendered) element receives the click
        for target in clickTargets.reversed() {
            if target.rect.contains(point) {
                print("SwiftUIOnWindows: Click target hit at \(point)")
                target.action()
                return
            }
        }
    }

    /// Render an existential `any View`.
    public func renderAnyView(_ view: any View, in context: inout RenderContext) {
        renderView(view, in: &context)
    }

    /// Render any view by dispatching on its type.
    public func renderView<V: View>(_ view: V, in context: inout RenderContext) {
        // 1. Check if view conforms to internal renderable protocol (containers, modifiers, buttons, etc.)
        if let renderable = view as? _RenderableInternal {
            renderable._render(in: &context)
            return
        }

        // 2. Text leaf view
        if let text = view as? Text {
            renderText(text, in: context)
            return
        }

        // 3. Color fill
        if let color = view as? Color {
            let rect = CGRect(origin: context.origin, size: context.size)
            nodes.append(.rect(color, rect, context.cornerRadius))
            return
        }

        // 4. EmptyView / Spacer
        if view is EmptyView { return }
        if view is Spacer { return }

        // 5. Divider
        if view is Divider {
            let rect = CGRect(origin: context.origin,
                              size: CGSize(width: context.size.width, height: 1))
            nodes.append(.rect(Color.gray.opacity(0.3), rect, 0))
            return
        }

        // 6. For all custom views, recurse into body
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
