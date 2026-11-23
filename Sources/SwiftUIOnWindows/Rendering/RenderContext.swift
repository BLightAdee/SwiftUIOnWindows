// RenderContext.swift - Abstract rendering context
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

/// A rendering context that tracks position and accumulated properties.
public struct RenderContext {
    public var origin: CGPoint
    public var size: CGSize
    public var foregroundColor: Color
    public var font: Font
    public var opacity: Double
    public var cornerRadius: CGFloat
    public var clipRect: CGRect?

    public init(origin: CGPoint = .zero, size: CGSize,
                foregroundColor: Color = .primary, font: Font = .body,
                opacity: Double = 1.0, cornerRadius: CGFloat = 0) {
        self.origin = origin
        self.size = size
        self.foregroundColor = foregroundColor
        self.font = font
        self.opacity = opacity
        self.cornerRadius = cornerRadius
    }

    /// Push a child context with offset origin.
    public func child(offset: CGPoint = .zero, size: CGSize? = nil) -> RenderContext {
        var ctx = self
        ctx.origin = CGPoint(x: origin.x + offset.x, y: origin.y + offset.y)
        if let size = size { ctx.size = size }
        return ctx
    }

    /// Render a view using the platform backend.
    public mutating func render<V: View>(_ view: V) {
        RenderTreeBuilder.shared.renderView(view, in: &self)
    }

    /// Render an existential view.
    public mutating func renderAny(_ view: any View) {
        RenderTreeBuilder.shared.renderAnyView(view, in: &self)
    }
}
