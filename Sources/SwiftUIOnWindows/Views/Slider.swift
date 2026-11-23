// Slider.swift - Slider view
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Slider: View {
    public typealias Body = Never
    internal let value: Binding<Double>
    internal let bounds: ClosedRange<Double>
    internal let step: Double?

    public init(value: Binding<Double>, in bounds: ClosedRange<Double> = 0...1,
                step: Double? = nil) {
        self.value = value; self.bounds = bounds; self.step = step
    }

    public var body: Never { fatalError("Slider is a leaf view") }
}
