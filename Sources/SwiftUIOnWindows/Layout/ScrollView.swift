// ScrollView.swift - ScrollView container
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct ScrollView<Content: View>: View {
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
}
