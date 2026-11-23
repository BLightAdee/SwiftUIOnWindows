// ScrollView.swift - ScrollView container
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct ScrollView<Content: View>: View, _RenderableInternal, _ChildrenProvider {
    public typealias Body = Never

    internal let axes: Axis.Set
    internal let showsIndicators: Bool
    internal let content: Content

    public init(_ axes: Axis.Set = .vertical,
                showsIndicators: Bool = true,
                @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
    }

    public var body: Never { fatalError("ScrollView uses custom layout") }

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

extension ScrollView: _LayoutSizableInternal {
    public func _layout(proposed: ProposedSize) -> CGSize {
        return LayoutEngine.layoutAny(content, proposed: proposed)
    }
}
