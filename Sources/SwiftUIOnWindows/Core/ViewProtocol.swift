// ViewProtocol.swift - Core View protocol and related types
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation
#if canImport(WinSDK)
import WinSDK
#endif

// MARK: - View Protocol

/// The core protocol that all SwiftUI views must conform to.
public protocol View {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}

// MARK: - Internal Rendering & Hierarchy Protocols

/// Internal protocol for views that know how to render themselves directly into a RenderContext.
public protocol _RenderableInternal {
    func _render(in context: inout RenderContext)
}

/// Internal protocol for containers that can unpack their child views as a flat list.
public protocol _ChildrenProvider {
    func _getChildren() -> [any View]
}

/// Internal protocol for views that know how to calculate their own size given a proposed size.
public protocol _LayoutSizableInternal {
    func _layout(proposed: ProposedSize) -> CGSize
}

// MARK: - Never as View (leaf views)

extension Never: View {
    public typealias Body = Never
    public var body: Never {
        fatalError("Never should not have a body accessed")
    }
}

// MARK: - EmptyView

public struct EmptyView: View, _RenderableInternal, _LayoutSizableInternal {
    public typealias Body = Never
    public init() {}
    public var body: Never {
        fatalError("EmptyView has no body")
    }
    public func _render(in context: inout RenderContext) {
        // Nothing to render
    }
    public func _layout(proposed: ProposedSize) -> CGSize {
        return .zero
    }
}

// MARK: - AnyView (type erasure)

public struct AnyView: View, _RenderableInternal, _ChildrenProvider, _LayoutSizableInternal {
    public typealias Body = Never
    internal let _typeInfo: String
    internal let _renderClosure: (inout RenderContext) -> Void
    internal let _underlying: any View

    public init<V: View>(_ view: V) {
        self._typeInfo = String(describing: type(of: view))
        self._underlying = view
        self._renderClosure = { ctx in
            ctx.render(view)
        }
    }

    public var body: Never {
        fatalError("AnyView uses custom rendering")
    }

    public func _render(in context: inout RenderContext) {
        _renderClosure(&context)
    }

    public func _getChildren() -> [any View] {
        if let provider = _underlying as? _ChildrenProvider {
            return provider._getChildren()
        }
        return [_underlying]
    }

    public func _layout(proposed: ProposedSize) -> CGSize {
        return LayoutEngine.layoutAny(_underlying, proposed: proposed)
    }
}

// MARK: - TupleView

public struct TupleView<T>: View, _ChildrenProvider, _RenderableInternal, _LayoutSizableInternal {
    public typealias Body = Never
    public let value: T

    public init(_ value: T) {
        self.value = value
    }

    public var body: Never {
        fatalError("TupleView uses custom rendering")
    }

    public func _getChildren() -> [any View] {
        let mirror = Mirror(reflecting: value)
        var result: [any View] = []
        for child in mirror.children {
            if let v = child.value as? any View {
                if let provider = v as? _ChildrenProvider {
                    result.append(contentsOf: provider._getChildren())
                } else {
                    result.append(v)
                }
            }
        }
        return result
    }

    public func _render(in context: inout RenderContext) {
        for child in _getChildren() {
            context.renderAny(child)
        }
    }

    public func _layout(proposed: ProposedSize) -> CGSize {
        let children = _getChildren()
        var maxWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        for child in children {
            let size = LayoutEngine.layoutAny(child, proposed: proposed)
            maxWidth = max(maxWidth, size.width)
            totalHeight += size.height
        }
        return CGSize(width: proposed.width ?? maxWidth, height: totalHeight)
    }
}

// MARK: - ConditionalContent

public struct ConditionalContent<TrueContent: View, FalseContent: View>: View, _ChildrenProvider, _RenderableInternal, _LayoutSizableInternal {
    public typealias Body = Never
    internal enum Storage {
        case trueContent(TrueContent)
        case falseContent(FalseContent)
    }
    internal let storage: Storage

    public var body: Never {
        fatalError("ConditionalContent uses custom rendering")
    }

    public func _getChildren() -> [any View] {
        switch storage {
        case .trueContent(let c):
            if let provider = c as? _ChildrenProvider { return provider._getChildren() }
            return [c]
        case .falseContent(let c):
            if let provider = c as? _ChildrenProvider { return provider._getChildren() }
            return [c]
        }
    }

    public func _render(in context: inout RenderContext) {
        for child in _getChildren() {
            context.renderAny(child)
        }
    }

    public func _layout(proposed: ProposedSize) -> CGSize {
        switch storage {
        case .trueContent(let c):
            return LayoutEngine.layoutAny(c, proposed: proposed)
        case .falseContent(let c):
            return LayoutEngine.layoutAny(c, proposed: proposed)
        }
    }
}

// MARK: - Optional View Conformance

extension Optional: View, _ChildrenProvider, _RenderableInternal, _LayoutSizableInternal where Wrapped: View {
    public typealias Body = ConditionalContent<Wrapped, EmptyView>
    public var body: ConditionalContent<Wrapped, EmptyView> {
        switch self {
        case .some(let view):
            return ConditionalContent(storage: .trueContent(view))
        case .none:
            return ConditionalContent(storage: .falseContent(EmptyView()))
        }
    }

    public func _getChildren() -> [any View] {
        switch self {
        case .some(let v):
            if let provider = v as? _ChildrenProvider { return provider._getChildren() }
            return [v]
        case .none:
            return []
        }
    }

    public func _render(in context: inout RenderContext) {
        if let v = self {
            context.render(v)
        }
    }

    public func _layout(proposed: ProposedSize) -> CGSize {
        switch self {
        case .some(let v):
            return LayoutEngine.layoutAny(v, proposed: proposed)
        case .none:
            return .zero
        }
    }
}
