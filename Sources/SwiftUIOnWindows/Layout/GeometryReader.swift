// GeometryReader.swift - GeometryReader
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - GeometryProxy

public struct GeometryProxy {
    public let size: CGSize
    public let safeAreaInsets: EdgeInsets

    public init(size: CGSize, safeAreaInsets: EdgeInsets = EdgeInsets()) {
        self.size = size
        self.safeAreaInsets = safeAreaInsets
    }

    public func frame(in coordinateSpace: CoordinateSpace) -> CGRect {
        CGRect(origin: .zero, size: size)
    }
}

public enum CoordinateSpace {
    case local
    case global
    case named(AnyHashable)
}

// MARK: - GeometryReader

public struct GeometryReader<Content: View>: View {
    public typealias Body = Never

    internal let content: (GeometryProxy) -> Content

    public init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }

    public var body: Never { fatalError("GeometryReader uses custom layout") }
}
