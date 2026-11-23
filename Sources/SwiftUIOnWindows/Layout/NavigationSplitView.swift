// NavigationSplitView.swift - Multi-column navigation
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct NavigationSplitView<Sidebar: View, Content: View, Detail: View>: View {
    public typealias Body = Never

    internal let sidebar: Sidebar
    internal let content: Content?
    internal let detail: Detail

    public init(@ViewBuilder sidebar: () -> Sidebar, @ViewBuilder detail: () -> Detail) where Content == EmptyView {
        self.sidebar = sidebar()
        self.content = nil
        self.detail = detail()
    }

    public init(@ViewBuilder sidebar: () -> Sidebar, @ViewBuilder content: () -> Content, @ViewBuilder detail: () -> Detail) {
        self.sidebar = sidebar()
        self.content = content()
        self.detail = detail()
    }

    public var body: Never { fatalError("NavigationSplitView uses custom layout") }
}
