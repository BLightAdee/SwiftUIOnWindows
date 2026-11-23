// ScrollViewReader.swift - Programmatic scrolling
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct ScrollViewProxy: Sendable {
    public func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {}
}

public struct ScrollViewReader<Content: View>: View {
    public typealias Body = Never

    internal let content: (ScrollViewProxy) -> Content

    public init(@ViewBuilder content: @escaping (ScrollViewProxy) -> Content) {
        self.content = content
    }

    public var body: Never { fatalError("ScrollViewReader uses custom layout") }
}
