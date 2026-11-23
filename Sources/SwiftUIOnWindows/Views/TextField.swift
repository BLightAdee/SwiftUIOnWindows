// TextField.swift - TextField and SecureField views
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct ValueFormatStyle: Sendable {
    public init() {}
    public static var number: ValueFormatStyle { ValueFormatStyle() }
}

public struct TextField: View {
    public typealias Body = Never
    internal let titleKey: String
    internal let text: Binding<String>

    public init(_ titleKey: String, text: Binding<String>) {
        self.titleKey = titleKey; self.text = text
    }

    public init<V, F>(_ titleKey: String, value: Binding<V>, format: F) {
        self.titleKey = titleKey
        self.text = Binding(
            get: { "\(value.wrappedValue)" },
            set: { _ in }
        )
    }

    public init<V>(_ titleKey: String, value: Binding<V>, format: ValueFormatStyle) {
        self.titleKey = titleKey
        self.text = Binding(
            get: { "\(value.wrappedValue)" },
            set: { _ in }
        )
    }

    public var body: Never { fatalError("TextField is a leaf view") }
}

public struct SecureField: View {
    public typealias Body = Never
    internal let titleKey: String
    internal let text: Binding<String>

    public init(_ titleKey: String, text: Binding<String>) {
        self.titleKey = titleKey; self.text = text
    }

    public var body: Never { fatalError("SecureField is a leaf view") }
}

public protocol TextFieldStyle {}
public struct RoundedBorderTextFieldStyle: TextFieldStyle, Sendable { public init() {} }
public struct PlainTextFieldStyle: TextFieldStyle, Sendable { public init() {} }
public struct DefaultTextFieldStyle: TextFieldStyle, Sendable { public init() {} }

extension TextFieldStyle where Self == RoundedBorderTextFieldStyle {
    public static var roundedBorder: RoundedBorderTextFieldStyle { RoundedBorderTextFieldStyle() }
}
extension TextFieldStyle where Self == PlainTextFieldStyle {
    public static var plain: PlainTextFieldStyle { PlainTextFieldStyle() }
}
extension TextFieldStyle where Self == DefaultTextFieldStyle {
    public static var automatic: DefaultTextFieldStyle { DefaultTextFieldStyle() }
}

public extension View {
    func textFieldStyle<S: TextFieldStyle>(_ style: S) -> some View {
        self
    }
}
