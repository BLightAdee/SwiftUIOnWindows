import SwiftUI

public struct DoublyLinkedListView: View {
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
                        Text("Doubly Linked List Operations")
                            .font(AppTheme.titleFont(size: 20))
                        Text("Each node points to BOTH its successor and predecessor, allowing forward and backward traversals.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Picker("Operation:", selection: $selectedOp) {
                        Text("Insert Head").tag("Insert Head")
                        Text("Delete Head").tag("Delete Head")
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
                                    VisualizerNodeView(node: node, showPrevPointer: true)
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
                    .frame(height: 220)
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
                    description: "Initial doubly linked list. Notice how each pair of adjacent nodes has TWO arrows running in opposite directions, linking A->B and B->A.",
                    codeLine: 7,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", prevAddress: "nullptr"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr", prevAddress: "0x80F4")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next", style: .bidirectional)
                    ]
                ),
                // Step 1: Allocate temp
                VisualizationStep(
                    description: "Step 1: 'Node* temp = new Node(99);' creates our new node 99 on the heap. Both its next and prev are set to nullptr.",
                    codeLine: 8,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", prevAddress: "nullptr"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr", prevAddress: "0x80F4"),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "nullptr", prevAddress: "nullptr", state: .temp)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next", style: .bidirectional)
                    ]
                ),
                // Step 2: temp->next = head
                VisualizationStep(
                    description: "Step 2: 'temp->next = head;' links temp's next pointer forward to Node A (0x80F4).",
                    codeLine: 9,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", prevAddress: "nullptr"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr", prevAddress: "0x80F4"),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "0x80F4", prevAddress: "nullptr", state: .active)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeTId, toNodeId: nodeAId, label: "next", color: .orange),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next", style: .bidirectional)
                    ]
                ),
                // Step 3: head->prev = temp
                VisualizationStep(
                    description: "Step 3: 'head->prev = temp;' links Node A's backward 'prev' pointer to our new node (0x81AC). They are now fully bound bidirectionally!",
                    codeLine: 11,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", prevAddress: "0x81AC", state: .active),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr", prevAddress: "0x80F4"),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "0x80F4", prevAddress: "nullptr", state: .active)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeTId, toNodeId: nodeAId, label: "next", color: .blue, style: .bidirectional),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next", style: .bidirectional)
                    ]
                ),
                // Step 4: head = temp
                VisualizationStep(
                    description: "Step 4: 'head = temp;' updates head pointer variable to 0x81AC. The insertion is successfully integrated!",
                    codeLine: 13,
                    nodes: [
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "0x80F4", prevAddress: "nullptr"),
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", prevAddress: "0x81AC"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr", prevAddress: "0x80F4")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeTId, label: "head"),
                        PointerConnection(fromNodeId: nodeTId, toNodeId: nodeAId, label: "next", style: .bidirectional),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next", style: .bidirectional)
                    ]
                )
            ]
            
        case "Delete Head":
            steps = [
                // Step 0: Initial
                VisualizationStep(
                    description: "Initial state. A 2-node doubly linked list.",
                    codeLine: 6,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", prevAddress: "nullptr"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr", prevAddress: "0x80F4")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next", style: .bidirectional)
                    ]
                ),
                // Step 1: Save in temp
                VisualizationStep(
                    description: "Step 1: 'Node* temp = head;' saves our head reference Node 10 (0x80F4) so it can be safely released later.",
                    codeLine: 7,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", prevAddress: "nullptr", state: .active),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr", prevAddress: "0x80F4")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next", style: .bidirectional)
                    ]
                ),
                // Step 2: head = head->next
                VisualizationStep(
                    description: "Step 2: 'head = head->next;' advances the head pointer to the second node 20 (0x80F8). Node 10 is left behind.",
                    codeLine: 8,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", prevAddress: "nullptr", state: .temp),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr", prevAddress: "0x80F4")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeBId, label: "head", color: .blue),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next", style: .bidirectional)
                    ]
                ),
                // Step 3: head->prev = nullptr
                VisualizationStep(
                    description: "Step 3: 'head->prev = nullptr;' completely severs the backward connection from the new head (Node 20) to Node 10. This isolates Node 10.",
                    codeLine: 10,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", prevAddress: "nullptr", state: .temp),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr", prevAddress: "nullptr", state: .active)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeBId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next") // Only forward next remains, backward deleted!
                    ]
                ),
                // Step 4: delete temp
                VisualizationStep(
                    description: "Step 4: 'delete temp;' frees Node 10's memory on the heap. Only Node 20 remains, which is now the clean head of our list!",
                    codeLine: 12,
                    nodes: [
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr", prevAddress: "nullptr")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeBId, label: "head")
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
    
    // 2. Link temp forward to head
    temp->next = head;
    
    // 3. Link head backward to temp
    if (head != nullptr) {
        head->prev = temp;
    }
    
    // 4. Update head pointer
    head = temp;
}
"""
        case "Delete Head":
            return """
void deleteHead(Node*& head) {
    if (head == nullptr) return;
    
    Node* temp = head;
    head = head->next;     // Advance head
    
    if (head != nullptr) {
        head->prev = nullptr; // Sever back-link
    }
    
    delete temp;           // Release heap
}
"""
        default:
            return ""
        }
    }
}

#if !os(Windows)
#Preview {
    DoublyLinkedListView()
}
#endif
