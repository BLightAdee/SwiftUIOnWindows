// Group.swift - Group and overlay containers
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - Group

public struct Group<Content: View>: View {
    public typealias Body = Never
    internal let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("Group uses custom layout") }
}

// MARK: - Form

public struct Form<Content: View>: View {
    public typealias Body = Never
    internal let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("Form uses custom layout") }
}
