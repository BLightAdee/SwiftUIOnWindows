import SwiftUI
import Foundation

/// States a node can be in during an animation step
public enum NodeVisualState: String, Codable {
    case normal
    case active      // Being inspected or current target
    case temp        // Newly allocated but not linked
    case highlight   // Special focus (e.g., found search target)
    case deleted     // Fading out/being freed
}

/// A node model representing a dynamic cell in memory
public struct NodeModel: Identifiable, Equatable {
    public let id: String
    public var value: Int
    public var address: String        // Simulated hex: e.g. 0x7FFA830C
    public var nextAddress: String    // "nullptr" or next node's address
    public var prevAddress: String?   // "nullptr" or prev node's address (for doubly linked lists)
    public var state: NodeVisualState
    
    public init(id: String = UUID().uuidString,
                value: Int,
                address: String,
                nextAddress: String = "nullptr",
                prevAddress: String? = nil,
                state: NodeVisualState = .normal) {
        self.id = id
        self.value = value
        self.address = address
        self.nextAddress = nextAddress
        self.prevAddress = prevAddress
        self.state = state
    }
}

/// The style of pointer line to render
public enum PointerStyle {
    case straight
    case curved
    case bidirectional
}

/// Explicit pointer connection drawn on overlay canvas
public struct PointerConnection: Identifiable, Equatable {
    public let id: String
    public var fromNodeId: String?     // nil represents global/external variable (e.g. head, curr)
    public var toNodeId: String?       // nil represents pointing to nullptr
    public var label: String           // "head", "tail", "curr", "temp", "next", "prev"
    public var color: Color
    public var style: PointerStyle
    
    public init(id: String = UUID().uuidString,
                fromNodeId: String? = nil,
                toNodeId: String? = nil,
                label: String,
                color: Color = .blue,
                style: PointerStyle = .straight) {
        self.id = id
        self.fromNodeId = fromNodeId
        self.toNodeId = toNodeId
        self.label = label
        self.color = color
        self.style = style
    }
}

/// Struct representing a single frame of the interactive visualizer
public struct VisualizationStep: Identifiable {
    public let id: String = UUID().uuidString
    public var description: String           // Short textual explanation of what's happening
    public var codeLine: Int                 // Index of code line to highlight (0-indexed)
    public var nodes: [NodeModel]            // List layout at this step
    public var pointers: [PointerConnection] // Global/local pointers to render
    
    public init(description: String, codeLine: Int, nodes: [NodeModel], pointers: [PointerConnection]) {
        self.description = description
        self.codeLine = codeLine
        self.nodes = nodes
        self.pointers = pointers
    }
}

// Helper to generate simulated hex addresses
public struct MemoryAddressSimulator {
    public static func random() -> String {
        let hexChars = "0123456789ABCDEF"
        var result = "0x7FF"
        for _ in 0..<5 {
            result.append(hexChars.randomElement()!)
        }
        return result
    }
}
