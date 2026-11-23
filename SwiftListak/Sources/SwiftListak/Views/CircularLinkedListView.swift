import SwiftUI

public struct CircularLinkedListView: View {
    @State private var selectedOp: String = "Insert Head"
    @State private var currentStepIndex: Int = 0
    @State private var isPlaying: Bool = false
    @State private var speedSeconds: Double = 1.5
    
    // Canvas preference anchor points
    @State private var anchorPoints: [String: NodeAnchorData] = [:]
    
    // Steps generated for the active operation
    @State private var steps: [VisualizationStep] = []
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 0) {
            // LEFT PANEL: Visualizer Canvas
            VStack(spacing: 16) {
                // Toolbar Selector & Description
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Circular Linked List Operations")
                            .font(AppTheme.titleFont(size: 20))
                        Text("The final node (tail) points back to the first node (head), forming a continuous loop.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Picker("Operation:", selection: $selectedOp) {
                        Text("Insert Head").tag("Insert Head")
                    }
                    .pickerStyle(.menu)
                    .frame(width: 180)
                    .onChange(of: selectedOp) { oldValue, newValue in
                        loadSteps(for: newValue)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Divider()
                
                // Visual Canvas Area
                ZStack {
                    if steps.count > currentStepIndex {
                        let activeStep = steps[currentStepIndex]
                        
                        // Scroll view of Nodes
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 40) {
                                // Global Badge Anchors (Head pointer badge)
                                VStack {
                                    Text("head")
                                        .font(AppTheme.monoFont(size: 10))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue)
                                        .cornerRadius(4)
                                        .background(
                                            GeometryReader { geo in
                                                let frame = geo.frame(in: .named("canvas"))
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
                                
                                ForEach(activeStep.nodes) { node in
                                    VisualizerNodeView(node: node)
                                        .padding(.top, node.state == .temp ? 0 : 32)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Background lines overlay (PointerArrowView)
                        PointerArrowView(connections: activeStep.pointers, anchorData: anchorPoints)
                    }
                }
                .coordinateSpace(name: "canvas")
                .onPreferenceChange(NodeGeometryPreferenceKey.self) { anchors in
                    self.anchorPoints = anchors
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.primary.opacity(0.01))
                
                // Controller Bar
                if steps.count > 0 {
                    ControlPanel(
                        currentStep: currentStepIndex,
                        totalSteps: steps.count,
                        isPlaying: isPlaying,
                        speedSeconds: $speedSeconds,
                        onStepBackward: stepBackward,
                        onStepForward: stepForward,
                        onPlayPauseToggle: { isPlaying.toggle() },
                        onReset: resetVisualization
                    )
                    .padding(.bottom, 16)
                }
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            // RIGHT PANEL: Xcode-style inspector showing Code & Logs
            VStack(alignment: .leading, spacing: 0) {
                // Header Tabs
                HStack {
                    Text("C++ Code Implementation")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right.square")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.primary.opacity(0.04))
                
                Divider()
                
                // Code block
                if steps.count > currentStepIndex {
                    CodeBlockView(
                        code: operationCode(for: selectedOp),
                        highlightedLineIndex: steps[currentStepIndex].codeLine
                    )
                    .frame(height: 250)
                }
                
                Divider()
                
                // Step explanation logs (Xcode Inspector info pane look)
                VStack(alignment: .leading, spacing: 8) {
                    Text("CONSOLE LOG & STEP DETAILS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    if steps.count > currentStepIndex {
                        Text(steps[currentStepIndex].description)
                            .font(AppTheme.bodyFont(size: 12))
                            .foregroundColor(.primary)
                            .lineSpacing(3)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .frame(maxHeight: .infinity)
                .background(Color.primary.opacity(0.01))
            }
            .frame(width: 320)
        }
        .onAppear {
            loadSteps(for: selectedOp)
        }
        // Autoplay Task
        .task(id: isPlaying) {
            if isPlaying {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: UInt64(speedSeconds * 1_000_000_000))
                    await MainActor.run {
                        stepForward()
                    }
                }
            }
        }
    }
    
    // Autoplay Controls
    private func stepForward() {
        if currentStepIndex < steps.count - 1 {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                currentStepIndex += 1
            }
        } else {
            isPlaying = false
        }
    }
    
    private func stepBackward() {
        if currentStepIndex > 0 {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                currentStepIndex -= 1
            }
        }
    }
    
    private func resetVisualization() {
        withAnimation(.spring(response: 0.4)) {
            currentStepIndex = 0
            isPlaying = false
        }
    }
    
    // Core steps database generators
    private func loadSteps(for op: String) {
        isPlaying = false
        currentStepIndex = 0
        
        let nodeAId = "node_a"
        let nodeBId = "node_b"
        let nodeTId = "node_temp"
        
        switch op {
        case "Insert Head":
            steps = [
                // Step 0: Initial State
                VisualizationStep(
                    description: "Initial Circular Linked List. Notice the curved pointer sweeping underneath, linking Node B (tail, 0x80F8) back to Node A (head, 0x80F4) instead of nullifying.",
                    codeLine: 8,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "0x80F4")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next"),
                        PointerConnection(fromNodeId: nodeBId, toNodeId: nodeAId, label: "next", style: .curved)
                    ]
                ),
                // Step 1: Allocate temp
                VisualizationStep(
                    description: "Step 1: 'Node* temp = new Node(99);' creates our new node 99 on the heap. Its next is initially nullptr.",
                    codeLine: 9,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "0x80F4"),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "nullptr", state: .temp)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next"),
                        PointerConnection(fromNodeId: nodeBId, toNodeId: nodeAId, label: "next", style: .curved)
                    ]
                ),
                // Step 2: Link temp->next = head
                VisualizationStep(
                    description: "Step 2: 'temp->next = head;' links the new node forward to the current head Node A (0x80F4).",
                    codeLine: 12,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "0x80F4"),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "0x80F4", state: .active)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeTId, toNodeId: nodeAId, label: "next", color: .orange),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next"),
                        PointerConnection(fromNodeId: nodeBId, toNodeId: nodeAId, label: "next", style: .curved)
                    ]
                ),
                // Step 3: Traverse to find tail
                VisualizationStep(
                    description: "Step 3: Traversal occurs. A 'tail' pointer is advanced until 'tail->next == head', identifying Node B (0x80F8) as the tail.",
                    codeLine: 15,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "0x80F4", state: .active), // Highlighted tail
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "0x80F4", state: .normal)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeTId, toNodeId: nodeAId, label: "next"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next"),
                        PointerConnection(fromNodeId: nodeBId, toNodeId: nodeAId, label: "next", color: .indigo, style: .curved) // Active sweep tail
                    ]
                ),
                // Step 4: Link tail->next = temp
                VisualizationStep(
                    description: "Step 4: 'tail->next = temp;' updates the tail Node B's next address to store Node 99 (0x81AC). The sweeping curve now redirects underneath to Node 99!",
                    codeLine: 16,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "0x81AC", state: .active),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "0x80F4", state: .active)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeTId, toNodeId: nodeAId, label: "next"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next"),
                        PointerConnection(fromNodeId: nodeBId, toNodeId: nodeTId, label: "next", color: .orange, style: .curved) // Sweeping to temp
                    ]
                ),
                // Step 5: head = temp
                VisualizationStep(
                    description: "Step 5: 'head = temp;' reassigns the 'head' pointer variable to Node 99. The loop is complete! Tail points to Node 99, and Node 99 points back to Node 10.",
                    codeLine: 17,
                    nodes: [
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "0x80F4"),
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "0x81AC")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeTId, label: "head"),
                        PointerConnection(fromNodeId: nodeTId, toNodeId: nodeAId, label: "next"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next"),
                        PointerConnection(fromNodeId: nodeBId, toNodeId: nodeTId, label: "next", style: .curved)
                    ]
                )
            ]
            
        default:
            break
        }
    }
    
    private func operationCode(for op: String) -> String {
        switch op {
        case "Insert Head":
            return """
void insertAtHead(Node*& head, int val) {
    // 1. Allocate on heap
    Node* temp = new Node(val);
    
    if (head == nullptr) {
        head = temp;
        temp->next = temp; // Loop to itself
    } else {
        temp->next = head; // Link temp to head
        
        // Find tail node to re-link loop
        Node* tail = head;
        while (tail->next != head) {
            tail = tail->next;
        }
        tail->next = temp; // Relink tail to temp
        head = temp;       // Set temp as head
    }
}
"""
        default:
            return ""
        }
    }
}

#if !os(Windows)
#Preview {
    CircularLinkedListView()
}
#endif
