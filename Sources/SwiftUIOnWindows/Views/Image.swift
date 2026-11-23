// Image.swift - Image view
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Image: View, Equatable {
    public typealias Body = Never

    internal let source: ImageSource
    internal var renderingMode: TemplateRenderingMode?
    internal var isResizable: Bool = false
    internal var capInsets: EdgeInsets = EdgeInsets()
    internal var resizingMode: ResizingMode = .stretch

    internal enum ImageSource: Equatable {
        case named(String)
        case systemName(String)
    }

    public init(_ name: String) { self.source = .named(name) }
    public init(systemName: String) { self.source = .systemName(systemName) }

    public var body: Never { fatalError("Image is a leaf view") }

    public func renderingMode(_ mode: TemplateRenderingMode?) -> Image {
        var copy = self; copy.renderingMode = mode; return copy
    }

    public func resizable(capInsets: EdgeInsets = EdgeInsets(),
                          resizingMode: ResizingMode = .stretch) -> Image {
        var copy = self; copy.isResizable = true; copy.capInsets = capInsets
        copy.resizingMode = resizingMode; return copy
    }

    public enum TemplateRenderingMode: Sendable { case original, template }
    public enum ResizingMode: Sendable { case stretch, tile }

    internal var mdl2Character: String {
        switch source {
        case .systemName(let name): return SFSymbolsMapper.map(name)
        case .named: return ""
        }
    }
}

internal enum SFSymbolsMapper {
    static func map(_ name: String) -> String {
        let m: [String: String] = [
            "plus": "\u{E710}", "minus": "\u{E738}", "xmark": "\u{E711}",
            "checkmark": "\u{E73E}", "chevron.right": "\u{E76C}",
            "chevron.left": "\u{E76B}", "magnifyingglass": "\u{E721}",
            "gear": "\u{E713}", "trash": "\u{E74D}", "star": "\u{E734}",
            "star.fill": "\u{E735}", "heart": "\u{EB51}", "heart.fill": "\u{EB52}",
            "person": "\u{E77B}", "house": "\u{E80F}", "bell": "\u{EA8F}",
            "envelope": "\u{E715}", "pencil": "\u{E70F}", "play": "\u{E768}",
            "pause": "\u{E769}", "circle": "\u{EA3A}", "square": "\u{E739}",
            "ellipsis": "\u{E712}", "line.3.horizontal": "\u{E700}",
            "arrow.left": "\u{E72B}", "arrow.right": "\u{E72A}",
        ]
        return m[name] ?? "\u{E9CE}"
    }
}
