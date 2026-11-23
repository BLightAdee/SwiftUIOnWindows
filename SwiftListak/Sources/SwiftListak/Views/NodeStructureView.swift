import SwiftUI
import Foundation

public struct NodeStructureView: View {
    @State private var stackVariable: String = "head"
    @State private var stackValue: String = "nullptr"
    @State private var heapNodeAllocated = false
    @State private var isDangling = false
    @State private var isNullified = true
    
    // Coordinates mapping
    @State private var anchorPoints: [String: NodeAnchorData] = [:]
    
    public init() {}
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                // Header Pane
                VStack(alignment: .leading, spacing: 6) {
                    Text("Core Concept")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.indigo)
                    Text("Node Structure & Pointer Syntax")
                        .font(AppTheme.titleFont(size: 28))
                        .foregroundColor(.primary)
                    Text("How C/C++ represents a node and manages raw memory pointers.")
                        .font(AppTheme.bodyFont(size: 14))
                        .foregroundColor(.secondary)
                }
                
                // Code block of standard node struct
                VStack(alignment: .leading, spacing: 10) {
                    Text("C++ Node Definition")
                        .font(AppTheme.titleFont(size: 18))
                    
                    CodeBlockView(code: """
struct Node {
    int data;           // Holds the cell value (4 bytes)
    Node* next;         // Pointer containing next node's address (8 bytes)
    
    // Constructor to initialize elements
    Node(int val) {
        data = val;
        next = nullptr; // Initialize next pointer to null
    }
};
""")
                    .frame(height: 180)
                }
                
                // Interactive Stack vs Heap Simulator
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Interactive Stack vs. Heap Simulator")
                            .font(AppTheme.titleFont(size: 18))
                        Spacer()
                        
                        // Help Popover
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.secondary)
                            .help("Stack stores local pointer variables; Heap stores dynamic objects created via 'new'")
                    }
                    
                    // Memory Visual Canvas
                    ZStack {
                        // Drawing connecting pointer line dynamically
                        if heapNodeAllocated && !isDangling {
                            PointerRendererLine(from: anchorPoints["stack_var"]?.rightAnchor ?? .zero,
                                                to: anchorPoints["heap_node"]?.leftAnchor ?? .zero,
                                                color: .blue)
                        } else if isDangling {
                            PointerRendererLine(from: anchorPoints["stack_var"]?.rightAnchor ?? .zero,
                                                to: CGPoint(x: (anchorPoints["stack_var"]?.rightAnchor.x ?? 0) + 80,
                                                            y: (anchorPoints["stack_var"]?.rightAnchor.y ?? 0)),
                                                color: .red,
                                                isDashed: true)
                        }
                        
                        HStack(spacing: 40) {
                            // Stack Space
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "square.stack.3d.up.fill")
                                        .foregroundColor(.indigo)
                                    Text("Stack Memory (Fast)")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(.indigo)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Address: 0x7FFE9B")
                                        .font(AppTheme.monoFont(size: 9))
                                        .foregroundColor(.secondary)
                                    
                                    // Pointer variable box
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("type")
                                                .font(.system(size: 8))
                                                .foregroundColor(.secondary)
                                            Text("Node*")
                                                .font(AppTheme.monoFont(size: 10))
                                                .bold()
                                        }
                                        .padding(.trailing, 8)
                                        
                                        Divider()
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("name")
                                                .font(.system(size: 8))
                                                .foregroundColor(.secondary)
                                            Text(stackVariable)
                                                .font(AppTheme.monoFont(size: 11))
                                                .bold()
                                        }
                                        .padding(.horizontal, 8)
                                        
                                        Divider()
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("value (address)")
                                                .font(.system(size: 8))
                                                .foregroundColor(.secondary)
                                            Text(stackValue)
                                                .font(AppTheme.monoFont(size: 10))
                                                .bold()
                                                .foregroundColor(stackValue == "nullptr" ? .secondary : (isDangling ? .red : .blue))
                                        }
                                    }
                                    .padding(8)
                                    .background(.thinMaterial)
                                    .cornerRadius(6)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(isDangling ? Color.red : Color.indigo.opacity(0.3), lineWidth: 1))
                                    .background(
                                        GeometryReader { geo in
                                            let frame = geo.frame(in: .named("canvas"))
                                            Color.clear
                                                .preference(key: NodeGeometryPreferenceKey.self, value: [
                                                    "stack_var": NodeAnchorData(
                                                        id: "stack_var",
                                                        center: CGPoint(x: frame.midX, y: frame.midY),
                                                        leftAnchor: CGPoint(x: frame.minX, y: frame.midY),
                                                        rightAnchor: CGPoint(x: frame.maxX, y: frame.midY),
                                                        topAnchor: CGPoint(x: frame.midX, y: frame.minY),
                                                        bottomAnchor: CGPoint(x: frame.midX, y: frame.maxY)
                                                    )
                                                ])
                                        }
                                    )
                                }
                                .padding()
                                .frame(width: 250, height: 130)
                                .background(Color.indigo.opacity(0.04))
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                            
                            // Heap Space
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "square.dashed")
                                        .foregroundColor(.teal)
                                    Text("Heap Memory (Dynamic)")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(.teal)
                                
                                ZStack {
                                    if heapNodeAllocated {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Address: 0x1008C")
                                                .font(AppTheme.monoFont(size: 9))
                                                .foregroundColor(.secondary)
                                            
                                            HStack(spacing: 0) {
                                                VStack(spacing: 2) {
                                                    Text("data")
                                                        .font(.system(size: 8))
                                                        .foregroundColor(.secondary)
                                                    Text("42")
                                                        .font(AppTheme.titleFont(size: 16))
                                                }
                                                .frame(width: 48, height: 42)
                                                
                                                Divider()
                                                
                                                VStack(spacing: 2) {
                                                    Text("next")
                                                        .font(.system(size: 8))
                                                        .foregroundColor(.secondary)
                                                    Text("nullptr")
                                                        .font(AppTheme.monoFont(size: 9))
                                                }
                                                .frame(width: 48, height: 42)
                                            }
                                            .background(.thinMaterial)
                                            .cornerRadius(6)
                                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.teal.opacity(0.4), lineWidth: 1))
                                            .background(
                                                GeometryReader { geo in
                                                    let frame = geo.frame(in: .named("canvas"))
                                                    Color.clear
                                                        .preference(key: NodeGeometryPreferenceKey.self, value: [
                                                            "heap_node": NodeAnchorData(
                                                                id: "heap_node",
                                                                center: CGPoint(x: frame.midX, y: frame.midY),
                                                                leftAnchor: CGPoint(x: frame.minX, y: frame.midY),
                                                                rightAnchor: CGPoint(x: frame.maxX, y: frame.midY),
                                                                topAnchor: CGPoint(x: frame.midX, y: frame.minY),
                                                                bottomAnchor: CGPoint(x: frame.midX, y: frame.maxY)
                                                            )
                                                        ])
                                                }
                                            )
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    } else {
                                        Text("Heap is Empty\n(Unallocated)")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .opacity(0.5)
                                    }
                                }
                                .padding()
                                .frame(width: 250, height: 130)
                                .background(Color.teal.opacity(0.04))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .coordinateSpace(name: "canvas")
                    .onPreferenceChange(NodeGeometryPreferenceKey.self) { anchors in
                        self.anchorPoints = anchors
                    }
                    .frame(height: 180)
                    
                    // Control Board
                    HStack(spacing: 12) {
                        Button(action: allocateNode) {
                            Text("head = new Node(42);")
                                .font(AppTheme.monoFont(size: 11))
                        }
                        .disabled(heapNodeAllocated && !isDangling)
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        
                        Button(action: deleteNode) {
                            Text("delete head;")
                                .font(AppTheme.monoFont(size: 11))
                        }
                        .disabled(!heapNodeAllocated || isDangling)
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        Button(action: nullifyPointer) {
                            Text("head = nullptr;")
                                .font(AppTheme.monoFont(size: 11))
                        }
                        .disabled(isNullified)
                        .buttonStyle(.bordered)
                        .tint(.orange)
                    }
                    
                    // Warnings & Explanations Panel (Xcode Style Info Banners)
                    VStack(alignment: .leading, spacing: 8) {
                        if heapNodeAllocated && !isDangling {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Valid Pointer Bond Established")
                                        .font(.system(size: 12, weight: .bold))
                                    Text("The stack variable 'head' correctly stores the dynamic heap block's starting address '0x1008C'.")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                        } else if isDangling {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("⚠️ WARNING: Dangling Pointer Detected!")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.red)
                                    Text("'delete head;' destroyed the node on the heap. However, the stack pointer variable 'head' STILL stores the memory location '0x1008C'! Accessing 'head->data' now will trigger a fatal Segmentation Fault crash.")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                        } else if isNullified && !heapNodeAllocated {
                            HStack(spacing: 10) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Pointer is Nullified (Safe State)")
                                        .font(.system(size: 12, weight: .bold))
                                    Text("'head' is set to 'nullptr' (0x0). It holds no reference to any random addresses, preventing accidents.")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                    .animation(.spring(response: 0.3), value: heapNodeAllocated)
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.1), lineWidth: 1))
            }
            .padding(24)
        }
    }
    
    // Core Simulator Logic
    private func allocateNode() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            heapNodeAllocated = true
            isDangling = false
            isNullified = false
            stackValue = "0x1008C"
        }
    }
    
    private func deleteNode() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            heapNodeAllocated = false
            isDangling = true
            isNullified = false
            // stackValue remains 0x1008C to show dangling reference!
        }
    }
    
    private func nullifyPointer() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            isDangling = false
            isNullified = true
            stackValue = "nullptr"
        }
    }
}

// Inline line helper for drawing customized straight connections
struct PointerRendererLine: View {
    let from: CGPoint
    let to: CGPoint
    var color: Color
    var isDashed: Bool = false
    
    var body: some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
            
            // Draw standard pointer arrow head
            let angle = atan2(to.y - from.y, to.x - from.x)
            let arrowSize: CGFloat = 6
            let arrowAngle = CGFloat.pi / 6
            let p1 = CGPoint(x: to.x - arrowSize * cos(angle - arrowAngle), y: to.y - arrowSize * sin(angle - arrowAngle))
            let p2 = CGPoint(x: to.x - arrowSize * cos(angle + arrowAngle), y: to.y - arrowSize * sin(angle + arrowAngle))
            path.move(to: to)
            path.addLine(to: p1)
            path.move(to: to)
            path.addLine(to: p2)
        }
        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: isDashed ? [4, 4] : []))
        .allowsHitTesting(false)
    }
}

#if !os(Windows)
#Preview {
    NodeStructureView()
}
#endif
