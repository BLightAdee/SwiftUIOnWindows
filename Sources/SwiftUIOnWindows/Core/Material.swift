// Material.swift - Background materials
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Material: Sendable, View {
    public typealias Body = Never

    public static let ultraThin = Material()
    public static let thin = Material()
    public static let regular = Material()
    public static let thick = Material()
    public static let ultraThick = Material()

    public static let ultraThinMaterial = Material.ultraThin
    public static let thinMaterial = Material.thin
    public static let regularMaterial = Material.regular
    public static let thickMaterial = Material.thick
    public static let ultraThickMaterial = Material.ultraThick

    public var body: Never { fatalError("Material uses custom rendering") }
}

public struct ShapeStyle_Material: Sendable {
    public static let ultraThinMaterial = Material.ultraThin
    public static let thinMaterial = Material.thin
    public static let regularMaterial = Material.regular
    public static let thickMaterial = Material.thick
    public static let ultraThickMaterial = Material.ultraThick
}

// Allow .background(.ultraThinMaterial) or .background(.thinMaterial)
public extension View {
    func background(_ material: Material) -> some View {
        self.background(Color.white.opacity(0.85))
    }
}
