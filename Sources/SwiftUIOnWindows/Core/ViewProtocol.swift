// ViewProtocol.swift - Core View protocol and related types
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

#if canImport(WinSDK)
import WinSDK
#endif

// MARK: - View Protocol

/// The core protocol that all SwiftUI views must conform to.
public protocol View {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}

// MARK: - Never as View (leaf views)

extension Never: View {
    public typealias Body = Never
    public var body: Never {
        fatalError("Never should not have a body accessed")
    }
}

// MARK: - EmptyView

public struct EmptyView: View {
    public typealias Body = Never
    public init() {}
    public var body: Never {
        fatalError("EmptyView has no body")
    }
}

// MARK: - AnyView (type erasure)

public struct AnyView: View {
    public typealias Body = Never
    internal let _typeInfo: String

    public init<V: View>(_ view: V) {
        self._typeInfo = String(describing: type(of: view))
    }

    public var body: Never {
        fatalError("AnyView uses custom rendering")
    }
}

// MARK: - TupleView

public struct TupleView<T>: View {
    public typealias Body = Never
    public let value: T

    public init(_ value: T) {
        self.value = value
    }

    public var body: Never {
        fatalError("TupleView uses custom rendering")
    }
}

// MARK: - ConditionalContent

public struct ConditionalContent<TrueContent: View, FalseContent: View>: View {
    public typealias Body = Never
    internal enum Storage {
        case trueContent(TrueContent)
        case falseContent(FalseContent)
    }
    internal let storage: Storage

    public var body: Never {
        fatalError("ConditionalContent uses custom rendering")
    }
}

// MARK: - Optional View Conformance

extension Optional: View where Wrapped: View {
    public typealias Body = ConditionalContent<Wrapped, EmptyView>
    public var body: ConditionalContent<Wrapped, EmptyView> {
        switch self {
        case .some(let view):
            return ConditionalContent(storage: .trueContent(view))
        case .none:
            return ConditionalContent(storage: .falseContent(EmptyView()))
        }
    }
}
