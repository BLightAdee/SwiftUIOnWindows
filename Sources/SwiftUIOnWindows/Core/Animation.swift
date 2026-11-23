// Animation.swift - Animation system
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Animation: Sendable {
    public static let `default` = Animation()

    public static func easeInOut(duration: Double = 0.35) -> Animation { Animation() }
    public static func easeIn(duration: Double = 0.35) -> Animation { Animation() }
    public static func easeOut(duration: Double = 0.35) -> Animation { Animation() }
    public static func linear(duration: Double = 0.35) -> Animation { Animation() }
    public static func spring(response: Double = 0.55, dampingFraction: Double = 0.825, blendDuration: Double = 0) -> Animation { Animation() }

    public func delay(_ delay: Double) -> Animation { self }
    public func repeatCount(_ repeatCount: Int, autoreverses: Bool = true) -> Animation { self }
    public func repeatForever(autoreverses: Bool = true) -> Animation { self }
}

public func withAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
    try body()
}

public struct AnyTransition: Sendable {
    public init() {}
    public static let opacity = AnyTransition()
    public static let slide = AnyTransition()
    public static let scale = AnyTransition()
    public static let identity = AnyTransition()

    public static func move(edge: Edge) -> AnyTransition { AnyTransition() }

    public func combined(with other: AnyTransition) -> AnyTransition { AnyTransition() }
    public func animation(_ animation: Animation?) -> AnyTransition { AnyTransition() }
    public static func asymmetric(insertion: AnyTransition, removal: AnyTransition) -> AnyTransition { AnyTransition() }
}

public extension View {
    func transition(_ t: AnyTransition) -> some View {
        self
    }
}
