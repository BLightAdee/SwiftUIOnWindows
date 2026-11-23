// Slider.swift - Slider view
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Slider: View, _RenderableInternal, _LayoutSizableInternal {
    public typealias Body = Never
    internal let value: Binding<Double>
    internal let bounds: ClosedRange<Double>
    internal let step: Double?

    public init(value: Binding<Double>, in bounds: ClosedRange<Double> = 0...1,
                step: Double? = nil) {
        self.value = value; self.bounds = bounds; self.step = step
    }

    public init<Label: View>(value: Binding<Double>, in bounds: ClosedRange<Double> = 0...1,
                             step: Double? = nil,
                             @ViewBuilder label: () -> Label) {
        self.value = value; self.bounds = bounds; self.step = step
    }

    public var body: Never { fatalError("Slider is a leaf view") }

    public func _layout(proposed: ProposedSize) -> CGSize {
        return CGSize(width: proposed.width ?? 150, height: 24)
    }

    public func _render(in context: inout RenderContext) {
        let trackHeight: CGFloat = 4
        let trackY = context.origin.y + (context.size.height - trackHeight) / 2
        let trackRect = CGRect(x: context.origin.x, y: trackY, width: context.size.width, height: trackHeight)
        RenderTreeBuilder.shared.appendNode(.rect(Color(red: 0.8, green: 0.8, blue: 0.8), trackRect, 2))

        let range = bounds.upperBound - bounds.lowerBound
        let fraction = range > 0 ? CGFloat((value.wrappedValue - bounds.lowerBound) / range) : 0
        let clampedFraction = min(max(fraction, 0), 1)

        let filledRect = CGRect(x: context.origin.x, y: trackY, width: context.size.width * clampedFraction, height: trackHeight)
        RenderTreeBuilder.shared.appendNode(.rect(Color.blue, filledRect, 2))

        let thumbSize: CGFloat = 16
        let thumbX = context.origin.x + (context.size.width - thumbSize) * clampedFraction
        let thumbY = context.origin.y + (context.size.height - thumbSize) / 2
        let thumbRect = CGRect(x: thumbX, y: thumbY, width: thumbSize, height: thumbSize)
        RenderTreeBuilder.shared.appendNode(.rect(Color.white, thumbRect, 8))
        RenderTreeBuilder.shared.appendNode(.border(Color.gray.opacity(0.4), thumbRect, 8, 1))
    }
}
