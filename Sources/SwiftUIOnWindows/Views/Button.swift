// Button.swift - Button view
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct ButtonRole: Equatable, Sendable {
    public init() {}
    public static let destructive = ButtonRole()
    public static let cancel = ButtonRole()
}

public struct Button<Label: View>: View {
    public typealias Body = Never

    internal let action: () -> Void
    internal let label: Label
    internal let role: ButtonRole?

    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
        self.role = nil
    }

    public init(role: ButtonRole?, action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
        self.role = role
    }

    public var body: Never { fatalError("Button is a leaf view") }
}

extension Button where Label == Text {
    public init(_ title: String, action: @escaping () -> Void) {
        self.action = action
        self.label = Text(title)
        self.role = nil
    }

    public init(_ title: String, role: ButtonRole?, action: @escaping () -> Void) {
        self.action = action
        self.label = Text(title)
        self.role = role
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

public struct PlainButtonStyle: ButtonStyle, Sendable {
    public init() {}
    public func makeBody(configuration: ButtonStyleConfiguration) -> some View { configuration.label }
}

public struct BorderedButtonStyle: ButtonStyle, Sendable {
    public init() {}
    public func makeBody(configuration: ButtonStyleConfiguration) -> some View { configuration.label }
}

public struct BorderedProminentButtonStyle: ButtonStyle, Sendable {
    public init() {}
    public func makeBody(configuration: ButtonStyleConfiguration) -> some View { configuration.label }
}

public struct BorderlessButtonStyle: ButtonStyle, Sendable {
    public init() {}
    public func makeBody(configuration: ButtonStyleConfiguration) -> some View { configuration.label }
}

public struct DefaultButtonStyle: ButtonStyle, Sendable {
    public init() {}
    public func makeBody(configuration: ButtonStyleConfiguration) -> some View { configuration.label }
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

extension ButtonStyle where Self == PlainButtonStyle {
    public static var plain: PlainButtonStyle { PlainButtonStyle() }
}
extension ButtonStyle where Self == BorderedButtonStyle {
    public static var bordered: BorderedButtonStyle { BorderedButtonStyle() }
}
extension ButtonStyle where Self == BorderedProminentButtonStyle {
    public static var borderedProminent: BorderedProminentButtonStyle { BorderedProminentButtonStyle() }
}
extension ButtonStyle where Self == BorderlessButtonStyle {
    public static var borderless: BorderlessButtonStyle { BorderlessButtonStyle() }
}
extension ButtonStyle where Self == DefaultButtonStyle {
    public static var automatic: DefaultButtonStyle { DefaultButtonStyle() }
}

public extension View {
    func buttonStyle<S: ButtonStyle>(_ style: S) -> some View {
        self
    }
}
