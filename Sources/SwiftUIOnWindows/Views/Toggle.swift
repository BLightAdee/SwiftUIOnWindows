// Toggle.swift - Toggle view
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Toggle<Label: View>: View {
    public typealias Body = Never
    internal let isOn: Binding<Bool>
    internal let label: Label

    public init(isOn: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.isOn = isOn; self.label = label()
    }

    public var body: Never { fatalError("Toggle is a leaf view") }
}

extension Toggle where Label == Text {
    public init(_ titleKey: String, isOn: Binding<Bool>) {
        self.isOn = isOn; self.label = Text(titleKey)
    }
}
