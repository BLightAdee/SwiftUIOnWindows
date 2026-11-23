// Text.swift - Text view
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Text: View, Equatable {
    public typealias Body = Never

    internal let content: TextContent
    internal var font: Font?
    internal var foregroundColor: Color?
    internal var fontWeight: Font.Weight?
    internal var isItalic: Bool = false
    internal var isBold: Bool = false
    internal var isStrikethrough: Bool = false
    internal var isUnderline: Bool = false
    internal var lineLimit: Int?
    internal var multilineAlignment: TextAlignment = .leading

    internal enum TextContent: Equatable {
        case verbatim(String)
    }

    public init(_ content: String) { self.content = .verbatim(content) }
    public init(verbatim content: String) { self.content = .verbatim(content) }

    public var body: Never { fatalError("Text is a leaf view") }

    public var resolvedText: String {
        switch content { case .verbatim(let str): return str }
    }

    public func font(_ font: Font?) -> Text {
        var copy = self; copy.font = font; return copy
    }

    public func foregroundColor(_ color: Color?) -> Text {
        var copy = self; copy.foregroundColor = color; return copy
    }

    public func fontWeight(_ weight: Font.Weight?) -> Text {
        var copy = self; copy.fontWeight = weight; return copy
    }

    public func bold() -> Text {
        var copy = self; copy.isBold = true; return copy
    }

    public func italic() -> Text {
        var copy = self; copy.isItalic = true; return copy
    }

    public func strikethrough(_ active: Bool = true, color: Color? = nil) -> Text {
        var copy = self; copy.isStrikethrough = active; return copy
    }

    public func underline(_ active: Bool = true, color: Color? = nil) -> Text {
        var copy = self; copy.isUnderline = active; return copy
    }

    public func lineLimit(_ number: Int?) -> Text {
        var copy = self; copy.lineLimit = number; return copy
    }

    public func multilineTextAlignment(_ alignment: TextAlignment) -> Text {
        var copy = self; copy.multilineAlignment = alignment; return copy
    }

    internal var resolvedFont: Font {
        var f = font ?? .body
        if isBold { f = f.bold() }
        if isItalic { f = f.italic() }
        if let w = fontWeight { f = f.weight(w) }
        return f
    }

    public static func + (lhs: Text, rhs: Text) -> Text {
        Text(lhs.resolvedText + rhs.resolvedText)
    }
}

public enum TextAlignment: Sendable { case leading, center, trailing }
public enum TruncationMode: Sendable { case head, tail, middle }
