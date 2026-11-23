// Shapes.swift - Shape protocol and built-in shapes
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - Shape Protocol

public protocol Shape: View {
    func path(in rect: CGRect) -> Path
}

extension Shape {
    public var body: some View { ShapeView(shape: self) }
}

internal struct ShapeView<S: Shape>: View {
    public typealias Body = Never
    let shape: S
    public var body: Never { fatalError("ShapeView uses custom rendering") }
}

// MARK: - AnyShape

public struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    public init<S: Shape>(_ shape: S) { self._path = shape.path }
    public func path(in rect: CGRect) -> Path { _path(rect) }
}

// MARK: - Path

public struct Path: Sendable {
    internal enum Element: Sendable {
        case moveTo(CGPoint)
        case lineTo(CGPoint)
        case quadCurveTo(CGPoint, control: CGPoint)
        case curveTo(CGPoint, control1: CGPoint, control2: CGPoint)
        case closeSubpath
        case addRect(CGRect)
        case addRoundedRect(CGRect, cornerRadius: CGFloat)
        case addEllipse(CGRect)
        case addArc(center: CGPoint, radius: CGFloat, startAngle: Angle, endAngle: Angle, clockwise: Bool)
    }

    internal var elements: [Element] = []

    public init() {}

    public init(_ callback: (inout Path) -> Void) {
        callback(&self)
    }

    public mutating func move(to point: CGPoint) { elements.append(.moveTo(point)) }
    public mutating func addLine(to point: CGPoint) { elements.append(.lineTo(point)) }
    public mutating func addQuadCurve(to point: CGPoint, control: CGPoint) {
        elements.append(.quadCurveTo(point, control: control))
    }
    public mutating func addCurve(to point: CGPoint, control1: CGPoint, control2: CGPoint) {
        elements.append(.curveTo(point, control1: control1, control2: control2))
    }
    public mutating func closeSubpath() { elements.append(.closeSubpath) }
    public mutating func addRect(_ rect: CGRect) { elements.append(.addRect(rect)) }
    public mutating func addRoundedRect(in rect: CGRect, cornerSize: CGSize) {
        elements.append(.addRoundedRect(rect, cornerRadius: cornerSize.width))
    }
    public mutating func addEllipse(in rect: CGRect) { elements.append(.addEllipse(rect)) }
    public mutating func addArc(center: CGPoint, radius: CGFloat, startAngle: Angle,
                                endAngle: Angle, clockwise: Bool) {
        elements.append(.addArc(center: center, radius: radius,
                                startAngle: startAngle, endAngle: endAngle, clockwise: clockwise))
    }
}

// MARK: - Built-in Shapes

public struct Rectangle: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        var p = Path(); p.addRect(rect); return p
    }
}

public struct RoundedRectangle: Shape {
    public let cornerRadius: CGFloat
    public let style: RoundedCornerStyle

    public init(cornerRadius: CGFloat, style: RoundedCornerStyle = .circular) {
        self.cornerRadius = cornerRadius; self.style = style
    }

    public init(cornerSize: CGSize, style: RoundedCornerStyle = .circular) {
        self.cornerRadius = cornerSize.width; self.style = style
    }

    public func path(in rect: CGRect) -> Path {
        var p = Path(); p.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius)); return p
    }
}

public enum RoundedCornerStyle: Sendable { case circular, continuous }

public struct Circle: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        var p = Path(); p.addEllipse(in: rect); return p
    }
}

public struct Ellipse: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        var p = Path(); p.addEllipse(in: rect); return p
    }
}

public struct Capsule: Shape {
    public let style: RoundedCornerStyle
    public init(style: RoundedCornerStyle = .circular) { self.style = style }
    public func path(in rect: CGRect) -> Path {
        let r = min(rect.width, rect.height) / 2
        var p = Path(); p.addRoundedRect(in: rect, cornerSize: CGSize(width: r, height: r)); return p
    }
}

// MARK: - Shape Modifiers

extension Shape {
    public func fill(_ color: Color) -> some View {
        ModifiedContent(content: ShapeView(shape: self),
                        modifier: ForegroundColorModifier(color: color))
    }

    public func stroke(_ color: Color, lineWidth: CGFloat = 1) -> some View {
        ModifiedContent(content: ShapeView(shape: self),
                        modifier: BorderModifier(color: color, width: lineWidth))
    }
}
