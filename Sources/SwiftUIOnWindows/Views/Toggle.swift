// Toggle.swift - Toggle view
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct Toggle<Label: View>: View, _RenderableInternal, _LayoutSizableInternal {
    public typealias Body = Never
    internal let isOn: Binding<Bool>
    internal let label: Label

    public init(isOn: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.isOn = isOn; self.label = label()
    }

    public var body: Never { fatalError("Toggle is a leaf view") }

    public func _layout(proposed: ProposedSize) -> CGSize {
        let labelSize = LayoutEngine.layoutAny(label, proposed: proposed)
        return CGSize(width: labelSize.width + 48, height: max(24, labelSize.height))
    }

    public func _render(in context: inout RenderContext) {
        let labelSize = LayoutEngine.layoutAny(label, proposed: ProposedSize(width: context.size.width, height: context.size.height))
        var labelCtx = context.child(offset: .zero, size: labelSize)
        labelCtx.render(label)

        // Draw toggle switch
        let switchWidth: CGFloat = 36
        let switchHeight: CGFloat = 20
        let switchX = context.origin.x + context.size.width - switchWidth
        let switchY = context.origin.y + (context.size.height - switchHeight) / 2
        let switchRect = CGRect(x: switchX, y: switchY, width: switchWidth, height: switchHeight)

        let switchColor = isOn.wrappedValue ? Color.green : Color(red: 0.8, green: 0.8, blue: 0.8)
        RenderTreeBuilder.shared.appendNode(.rect(switchColor, switchRect, 10))

        let thumbSize: CGFloat = 16
        let thumbX = isOn.wrappedValue ? (switchX + switchWidth - thumbSize - 2) : (switchX + 2)
        let thumbRect = CGRect(x: thumbX, y: switchY + 2, width: thumbSize, height: thumbSize)
        RenderTreeBuilder.shared.appendNode(.rect(Color.white, thumbRect, 8))

        // Register click target
        let totalRect = CGRect(origin: context.origin, size: context.size)
        let binding = isOn
        RenderTreeBuilder.shared.registerClickTarget(rect: totalRect) {
            binding.wrappedValue.toggle()
        }
    }
}

extension Toggle where Label == Text {
    public init(_ titleKey: String, isOn: Binding<Bool>) {
        self.isOn = isOn; self.label = Text(titleKey)
    }
}
