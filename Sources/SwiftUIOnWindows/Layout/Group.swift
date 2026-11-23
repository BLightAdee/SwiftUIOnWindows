// Group.swift - Group and overlay containers
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - Group

public struct Group<Content: View>: View, _ChildrenProvider, _RenderableInternal {
    public typealias Body = Never
    internal let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("Group uses custom layout") }

    public func _getChildren() -> [any View] {
        if let provider = content as? _ChildrenProvider {
            return provider._getChildren()
        }
        return [content]
    }

    public func _render(in context: inout RenderContext) {
        context.render(content)
    }
}

extension Group: _LayoutSizableInternal {
    public func _layout(proposed: ProposedSize) -> CGSize {
        return LayoutEngine.layoutAny(content, proposed: proposed)
    }
}

// MARK: - Form

public struct Form<Content: View>: View, _ChildrenProvider, _RenderableInternal, _LayoutSizableInternal {
    public typealias Body = Never
    internal let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("Form uses custom layout") }

    public func _getChildren() -> [any View] {
        if let provider = content as? _ChildrenProvider {
            return provider._getChildren()
        }
        return [content]
    }

    public func _render(in context: inout RenderContext) {
        context.render(content)
    }

    public func _layout(proposed: ProposedSize) -> CGSize {
        return LayoutEngine.layoutAny(content, proposed: proposed)
    }
}
