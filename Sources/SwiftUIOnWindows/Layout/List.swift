// List.swift - List container
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct List<Content: View>: View {
    public typealias Body = Never

    internal let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public init<SelectionValue: Hashable>(selection: Binding<SelectionValue?>?, @ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError("List uses custom layout") }
}

// MARK: - ListStyle

public protocol ListStyle {}
public struct SidebarListStyle: ListStyle, Sendable { public init() {} }
public struct InsetListStyle: ListStyle, Sendable { public init() {} }
public struct PlainListStyle: ListStyle, Sendable { public init() {} }

extension ListStyle where Self == SidebarListStyle {
    public static var sidebar: SidebarListStyle { SidebarListStyle() }
}
extension ListStyle where Self == InsetListStyle {
    public static var inset: InsetListStyle { InsetListStyle() }
}
extension ListStyle where Self == PlainListStyle {
    public static var plain: PlainListStyle { PlainListStyle() }
}

public extension View {
    func listStyle<S: ListStyle>(_ style: S) -> some View { self }
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

extension ForEach where Data == Int, ID == Int {
    public init(_ data: Range<Int>, id: KeyPath<Int, Int> = \.self, @ViewBuilder content: @escaping (Int) -> Content) {
        self.data = Array(data)
        self.id = id
        self.content = content
    }

    public init(_ data: ClosedRange<Int>, id: KeyPath<Int, Int> = \.self, @ViewBuilder content: @escaping (Int) -> Content) {
        self.data = Array(data)
        self.id = id
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

extension Section where Footer == EmptyView {
    public init(header: Parent, @ViewBuilder content: () -> Content) {
        self.header = header
        self.footer = nil
        self.content = content()
    }
}

extension Section {
    public init(header: Parent, footer: Footer, @ViewBuilder content: () -> Content) {
        self.header = header
        self.footer = footer
        self.content = content()
    }
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
