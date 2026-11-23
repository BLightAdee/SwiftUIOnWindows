// List.swift - List container
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct List<Content: View>: View {
    public typealias Body = Never

    internal let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("List uses custom layout") }
}

// MARK: - ForEach

public struct ForEach<Data, ID: Hashable, Content: View>: View {
    public typealias Body = Never

    internal let data: [Data]
    internal let id: KeyPath<Data, ID>
    internal let content: (Data) -> Content

    public init(_ data: [Data], id: KeyPath<Data, ID>,
                @ViewBuilder content: @escaping (Data) -> Content) {
        self.data = data
        self.id = id
        self.content = content
    }

    public var body: Never { fatalError("ForEach uses custom layout") }
}

extension ForEach where Data: Identifiable, ID == Data.ID {
    public init(_ data: [Data], @ViewBuilder content: @escaping (Data) -> Content) {
        self.data = data
        self.id = \.id
        self.content = content
    }
}

extension ForEach where Data == Range<Int>, ID == Int {
    public init(_ data: Range<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.data = Array(data)
        self.id = \.self
        self.content = content
    }
}

// MARK: - Section

public struct Section<Parent: View, Content: View, Footer: View>: View {
    public typealias Body = Never
    internal let header: Parent?
    internal let footer: Footer?
    internal let content: Content

    public var body: Never { fatalError("Section uses custom layout") }
}

extension Section where Parent == Text, Footer == EmptyView {
    public init(_ titleKey: String, @ViewBuilder content: () -> Content) {
        self.header = Text(titleKey)
        self.footer = nil
        self.content = content()
    }
}

extension Section where Parent == EmptyView, Footer == EmptyView {
    public init(@ViewBuilder content: () -> Content) {
        self.header = nil
        self.footer = nil
        self.content = content()
    }
}
