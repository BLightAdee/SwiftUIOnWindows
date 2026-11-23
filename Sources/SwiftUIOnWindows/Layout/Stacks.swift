// Stacks.swift - VStack, HStack, ZStack layout containers
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - VStack

public struct VStack<Content: View>: View, _ChildrenProvider, _RenderableInternal, _LayoutSizableInternal {
    public typealias Body = Never

    internal let alignment: HorizontalAlignment
    internal let spacing: CGFloat?
    internal let content: Content

    public init(alignment: HorizontalAlignment = .center,
                spacing: CGFloat? = nil,
                @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: Never { fatalError("VStack uses custom layout") }

    public func _getChildren() -> [any View] {
        if let provider = content as? _ChildrenProvider {
            return provider._getChildren()
        }
        return [content]
    }

    public func _layout(proposed: ProposedSize) -> CGSize {
        let children = _getChildren()
        let spacing = self.spacing ?? 8.0
        var totalHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        var spacerCount = 0

        for child in children {
            if child is Spacer {
                spacerCount += 1
            } else {
                let size = LayoutEngine.layoutAny(child, proposed: ProposedSize(width: proposed.width, height: nil))
                maxWidth = max(maxWidth, size.width)
                totalHeight += size.height
            }
        }
        let totalSpacings = CGFloat(max(0, children.count - 1)) * spacing
        totalHeight += totalSpacings

        if spacerCount > 0, let pHeight = proposed.height {
            totalHeight = max(totalHeight, pHeight)
        }
        return CGSize(width: proposed.width ?? maxWidth, height: totalHeight)
    }

    public func _render(in context: inout RenderContext) {
        let children = _getChildren()
        let spacing = self.spacing ?? 8.0
        var currentY: CGFloat = 0

        var measuredChildren: [(view: any View, size: CGSize)] = []
        var totalFixedHeights: CGFloat = 0
        var spacerCount = 0

        for child in children {
            if child is Spacer {
                spacerCount += 1
                measuredChildren.append((child, .zero))
            } else {
                let proposed = ProposedSize(width: context.size.width, height: nil)
                let size = LayoutEngine.layout(child, proposed: proposed)
                measuredChildren.append((child, size))
                totalFixedHeights += size.height
            }
        }

        let totalSpacings = CGFloat(max(0, children.count - 1)) * spacing
        let remainingHeight = max(0, context.size.height - totalFixedHeights - totalSpacings)
        let spacerHeight = spacerCount > 0 ? remainingHeight / CGFloat(spacerCount) : 0

        for item in measuredChildren {
            let child = item.view
            let childHeight = (child is Spacer) ? spacerHeight : item.size.height
            let childWidth = min(item.size.width, context.size.width)

            var childX: CGFloat = 0
            switch alignment {
            case .leading:
                childX = 0
            case .center:
                childX = (context.size.width - childWidth) / 2
            case .trailing:
                childX = context.size.width - childWidth
            }

            if !(child is Spacer) {
                var childCtx = context.child(
                    offset: CGPoint(x: childX, y: currentY),
                    size: CGSize(width: childWidth, height: childHeight)
                )
                childCtx.renderAny(child)
            }

            currentY += childHeight + spacing
        }
    }
}

// MARK: - HStack

public struct HStack<Content: View>: View, _ChildrenProvider, _RenderableInternal, _LayoutSizableInternal {
    public typealias Body = Never

    internal let alignment: VerticalAlignment
    internal let spacing: CGFloat?
    internal let content: Content

    public init(alignment: VerticalAlignment = .center,
                spacing: CGFloat? = nil,
                @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: Never { fatalError("HStack uses custom layout") }

    public func _getChildren() -> [any View] {
        if let provider = content as? _ChildrenProvider {
            return provider._getChildren()
        }
        return [content]
    }

    public func _layout(proposed: ProposedSize) -> CGSize {
        let children = _getChildren()
        let spacing = self.spacing ?? 8.0
        var totalWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        var spacerCount = 0

        for child in children {
            if child is Spacer {
                spacerCount += 1
            } else {
                let size = LayoutEngine.layoutAny(child, proposed: ProposedSize(width: nil, height: proposed.height))
                maxHeight = max(maxHeight, size.height)
                totalWidth += size.width
            }
        }
        let totalSpacings = CGFloat(max(0, children.count - 1)) * spacing
        totalWidth += totalSpacings

        if spacerCount > 0, let pWidth = proposed.width {
            totalWidth = max(totalWidth, pWidth)
        }
        return CGSize(width: totalWidth, height: proposed.height ?? maxHeight)
    }

    public func _render(in context: inout RenderContext) {
        let children = _getChildren()
        let spacing = self.spacing ?? 8.0
        var currentX: CGFloat = 0

        var measuredChildren: [(view: any View, size: CGSize)] = []
        var totalFixedWidths: CGFloat = 0
        var spacerCount = 0

        for child in children {
            if child is Spacer {
                spacerCount += 1
                measuredChildren.append((child, .zero))
            } else {
                let proposed = ProposedSize(width: nil, height: context.size.height)
                let size = LayoutEngine.layout(child, proposed: proposed)
                measuredChildren.append((child, size))
                totalFixedWidths += size.width
            }
        }

        let totalSpacings = CGFloat(max(0, children.count - 1)) * spacing
        let remainingWidth = max(0, context.size.width - totalFixedWidths - totalSpacings)
        let spacerWidth = spacerCount > 0 ? remainingWidth / CGFloat(spacerCount) : 0

        for item in measuredChildren {
            let child = item.view
            let childWidth = (child is Spacer) ? spacerWidth : item.size.width
            let childHeight = min(item.size.height, context.size.height)

            var childY: CGFloat = 0
            switch alignment {
            case .top:
                childY = 0
            case .center:
                childY = (context.size.height - childHeight) / 2
            case .bottom:
                childY = context.size.height - childHeight
            }

            if !(child is Spacer) {
                var childCtx = context.child(
                    offset: CGPoint(x: currentX, y: childY),
                    size: CGSize(width: childWidth, height: childHeight)
                )
                childCtx.renderAny(child)
            }

            currentX += childWidth + spacing
        }
    }
}

// MARK: - ZStack

public struct ZStack<Content: View>: View, _ChildrenProvider, _RenderableInternal, _LayoutSizableInternal {
    public typealias Body = Never

    internal let alignment: Alignment
    internal let content: Content

    public init(alignment: Alignment = .center,
                @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.content = content()
    }

    public var body: Never { fatalError("ZStack uses custom layout") }

    public func _getChildren() -> [any View] {
        if let provider = content as? _ChildrenProvider {
            return provider._getChildren()
        }
        return [content]
    }

    public func _layout(proposed: ProposedSize) -> CGSize {
        let children = _getChildren()
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        for child in children {
            let size = LayoutEngine.layoutAny(child, proposed: proposed)
            maxWidth = max(maxWidth, size.width)
            maxHeight = max(maxHeight, size.height)
        }
        return CGSize(width: proposed.width ?? maxWidth, height: proposed.height ?? maxHeight)
    }

    public func _render(in context: inout RenderContext) {
        for child in _getChildren() {
            var childCtx = context
            childCtx.renderAny(child)
        }
    }
}

// MARK: - LazyVStack

public struct LazyVStack<Content: View>: View, _ChildrenProvider, _RenderableInternal {
    public typealias Body = Never

    internal let alignment: HorizontalAlignment
    internal let spacing: CGFloat?
    internal let content: Content

    public init(alignment: HorizontalAlignment = .center,
                spacing: CGFloat? = nil,
                @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: Never { fatalError("LazyVStack uses custom layout") }

    public func _getChildren() -> [any View] {
        if let provider = content as? _ChildrenProvider {
            return provider._getChildren()
        }
        return [content]
    }

    public func _render(in context: inout RenderContext) {
        let vstack = VStack(alignment: alignment, spacing: spacing) { content }
        var childCtx = context
        vstack._render(in: &childCtx)
    }
}

// MARK: - LazyHStack

public struct LazyHStack<Content: View>: View, _ChildrenProvider, _RenderableInternal {
    public typealias Body = Never

    internal let alignment: VerticalAlignment
    internal let spacing: CGFloat?
    internal let content: Content

    public init(alignment: VerticalAlignment = .center,
                spacing: CGFloat? = nil,
                @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: Never { fatalError("LazyHStack uses custom layout") }

    public func _getChildren() -> [any View] {
        if let provider = content as? _ChildrenProvider {
            return provider._getChildren()
        }
        return [content]
    }

    public func _render(in context: inout RenderContext) {
        let hstack = HStack(alignment: alignment, spacing: spacing) { content }
        var childCtx = context
        hstack._render(in: &childCtx)
    }
}
