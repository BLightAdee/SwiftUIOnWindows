// Color.swift - Color type with macOS-style system colors
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Color: Equatable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var opacity: Double

    public init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red; self.green = green; self.blue = blue; self.opacity = opacity
    }

    public init(_ colorSpace: ColorSpace = .sRGB, red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red; self.green = green; self.blue = blue; self.opacity = opacity
    }

    public init(white: Double, opacity: Double = 1.0) {
        self.red = white; self.green = white; self.blue = white; self.opacity = opacity
    }

    public enum ColorSpace: Sendable { case sRGB, sRGBLinear, displayP3 }

    // macOS system colors
    public static let clear = Color(red: 0, green: 0, blue: 0, opacity: 0)
    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let white = Color(red: 1, green: 1, blue: 1)
    public static let gray = Color(red: 0.557, green: 0.557, blue: 0.576)
    public static let red = Color(red: 1.0, green: 0.231, blue: 0.188)
    public static let orange = Color(red: 1.0, green: 0.584, blue: 0.0)
    public static let yellow = Color(red: 1.0, green: 0.839, blue: 0.039)
    public static let green = Color(red: 0.196, green: 0.843, blue: 0.294)
    public static let mint = Color(red: 0.0, green: 0.780, blue: 0.745)
    public static let teal = Color(red: 0.353, green: 0.784, blue: 0.980)
    public static let cyan = Color(red: 0.392, green: 0.824, blue: 1.0)
    public static let blue = Color(red: 0.0, green: 0.478, blue: 1.0)
    public static let indigo = Color(red: 0.345, green: 0.337, blue: 0.839)
    public static let purple = Color(red: 0.686, green: 0.322, blue: 0.871)
    public static let pink = Color(red: 1.0, green: 0.176, blue: 0.333)
    public static let brown = Color(red: 0.635, green: 0.518, blue: 0.369)
    public static let primary = Color(red: 0.0, green: 0.0, blue: 0.0)
    public static let secondary = Color(red: 0.557, green: 0.557, blue: 0.576)
    public static let accentColor = Color(red: 0.0, green: 0.478, blue: 1.0)

    public func opacity(_ opacity: Double) -> Color {
        var copy = self; copy.opacity = opacity; return copy
    }

    public var colorRef: UInt32 {
        let r = UInt32(max(0, min(1, red)) * 255)
        let g = UInt32(max(0, min(1, green)) * 255)
        let b = UInt32(max(0, min(1, blue)) * 255)
        return r | (g << 8) | (b << 16)
    }
}

extension Color: View {
    public typealias Body = Never
    public var body: Never { fatalError("Color as View uses custom rendering") }
}

public enum ColorScheme: Sendable { case light, dark }
