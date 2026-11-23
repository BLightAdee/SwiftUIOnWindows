// Picker.swift - Picker view
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Picker<Label: View, SelectionValue: Hashable, Content: View>: View {
    public typealias Body = Never
    internal let selection: Binding<SelectionValue>
    internal let label: Label
    internal let content: Content

    public init(selection: Binding<SelectionValue>,
                @ViewBuilder content: () -> Content,
                @ViewBuilder label: () -> Label) {
        self.selection = selection; self.label = label(); self.content = content()
    }

    public var body: Never { fatalError("Picker is a leaf view") }
}

extension Picker where Label == Text {
    public init(_ titleKey: String, selection: Binding<SelectionValue>,
                @ViewBuilder content: () -> Content) {
        self.selection = selection; self.label = Text(titleKey); self.content = content()
    }
}

public protocol PickerStyle {}
public struct MenuPickerStyle: PickerStyle, Sendable { public init() {} }
public struct SegmentedPickerStyle: PickerStyle, Sendable { public init() {} }
public struct DefaultPickerStyle: PickerStyle, Sendable { public init() {} }

extension PickerStyle where Self == MenuPickerStyle {
    public static var menu: MenuPickerStyle { MenuPickerStyle() }
}
extension PickerStyle where Self == SegmentedPickerStyle {
    public static var segmented: SegmentedPickerStyle { SegmentedPickerStyle() }
}
extension PickerStyle where Self == DefaultPickerStyle {
    public static var automatic: DefaultPickerStyle { DefaultPickerStyle() }
}

public extension View {
    func pickerStyle<S: PickerStyle>(_ style: S) -> some View {
        self
    }
}
