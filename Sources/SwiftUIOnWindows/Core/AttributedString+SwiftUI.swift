// AttributedString+SwiftUI.swift - AttributedString compatibility extensions for SwiftUI
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct InlinePresentationIntent: OptionSet, Sendable {
    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }
    public static let stronglyEmphasized = InlinePresentationIntent(rawValue: 1 << 0)
    public static let emphasized = InlinePresentationIntent(rawValue: 1 << 1)
}

extension AttributedSubstring {
    public var foregroundColor: Color? {
        get { nil }
        set {}
    }

    public var inlinePresentationIntent: InlinePresentationIntent? {
        get { nil }
        set {}
    }
}

extension AttributedString {
    public var foregroundColor: Color? {
        get { nil }
        set {}
    }

    public var inlinePresentationIntent: InlinePresentationIntent? {
        get { nil }
        set {}
    }
}
