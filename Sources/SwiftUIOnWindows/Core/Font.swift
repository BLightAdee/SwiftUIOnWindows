// Font.swift - Font type with macOS-style typography
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Font: Equatable, Sendable {
    public var name: String
    public var size: CGFloat
    public var weight: Weight
    public var design: Design
    public var isItalic: Bool

    internal init(name: String = "Segoe UI", size: CGFloat = 13, weight: Weight = .regular,
                  design: Design = .default, isItalic: Bool = false) {
        self.name = name; self.size = size; self.weight = weight
        self.design = design; self.isItalic = isItalic
    }

    // Text Styles (macOS sizing)
    public static let largeTitle = Font(size: 26, weight: .regular)
    public static let title = Font(size: 22, weight: .regular)
    public static let title2 = Font(size: 17, weight: .regular)
    public static let title3 = Font(size: 15, weight: .regular)
    public static let headline = Font(size: 13, weight: .semibold)
    public static let subheadline = Font(size: 11, weight: .regular)
    public static let body = Font(size: 13, weight: .regular)
    public static let callout = Font(size: 12, weight: .regular)
    public static let footnote = Font(size: 10, weight: .regular)
    public static let caption = Font(size: 10, weight: .regular)
    public static let caption2 = Font(size: 10, weight: .medium)

    public static func system(size: CGFloat, weight: Weight = .regular, design: Design = .default) -> Font {
        Font(size: size, weight: weight, design: design)
    }

    public static func custom(_ name: String, size: CGFloat) -> Font {
        Font(name: name, size: size)
    }

    public func weight(_ weight: Weight) -> Font {
        var copy = self; copy.weight = weight; return copy
    }

    public func italic() -> Font {
        var copy = self; copy.isItalic = true; return copy
    }

    public func bold() -> Font {
        var copy = self; copy.weight = .bold; return copy
    }

    public func monospaced() -> Font {
        var copy = self
        copy.design = .monospaced
        return copy
    }

    public func monospacedDigit() -> Font { return self }

    public enum Weight: Int, Equatable, Sendable {
        case ultraLight = 100, thin = 200, light = 300, regular = 400
        case medium = 500, semibold = 600, bold = 700, heavy = 800, black = 900
    }

    public enum Design: Sendable {
        case `default`, rounded, serif, monospaced
    }

    internal var win32FontName: String {
        switch design {
        case .monospaced: return "Cascadia Code"
        case .serif: return "Cambria"
        case .rounded, .default: return name
        }
    }
}
