// Stacks.swift - VStack, HStack, ZStack layout containers
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - VStack

public struct VStack<Content: View>: View {
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
}

// MARK: - HStack

public struct HStack<Content: View>: View {
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
}

// MARK: - ZStack

public struct ZStack<Content: View>: View {
    public typealias Body = Never

    internal let alignment: Alignment
    internal let content: Content

    public init(alignment: Alignment = .center,
                @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.content = content()
    }

    public var body: Never { fatalError("ZStack uses custom layout") }
}

// MARK: - LazyVStack

public struct LazyVStack<Content: View>: View {
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
}

// MARK: - LazyHStack

public struct LazyHStack<Content: View>: View {
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
}
