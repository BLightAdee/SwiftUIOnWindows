// Stepper.swift - Stepper view
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Stepper<Label: View>: View {
    public typealias Body = Never
    internal let label: Label
    internal let onIncrement: (() -> Void)?
    internal let onDecrement: (() -> Void)?

    public init(@ViewBuilder label: () -> Label, onIncrement: (() -> Void)?, onDecrement: (() -> Void)?) {
        self.label = label()
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    public var body: Never { fatalError("Stepper is a leaf view") }
}

extension Stepper where Label == Text {
    public init(_ titleKey: String, onIncrement: (() -> Void)?, onDecrement: (() -> Void)?) {
        self.label = Text(titleKey)
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    public init<V: Strideable>(_ titleKey: String, value: Binding<V>, in bounds: ClosedRange<V>? = nil, step: V.Stride = 1) {
        self.label = Text(titleKey)
        self.onIncrement = {
            let next = value.wrappedValue.advanced(by: step)
            if let bounds = bounds {
                if bounds.contains(next) { value.wrappedValue = next }
            } else {
                value.wrappedValue = next
            }
        }
        self.onDecrement = {
            let prev = value.wrappedValue.advanced(by: -step)
            if let bounds = bounds {
                if bounds.contains(prev) { value.wrappedValue = prev }
            } else {
                value.wrappedValue = prev
            }
        }
    }
}
