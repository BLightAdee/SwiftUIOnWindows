import SwiftUI
import Foundation

/// Data structure carrying physical node screen coordinates
public struct NodeAnchorData: Equatable {
    public let id: String
    public let center: CGPoint
    public let leftAnchor: CGPoint
    public let rightAnchor: CGPoint
    public let topAnchor: CGPoint
    public let bottomAnchor: CGPoint
}

/// Preference Key to bubble up node coordinate mappings in the Canvas Coordinate Space
public struct NodeGeometryPreferenceKey: PreferenceKey {
    public static var defaultValue: [String: NodeAnchorData] = [:]
    
    public static func reduce(value: inout [String: NodeAnchorData], nextValue: () -> [String: NodeAnchorData]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

public struct VisualizerNodeView: View {
    public let node: NodeModel
    public let showPrevPointer: Bool // True for doubly linked list layout
    
    @State private var isHovered = false
    
    public init(node: NodeModel, showPrevPointer: Bool = false) {
        self.node = node
        self.showPrevPointer = showPrevPointer
    }
    
    public var body: some View {
        VStack(spacing: 6) {
            // Address Label (Simulated RAM location)
            Text(node.address)
                .font(AppTheme.monoFont(size: 10))
                .foregroundColor(addressColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(addressColor.opacity(0.12))
                .cornerRadius(4)
                .scaleEffect(isHovered ? 1.05 : 1.0)
                .animation(.spring(response: 0.2), value: isHovered)
            
            // Double-Compartment Node Body
            HStack(spacing: 0) {
                // Prev compartment (if doubly linked)
                if showPrevPointer {
                    VStack(spacing: 2) {
                        Text("prev")
                            .font(AppTheme.monoFont(size: 8))
                            .foregroundColor(.secondary)
                        Text(shortAddress(node.prevAddress ?? ""))
                            .font(AppTheme.monoFont(size: 9))
                            .bold()
                            .foregroundColor(.indigo)
                    }
                    .frame(width: 42, height: 42)
                    .background(Color.primary.opacity(0.03))
                    
                    Divider()
                }
                
                // Data Compartment
                VStack(spacing: 2) {
                    Text("data")
                        .font(AppTheme.monoFont(size: 8))
                        .foregroundColor(.secondary)
                    Text("\(node.value)")
                        .font(AppTheme.titleFont(size: 16))
                        .foregroundColor(.primary)
                }
                .frame(width: 50, height: 42)
                
                Divider()
                
                // Next Compartment
                VStack(spacing: 2) {
                    Text("next")
                        .font(AppTheme.monoFont(size: 8))
                        .foregroundColor(.secondary)
                    Text(shortAddress(node.nextAddress))
                        .font(AppTheme.monoFont(size: 9))
                        .bold()
                        .foregroundColor(.blue)
                }
                .frame(width: 42, height: 42)
                .background(Color.primary.opacity(0.03))
            }
            .frame(height: 46)
            .background(.thinMaterial)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: node.state == .active || node.state == .highlight ? 2 : 1)
            )
            .shadow(color: glowColor.opacity(node.state == .active || node.state == .highlight ? 0.35 : 0.05), radius: 6)
            .scaleEffect(node.state == .temp ? 0.95 : 1.0)
            
            // Stack/Heap Allocation Tag (Optional detail context)
            if node.state == .temp {
                Text("Heap Alloc")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(3)
            }
        }
        .padding(4)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        // Bubble up coordinates in `"canvas"` relative namespace
        .background(
            GeometryReader { geo in
                let frame = geo.frame(in: .named("canvas"))
                Color.clear
                    .preference(key: NodeGeometryPreferenceKey.self, value: [
                        node.id: NodeAnchorData(
                            id: node.id,
                            center: CGPoint(x: frame.midX, y: frame.midY),
                            leftAnchor: CGPoint(x: frame.minX, y: frame.midY + 6), // Offset slightly down from center line
                            rightAnchor: CGPoint(x: frame.maxX, y: frame.midY + 6),
                            topAnchor: CGPoint(x: frame.midX, y: frame.minY),
                            bottomAnchor: CGPoint(x: frame.midX, y: frame.maxY)
                        )
                    ])
            }
        )
    }
    
    // Style Utilities
    private var borderColor: Color {
        switch node.state {
        case .normal: return AppTheme.UI.nodeBorderNormal
        case .active: return AppTheme.UI.nodeBorderActive
        case .temp: return AppTheme.UI.nodeBorderTemp
        case .highlight: return AppTheme.UI.nodeBorderHighlight
        case .deleted: return Color.red.opacity(0.6)
        }
    }
    
    private var glowColor: Color {
        switch node.state {
        case .active: return .blue
        case .highlight: return .green
        case .temp: return .orange
        default: return .clear
        }
    }
    
    private var addressColor: Color {
        if node.state == .active { return .blue }
        if node.state == .highlight { return .green }
        if node.state == .temp { return .orange }
        return .secondary
    }
    
    private func shortAddress(_ addr: String) -> String {
        if addr == "nullptr" || addr == "NULL" || addr.isEmpty {
            return "∅"
        }
        // Take last 4 digits for sleek display
        if addr.count >= 6 {
            return String(addr.suffix(4))
        }
        return addr
    }
}

#if !os(Windows)
#Preview {
    HStack(spacing: 20) {
        VisualizerNodeView(node: NodeModel(value: 5, address: "0x7FFA2", nextAddress: "0x7FFA8"))
        VisualizerNodeView(node: NodeModel(value: 12, address: "0x7FFA8", nextAddress: "nullptr", state: .temp))
        VisualizerNodeView(node: NodeModel(value: 42, address: "0x7FFBC", nextAddress: "0x7FFC0", prevAddress: "0x7FFA8", state: .active), showPrevPointer: true)
    }
    .coordinateSpace(name: "canvas")
    .padding()
}
#endif
