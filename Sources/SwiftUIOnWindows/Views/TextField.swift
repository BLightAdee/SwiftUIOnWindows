// TextField.swift - TextField and SecureField views
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct ValueFormatStyle: Sendable {
    public init() {}
    public static var number: ValueFormatStyle { ValueFormatStyle() }
}

public struct TextField: View, _RenderableInternal, _LayoutSizableInternal {
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

    public func _layout(proposed: ProposedSize) -> CGSize {
        return CGSize(width: proposed.width ?? 180, height: 28)
    }

    public func _render(in context: inout RenderContext) {
        let rect = CGRect(origin: context.origin, size: context.size)
        RenderTreeBuilder.shared.appendNode(.rect(Color.white, rect, 4))
        RenderTreeBuilder.shared.appendNode(.border(Color.gray.opacity(0.5), rect, 4, 1))
        let displayText = text.wrappedValue.isEmpty ? titleKey : text.wrappedValue
        let textColor = text.wrappedValue.isEmpty ? Color.gray : Color.black
        let textRect = CGRect(origin: CGPoint(x: rect.origin.x + 8, y: rect.origin.y + 5),
                              size: CGSize(width: max(0, rect.size.width - 16), height: max(0, rect.size.height - 10)))
        RenderTreeBuilder.shared.appendNode(.text(displayText, context.font, textColor, textRect))
    }
}

public struct SecureField: View, _RenderableInternal, _LayoutSizableInternal {
    public typealias Body = Never
    internal let titleKey: String
    internal let text: Binding<String>

    public init(_ titleKey: String, text: Binding<String>) {
        self.titleKey = titleKey; self.text = text
    }

    public var body: Never { fatalError("SecureField is a leaf view") }

    public func _layout(proposed: ProposedSize) -> CGSize {
        return CGSize(width: proposed.width ?? 180, height: 28)
    }

    public func _render(in context: inout RenderContext) {
        let rect = CGRect(origin: context.origin, size: context.size)
        RenderTreeBuilder.shared.appendNode(.rect(Color.white, rect, 4))
        RenderTreeBuilder.shared.appendNode(.border(Color.gray.opacity(0.5), rect, 4, 1))
        let displayText = text.wrappedValue.isEmpty ? titleKey : String(repeating: "•", count: text.wrappedValue.count)
        let textColor = text.wrappedValue.isEmpty ? Color.gray : Color.black
        let textRect = CGRect(origin: CGPoint(x: rect.origin.x + 8, y: rect.origin.y + 5),
                              size: CGSize(width: max(0, rect.size.width - 16), height: max(0, rect.size.height - 10)))
        RenderTreeBuilder.shared.appendNode(.text(displayText, context.font, textColor, textRect))
    }
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
