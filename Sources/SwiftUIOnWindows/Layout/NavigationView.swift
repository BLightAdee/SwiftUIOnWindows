// NavigationView.swift - Navigation containers
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - NavigationView

public struct NavigationView<Content: View>: View {
    public typealias Body = Never
    internal let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("NavigationView uses custom layout") }
}

// MARK: - NavigationStack

public struct NavigationStack<Content: View>: View {
    public typealias Body = Never
    internal let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("NavigationStack uses custom layout") }
}

// MARK: - NavigationLink

public struct NavigationLink<Label: View, Destination: View>: View {
    public typealias Body = Never
    internal let destination: Destination
    internal let label: Label

    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }

    public var body: Never { fatalError("NavigationLink is a leaf view") }
}

extension NavigationLink where Label == Text {
    public init(_ titleKey: String, destination: Destination) {
        self.destination = destination
        self.label = Text(titleKey)
    }
}

extension NavigationLink where Destination == EmptyView {
    public init<P: Hashable>(value: P?, @ViewBuilder label: () -> Label) {
        self.destination = EmptyView()
        self.label = label()
    }
}

// MARK: - TabView

public struct TabView<Content: View>: View {
    public typealias Body = Never
    internal let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("TabView uses custom layout") }
}
