import SwiftUI

public struct SinglyLinkedListView: View {
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
                        Text("Singly Linked List Operations")
                            .font(AppTheme.titleFont(size: 20))
                        Text("Each node points ONLY to its successor in a single direction.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Picker("Operation:", selection: $selectedOp) {
                        Text("Insert Head").tag("Insert Head")
                        Text("Insert Middle").tag("Insert Middle")
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
                                    VisualizerNodeView(node: node)
                                        .padding(.top, node.state == .temp ? 0 : 32) // temp nodes align higher up
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
        // Swift Concurrency Autoplay task
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
                    description: "The list contains 2 elements. The 'head' pointer stores Node A's address (0x80F4).",
                    codeLine: 7,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next")
                    ]
                ),
                // Step 1: Allocate temp
                VisualizationStep(
                    description: "Step 1: 'Node* temp = new Node(99);' allocates a new node with data 99 on the heap. It gets address '0x81AC' and 'next' is initialized to nullptr.",
                    codeLine: 8,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr"),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "nullptr", state: .temp)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next")
                        // temp points to the allocated node (we can overlay a temp label later, or let it hover)
                    ]
                ),
                // Step 2: temp->next = head
                VisualizationStep(
                    description: "Step 2: 'temp->next = head;' rewires 'temp''s next pointer to hold 'head''s address (0x80F4). Node 99 now points to Node 10.",
                    codeLine: 9,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr"),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "0x80F4", state: .active)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeTId, toNodeId: nodeAId, label: "next", color: .orange),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next")
                    ]
                ),
                // Step 3: head = temp
                VisualizationStep(
                    description: "Step 3: 'head = temp;' reassigns 'head' to store the temp node address (0x81AC). Node 99 is now officially the head of the list!",
                    codeLine: 10,
                    nodes: [
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "0x80F4"),
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeTId, label: "head", color: .blue),
                        PointerConnection(fromNodeId: nodeTId, toNodeId: nodeAId, label: "next"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next")
                    ]
                )
            ]
            
        case "Insert Middle":
            steps = [
                // Step 0: Initial State
                VisualizationStep(
                    description: "Initial list state. We want to insert node with value 99 at index 1 (between 10 and 20).",
                    codeLine: 5,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next")
                    ]
                ),
                // Step 1: Allocate temp
                VisualizationStep(
                    description: "Step 1: 'Node* temp = new Node(99);' creates our new cell on the heap.",
                    codeLine: 6,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr"),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "nullptr", state: .temp)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next")
                    ]
                ),
                // Step 2: Initialize curr
                VisualizationStep(
                    description: "Step 2: 'Node* curr = head;' initializes a 'curr' pointer badge to traverse the list.",
                    codeLine: 7,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", state: .active),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr"),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "nullptr", state: .temp)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next")
                    ]
                ),
                // Step 3: Link temp->next = curr->next
                VisualizationStep(
                    description: "Step 3: 'temp->next = curr->next;' links the new node 99 to the node AFTER curr (Node 20, at address 0x80F8).",
                    codeLine: 11,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", state: .active),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr"),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "0x80F8", state: .active)
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next"),
                        PointerConnection(fromNodeId: nodeTId, toNodeId: nodeBId, label: "next", color: .orange)
                    ]
                ),
                // Step 4: Link curr->next = temp
                VisualizationStep(
                    description: "Step 4: 'curr->next = temp;' breaks Node 10's original connection and rewires it to point directly to our new Node 99 (0x81AC). The insertion is complete!",
                    codeLine: 12,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x81AC"),
                        NodeModel(id: nodeTId, value: 99, address: "0x81AC", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeTId, label: "next", color: .blue),
                        PointerConnection(fromNodeId: nodeTId, toNodeId: nodeBId, label: "next")
                    ]
                )
            ]
            
        case "Delete Head":
            steps = [
                // Step 0: Initial
                VisualizationStep(
                    description: "Initial state. The list contains 2 elements.",
                    codeLine: 6,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8"),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next")
                    ]
                ),
                // Step 1: Save in temp
                VisualizationStep(
                    description: "Step 1: 'Node* temp = head;' saves the address of the head node (0x80F4) so that we can delete it from the heap later.",
                    codeLine: 7,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", state: .active),
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeAId, label: "head"),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next")
                    ]
                ),
                // Step 2: head = head->next
                VisualizationStep(
                    description: "Step 2: 'head = head->next;' advances the head pointer to the next element (0x80F8). The list starting index is shifted, but the first node still exists.",
                    codeLine: 8,
                    nodes: [
                        NodeModel(id: nodeAId, value: 10, address: "0x80F4", nextAddress: "0x80F8", state: .temp), // Isolated
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr")
                    ],
                    pointers: [
                        PointerConnection(fromNodeId: "global_head", toNodeId: nodeBId, label: "head", color: .blue),
                        PointerConnection(fromNodeId: nodeAId, toNodeId: nodeBId, label: "next")
                    ]
                ),
                // Step 3: delete temp
                VisualizationStep(
                    description: "Step 3: 'delete temp;' releases the original node's memory on the heap. Node 10 is successfully deleted and cannot be leaked!",
                    codeLine: 9,
                    nodes: [
                        NodeModel(id: nodeBId, value: 20, address: "0x80F8", nextAddress: "nullptr")
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
    // 1. Create a new Node on Heap
    Node* temp = new Node(val);
    
    // 2. Link temp's next to head
    temp->next = head;
    
    // 3. Move head to point to temp
    head = temp;
}
"""
        case "Insert Middle":
            return """
void insertAtMiddle(Node*& head, int val, int index) {
    Node* temp = new Node(val);
    Node* curr = head;
    
    for (int i = 0; i < index - 1; i++) {
        curr = curr->next;
    }
    
    temp->next = curr->next;
    curr->next = temp;
}
"""
        case "Delete Head":
            return """
void deleteHead(Node*& head) {
    if (head == nullptr) return;
    
    Node* temp = head;     // Save head pointer
    head = head->next;     // Move head to index 1
    delete temp;           // Release the heap memory
}
"""
        default:
            return ""
        }
    }
}

#if !os(Windows)
#Preview {
    SinglyLinkedListView()
}
#endif
