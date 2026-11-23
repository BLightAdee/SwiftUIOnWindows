// GeometryTypes.swift - Core geometry types
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - Edge and EdgeInsets

public enum Edge: Int8, CaseIterable, Sendable {
    case top, leading, bottom, trailing

    public struct Set: OptionSet, Sendable {
        public let rawValue: Int8
        public init(rawValue: Int8) { self.rawValue = rawValue }

        public static let top = Set(rawValue: 1 << 0)
        public static let leading = Set(rawValue: 1 << 1)
        public static let bottom = Set(rawValue: 1 << 2)
        public static let trailing = Set(rawValue: 1 << 3)
        public static let horizontal: Set = [.leading, .trailing]
        public static let vertical: Set = [.top, .bottom]
        public static let all: Set = [.top, .leading, .bottom, .trailing]
    }
}

public struct EdgeInsets: Equatable, Sendable {
    public var top: CGFloat
    public var leading: CGFloat
    public var bottom: CGFloat
    public var trailing: CGFloat

    public init(top: CGFloat = 0, leading: CGFloat = 0,
                bottom: CGFloat = 0, trailing: CGFloat = 0) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }

    public init() {
        self.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}

// MARK: - ProposedSize

public struct ProposedSize: Sendable {
    public var width: CGFloat?
    public var height: CGFloat?

    public init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }

    public static let zero = ProposedSize(width: 0, height: 0)
    public static let infinity = ProposedSize(width: .infinity, height: .infinity)
    public static let unspecified = ProposedSize(width: nil, height: nil)
}

// MARK: - Alignment

public struct Alignment: Equatable, Sendable {
    public var horizontal: HorizontalAlignment
    public var vertical: VerticalAlignment

    public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    public static let center = Alignment(horizontal: .center, vertical: .center)
    public static let leading = Alignment(horizontal: .leading, vertical: .center)
    public static let trailing = Alignment(horizontal: .trailing, vertical: .center)
    public static let top = Alignment(horizontal: .center, vertical: .top)
    public static let bottom = Alignment(horizontal: .center, vertical: .bottom)
    public static let topLeading = Alignment(horizontal: .leading, vertical: .top)
    public static let topTrailing = Alignment(horizontal: .trailing, vertical: .top)
    public static let bottomLeading = Alignment(horizontal: .leading, vertical: .bottom)
    public static let bottomTrailing = Alignment(horizontal: .trailing, vertical: .bottom)
}

public enum HorizontalAlignment: Sendable {
    case leading, center, trailing
}

public enum VerticalAlignment: Sendable {
    case top, center, bottom
}

// MARK: - UnitPoint

public struct UnitPoint: Equatable, Sendable {
    public var x: CGFloat
    public var y: CGFloat

    public init(x: CGFloat, y: CGFloat) { self.x = x; self.y = y }

    public static let zero = UnitPoint(x: 0, y: 0)
    public static let center = UnitPoint(x: 0.5, y: 0.5)
    public static let leading = UnitPoint(x: 0, y: 0.5)
    public static let trailing = UnitPoint(x: 1, y: 0.5)
    public static let top = UnitPoint(x: 0.5, y: 0)
    public static let bottom = UnitPoint(x: 0.5, y: 1)
    public static let topLeading = UnitPoint(x: 0, y: 0)
    public static let topTrailing = UnitPoint(x: 1, y: 0)
    public static let bottomLeading = UnitPoint(x: 0, y: 1)
    public static let bottomTrailing = UnitPoint(x: 1, y: 1)
}

// MARK: - Axis

public enum Axis: Int8, CaseIterable, Sendable {
    case horizontal, vertical

    public struct Set: OptionSet, Sendable {
        public let rawValue: Int8
        public init(rawValue: Int8) { self.rawValue = rawValue }
        public static let horizontal = Set(rawValue: 1 << 0)
        public static let vertical = Set(rawValue: 1 << 1)
    }
}

// MARK: - Angle

public struct Angle: Sendable {
    public var radians: Double
    public init(radians: Double) { self.radians = radians }
    public init(degrees: Double) { self.radians = degrees * .pi / 180 }
    public var degrees: Double { radians * 180 / .pi }
    public static let zero = Angle(radians: 0)
    public static func degrees(_ degrees: Double) -> Angle { Angle(degrees: degrees) }
    public static func radians(_ radians: Double) -> Angle { Angle(radians: radians) }
}
