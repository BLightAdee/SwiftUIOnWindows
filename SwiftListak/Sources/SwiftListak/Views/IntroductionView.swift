import SwiftUI

public struct IntroductionView: View {
    @State private var comparisonMode: Int = 0 // 0 = Array, 1 = Linked List
    
    public init() {}
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                // Header Hero Section (Apple Aesthetic)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Introduction")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.indigo)
                    Text("Dynamic Memory Allocation")
                        .font(AppTheme.titleFont(size: 28))
                        .foregroundColor(.primary)
                    Text("Understanding how C/C++ handles data structures physically in RAM.")
                        .font(AppTheme.bodyFont(size: 14))
                        .foregroundColor(.secondary)
                }
                
                // Segmented Picker (macOS Native look)
                Picker("", selection: $comparisonMode) {
                    Text("Contiguous Array (std::vector)").tag(0)
                    Text("Dynamic Linked List (std::list)").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 450)
                
                // Interactive Memory Visualizer
                VStack(alignment: .leading, spacing: 12) {
                    Text("Physical RAM Layout View")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    if comparisonMode == 0 {
                        ArrayMemoryVisualizer()
                            .transition(.opacity)
                    } else {
                        ListMemoryVisualizer()
                            .transition(.opacity)
                    }
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.1), lineWidth: 1))
                
                // Key Structural Comparison Table (Apple Grid style)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Time Complexity Matrix")
                        .font(AppTheme.titleFont(size: 18))
                    
                    VStack(spacing: 0) {
                        // Table Headers
                        HStack {
                            Text("Operation")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Array (Contiguous)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Linked List (Scattered)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.primary.opacity(0.04))
                        
                        Divider()
                        
                        // Rows
                        complexityRow(op: "Access by Index", array: "O(1) - Fast direct math", list: "O(n) - Sequentially traverse pointers", highlightArray: true)
                        complexityRow(op: "Insert / Delete at Head", array: "O(n) - Shift all trailing slots", list: "O(1) - Simply rewire head pointer", highlightArray: false)
                        complexityRow(op: "Insert / Delete at Tail", array: "O(1) amortized", list: "O(1) - If tail pointer is saved", highlightArray: false)
                        complexityRow(op: "Insert / Delete in Middle", array: "O(n) - Shift remaining slots", list: "O(n) - Find position + O(1) link", highlightArray: false)
                    }
                    .background(Color.primary.opacity(0.02))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.08), lineWidth: 1))
                }
                
                // Rich Descriptions
                VStack(alignment: .leading, spacing: 10) {
                    Text("Under the Hood in C/C++")
                        .font(AppTheme.titleFont(size: 18))
                    
                    Text("In C/C++, an **array** is allocated as a single, uninterrupted chunk of bytes in memory. The CPU can jump directly to any index because the address math is simple: `Address = Base + Index * Size`. However, resizing or inserting at the front forces a costly copy operation.")
                        .font(AppTheme.bodyFont(size: 13))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                    
                    Text("A **linked list**, conversely, utilizes **Heap memory allocation**. Each element (node) resides in a distinct, separate RAM address. Nodes link together by embedding a **pointer** (the hexadecimal address) to their successor. This yields infinite structural flexibility at the cost of direct indexing capability.")
                        .font(AppTheme.bodyFont(size: 13))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
            }
            .padding(24)
        }
    }
    
    // Sub-components
    private func complexityRow(op: String, array: String, list: String, highlightArray: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(op)
                    .font(.system(size: 12, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(array)
                    .font(AppTheme.monoFont(size: 11))
                    .foregroundColor(highlightArray ? .green : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(list)
                    .font(AppTheme.monoFont(size: 11))
                    .foregroundColor(highlightArray ? .primary : .green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            Divider()
        }
    }
}

// Contiguous Array Visualizer Component
struct ArrayMemoryVisualizer: View {
    let elements = [10, 20, 30, 40, 50]
    let baseAddr = 0x1000
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 2) {
                ForEach(0..<elements.count, id: \.self) { idx in
                    VStack(spacing: 8) {
                        // Index
                        Text("[\(idx)]")
                            .font(AppTheme.monoFont(size: 9))
                            .foregroundColor(.secondary)
                        
                        // Cell
                        VStack(spacing: 2) {
                            Text("data")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                            Text("\(elements[idx])")
                                .font(AppTheme.titleFont(size: 14))
                                .bold()
                        }
                        .frame(width: 56, height: 42)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                        
                        // Address (each occupies 4 bytes for integer)
                        Text(String(format: "0x%04X", baseAddr + (idx * 4)))
                            .font(AppTheme.monoFont(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
            
            Text("Elements are physically packed together in a single block. Notice how the hexadecimal RAM addresses increment linearly by exactly 4 bytes (`+4`).")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// Scattered List Visualizer Component
struct ListMemoryVisualizer: View {
    // We statically position nodes to demonstrate scattered memory layout
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                // Node 1
                VStack(spacing: 6) {
                    Text("0x7FFA")
                        .font(AppTheme.monoFont(size: 9))
                        .foregroundColor(.indigo)
                    HStack(spacing: 0) {
                        Text("10").bold().frame(width: 28)
                        Divider()
                        Text("x7FF0").foregroundColor(.blue).font(AppTheme.monoFont(size: 8)).frame(width: 32)
                    }
                    .frame(height: 30)
                    .background(Color.teal.opacity(0.1))
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.teal.opacity(0.3), lineWidth: 1))
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                
                // Node 2
                VStack(spacing: 6) {
                    Text("0x7FF0")
                        .font(AppTheme.monoFont(size: 9))
                        .foregroundColor(.indigo)
                    HStack(spacing: 0) {
                        Text("20").bold().frame(width: 28)
                        Divider()
                        Text("x7FFC").foregroundColor(.blue).font(AppTheme.monoFont(size: 8)).frame(width: 32)
                    }
                    .frame(height: 30)
                    .background(Color.teal.opacity(0.1))
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.teal.opacity(0.3), lineWidth: 1))
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                
                // Node 3
                VStack(spacing: 6) {
                    Text("0x7FFC")
                        .font(AppTheme.monoFont(size: 9))
                        .foregroundColor(.indigo)
                    HStack(spacing: 0) {
                        Text("30").bold().frame(width: 28)
                        Divider()
                        Text("∅").foregroundColor(.blue).font(AppTheme.monoFont(size: 10)).frame(width: 32)
                    }
                    .frame(height: 30)
                    .background(Color.teal.opacity(0.1))
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.teal.opacity(0.3), lineWidth: 1))
                }
            }
            .padding(.vertical, 8)
            
            Text("Nodes are scattered at random positions in heap space. The sequential link is established solely because the 'next' cell stores the destination's hex address.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#if !os(Windows)
#Preview {
    IntroductionView()
}
#endif
