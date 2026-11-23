import SwiftUI

public struct SandboxView: View {
    @State private var nodes: [NodeModel] = [
        NodeModel(value: 10, address: "0x8040"),
        NodeModel(value: 20, address: "0x8080"),
        NodeModel(value: 30, address: "0x80C0")
    ]
    
    @State private var newValueStr: String = "15"
    @State private var selectedNodeId: String? = nil
    
    // Canvas geometry
    @State private var anchorPoints: [String: NodeAnchorData] = [:]
    
    public init() {
        // Initialize connections
        // Note: SwiftUI requires self assignments in init or inline. We do it onAppear or via helper computed properties.
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            // MAIN VIEW: Visual Canvas
            VStack(spacing: 0) {
                // Header Panel
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Interactive Sandbox Playground")
                            .font(AppTheme.titleFont(size: 20))
                        Text("Build your own C++ linked list! Select a node to view or edit its memory state in the Inspector.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                
                Divider()
                
                // Live visual canvas
                ZStack {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 40) {
                            // Head anchor badge
                            VStack {
                                Text("head")
                                    .font(AppTheme.monoFont(size: 10))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(nodes.isEmpty ? Color.red : Color.blue)
                                    .cornerRadius(4)
                                    .background(
                                        GeometryReader { geo in
                                            let frame = geo.frame(in: .named("sandbox_canvas"))
                                            Color.clear
                                                .preference(key: NodeGeometryPreferenceKey.self, value: [
                                                    "global_head": NodeAnchorData(
                                                        id: "global_head",
                                                        center: CGPoint(x: frame.midX, y: frame.midY),
                                                        leftAnchor: CGPoint(x: frame.minX, y: frame.midY),
                                                        rightAnchor: CGPoint(x: frame.maxX, y: frame.midY),
                                                        topAnchor: CGPoint(x: frame.midX, y: frame.minY),
                                                        bottomAnchor: CGPoint(x: frame.midX, y: frame.maxY)
                                                    )
                                                ])
                                        }
                                    )
                                Spacer().frame(height: 60)
                            }
                            .padding(.top, 32)
                            
                            if nodes.isEmpty {
                                VStack {
                                    Spacer().frame(height: 32)
                                    Text("List is Empty (nullptr)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .background(Color.primary.opacity(0.03))
                                        .cornerRadius(6)
                                }
                            } else {
                                ForEach(nodes) { node in
                                    Button(action: { selectedNodeId = node.id }) {
                                        VisualizerNodeView(node: node)
                                            .xcodeCardStyle(isSelected: selectedNodeId == node.id, highlightColor: .blue)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, 32)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .frame(minHeight: 200)
                    }
                    
                    // Arrow Connections Overlay
                    PointerArrowView(connections: generateConnections(), anchorData: anchorPoints)
                }
                .coordinateSpace(name: "sandbox_canvas")
                .onPreferenceChange(NodeGeometryPreferenceKey.self) { anchors in
                    self.anchorPoints = anchors
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.primary.opacity(0.01))
                
                Divider()
                
                // Sandbox Controls Bar (Xcode Debug look)
                HStack(spacing: 12) {
                    // Node value field
                    HStack(spacing: 6) {
                        Text("Value:")
                            .font(.system(size: 11, weight: .semibold))
                        TextField("Val", text: $newValueStr)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 48)
                            .controlSize(.small)
                    }
                    
                    Divider().frame(height: 18)
                    
                    Button(action: insertHead) {
                        Image(systemName: "plus.square")
                        Text("Insert Head")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button(action: insertTail) {
                        Image(systemName: "plus.square")
                        Text("Insert Tail")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Divider().frame(height: 18)
                    
                    Button(action: deleteHead) {
                        Image(systemName: "minus.square")
                        Text("Delete Head")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(nodes.isEmpty)
                    
                    Button(action: deleteTail) {
                        Image(systemName: "minus.square")
                        Text("Delete Tail")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(nodes.isEmpty)
                    
                    Divider().frame(height: 18)
                    
                    Button(action: reverseList) {
                        Image(systemName: "arrow.left.and.right")
                        Text("Reverse")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(nodes.count < 2)
                    
                    Spacer()
                }
                .padding(12)
                .background(Color.primary.opacity(0.03))
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            // RIGHT INSPECTOR PANEL (Xcode Native Utility Pane Style)
            VStack(alignment: .leading, spacing: 0) {
                // Inspector Headers
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                    Text("Identity Inspector")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.primary.opacity(0.04))
                
                Divider()
                
                if let selectedNode = nodes.first(where: { $0.id == selectedNodeId }) {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // Physical RAM location
                            inspectorSection(title: "RAM IDENTITY") {
                                VStack(alignment: .leading, spacing: 6) {
                                    labeledValue(label: "Node Address", value: selectedNode.address, mono: true, color: .indigo)
                                    labeledValue(label: "Next Pointer", value: selectedNode.nextAddress, mono: true, color: .blue)
                                }
                            }
                            
                            Divider()
                            
                            // Edit Value (Form fields look)
                            inspectorSection(title: "NODE CONTENT") {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("data (int)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.secondary)
                                    
                                    // Custom value slider or input
                                    HStack {
                                        TextField("data", value: binding(for: selectedNode.id), format: .number)
                                            .textFieldStyle(.roundedBorder)
                                            .controlSize(.small)
                                        
                                        Stepper("", value: binding(for: selectedNode.id), in: -999...999)
                                            .labelsHidden()
                                            .controlSize(.small)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Manual pointer deallocation simulator
                            inspectorSection(title: "MEMORY MANAGEMENT") {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Free this specific node from the C++ dynamic heap space manually:")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                    
                                    Button(role: .destructive, action: { freeSpecificNode(id: selectedNode.id) }) {
                                        HStack {
                                            Spacer()
                                            Image(systemName: "trash")
                                            Text("delete & free(node);")
                                                .font(AppTheme.monoFont(size: 11))
                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.red)
                                    .controlSize(.small)
                                }
                            }
                        }
                        .padding(16)
                    }
                } else {
                    // Empty Inspector State
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "slider.horizontal.3")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("No Node Selected")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Select any node card on the canvas to inspect and edit its physical memory contents.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: 250)
            .background(Color.primary.opacity(0.01))
        }
        .onAppear {
            updateNextAddresses()
        }
    }
    
    // Auxiliary UI Helpers
    private func inspectorSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
            content()
        }
    }
    
    private func labeledValue(label: String, value: String, mono: Bool = false, color: Color = .primary) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(mono ? AppTheme.monoFont(size: 10) : .system(size: 11))
                .bold()
                .foregroundColor(color)
        }
    }
    
    // Binding wrapper to update visual state interactively inside Inspector
    private func binding(for id: String) -> Binding<Int> {
        Binding(
            get: {
                self.nodes.first(where: { $0.id == id })?.value ?? 0
            },
            set: { newValue in
                if let idx = self.nodes.firstIndex(where: { $0.id == id }) {
                    self.nodes[idx].value = newValue
                }
            }
        )
    }
    
    // Dynamic pointers generator
    private func generateConnections() -> [PointerConnection] {
        var connections: [PointerConnection] = []
        
        // Head pointer line
        if let firstNode = nodes.first {
            connections.append(PointerConnection(fromNodeId: "global_head", toNodeId: firstNode.id, label: "head"))
        }
        
        // Nodes next pointer lines
        for i in 0..<nodes.count {
            if i < nodes.count - 1 {
                connections.append(PointerConnection(fromNodeId: nodes[i].id, toNodeId: nodes[i+1].id, label: "next"))
            }
        }
        
        return connections
    }
    
    // CORE HANDLERS
    private func updateNextAddresses() {
        for i in 0..<nodes.count {
            if i < nodes.count - 1 {
                nodes[i].nextAddress = nodes[i+1].address
            } else {
                nodes[i].nextAddress = "nullptr"
            }
        }
    }
    
    private func insertHead() {
        let val = Int(newValueStr) ?? Int.random(in: 1...99)
        let addr = MemoryAddressSimulator.random()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
            let newNode = NodeModel(value: val, address: addr)
            nodes.insert(newNode, at: 0)
            updateNextAddresses()
        }
    }
    
    private func insertTail() {
        let val = Int(newValueStr) ?? Int.random(in: 1...99)
        let addr = MemoryAddressSimulator.random()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
            let newNode = NodeModel(value: val, address: addr)
            nodes.append(newNode)
            updateNextAddresses()
        }
    }
    
    private func deleteHead() {
        guard !nodes.isEmpty else { return }
        withAnimation(.spring(response: 0.4)) {
            if selectedNodeId == nodes[0].id {
                selectedNodeId = nil
            }
            nodes.remove(at: 0)
            updateNextAddresses()
        }
    }
    
    private func deleteTail() {
        guard !nodes.isEmpty else { return }
        withAnimation(.spring(response: 0.4)) {
            let tailIdx = nodes.count - 1
            if selectedNodeId == nodes[tailIdx].id {
                selectedNodeId = nil
            }
            nodes.remove(at: tailIdx)
            updateNextAddresses()
        }
    }
    
    private func reverseList() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            nodes.reverse()
            updateNextAddresses()
        }
    }
    
    private func freeSpecificNode(id: String) {
        withAnimation(.spring(response: 0.4)) {
            if selectedNodeId == id {
                selectedNodeId = nil
            }
            nodes.removeAll(where: { $0.id == id })
            updateNextAddresses()
        }
    }
}

#if !os(Windows)
#Preview {
    SandboxView()
}
#endif
