// Spacer.swift - Spacer and Divider views
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - Spacer

public struct Spacer: View {
    public typealias Body = Never

    internal let minLength: CGFloat?

    public init(minLength: CGFloat? = nil) {
        self.minLength = minLength
    }

    public var body: Never { fatalError("Spacer is a leaf view") }
}

// MARK: - Divider

public struct Divider: View {
    public typealias Body = Never

    public init() {}

    public var body: Never { fatalError("Divider is a leaf view") }
}
