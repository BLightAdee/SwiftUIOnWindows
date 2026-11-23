// Button.swift - Button view
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Button<Label: View>: View {
    public typealias Body = Never

    internal let action: () -> Void
    internal let label: Label
    internal var buttonStyle: AnyButtonStyle = .default

    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    public var body: Never { fatalError("Button is a leaf view") }
}

extension Button where Label == Text {
    public init(_ title: String, action: @escaping () -> Void) {
        self.action = action
        self.label = Text(title)
    }
}

public protocol ButtonStyle {
    associatedtype Body: View
    func makeBody(configuration: ButtonStyleConfiguration) -> Body
}

public struct ButtonStyleConfiguration {
    public let label: AnyView
    public let isPressed: Bool
}

public struct AnyButtonStyle: Sendable {
    internal enum Style: Sendable {
        case `default`, bordered, borderedProminent, borderless, plain
    }
    internal let style: Style
    public static let `default` = AnyButtonStyle(style: .default)
    public static let bordered = AnyButtonStyle(style: .bordered)
    public static let borderedProminent = AnyButtonStyle(style: .borderedProminent)
    public static let borderless = AnyButtonStyle(style: .borderless)
    public static let plain = AnyButtonStyle(style: .plain)
}
