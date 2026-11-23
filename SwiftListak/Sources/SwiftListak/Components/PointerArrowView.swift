import SwiftUI
import Foundation

public struct PointerArrowView: View {
    public let connections: [PointerConnection]
    public let anchorData: [String: NodeAnchorData]
    
    public init(connections: [PointerConnection], anchorData: [String: NodeAnchorData]) {
        self.connections = connections
        self.anchorData = anchorData
    }
    
    public var body: some View {
        bodyContent
    }
    
    // Instead of drawing everything in a single Path, let's render individual paths in a ZStack
    // to give each connection its own color, opacity, and spring animation.
    public var bodyContent: some View {
        ZStack {
            ForEach(connections) { conn in
                if let fromId = conn.fromNodeId,
                   let toId = conn.toNodeId,
                   let fromAnchor = anchorData[fromId],
                   let toAnchor = anchorData[toId] {
                    
                    Path { path in
                        switch conn.style {
                        case .straight:
                            // Check if source is a global variable badge or a node
                            let startPoint = fromId.hasPrefix("global_") ? fromAnchor.bottomAnchor : fromAnchor.rightAnchor
                            let endPoint = fromId.hasPrefix("global_") ? toAnchor.topAnchor : toAnchor.leftAnchor
                            drawStraightArrow(in: &path, from: startPoint, to: endPoint)
                            
                        case .bidirectional:
                            // Forward Arrow
                            let startFwd = CGPoint(x: fromAnchor.rightAnchor.x, y: fromAnchor.rightAnchor.y - 6)
                            let endFwd = CGPoint(x: toAnchor.leftAnchor.x, y: toAnchor.leftAnchor.y - 6)
                            drawStraightArrow(in: &path, from: startFwd, to: endFwd)
                            
                            // Backward Arrow
                            let startBwd = CGPoint(x: toAnchor.leftAnchor.x, y: toAnchor.leftAnchor.y + 6)
                            let endBwd = CGPoint(x: fromAnchor.rightAnchor.x, y: fromAnchor.rightAnchor.y + 6)
                            drawStraightArrow(in: &path, from: startBwd, to: endBwd)
                            
                        case .curved:
                            drawCurvedUnderArrow(in: &path, from: fromAnchor.bottomAnchor, to: toAnchor.bottomAnchor)
                        }
                    }
                    .stroke(conn.color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .shadow(color: conn.color.opacity(0.15), radius: 2)
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// Low-Level Geometric Drawing Helpers
extension PointerArrowView {
    
    private func drawStraightArrow(in path: inout Path, from: CGPoint, to: CGPoint) {
        // Draw main line
        path.move(to: from)
        path.addLine(to: to)
        
        // Calculate angle of arrowhead
        let angle = atan2(to.y - from.y, to.x - from.x)
        drawArrowHead(in: &path, at: to, angle: angle)
    }
    
    private func drawCurvedUnderArrow(in path: inout Path, from: CGPoint, to: CGPoint) {
        // A sweeping curve that starts from bottom of tail, dips down, and ends at bottom of head.
        path.move(to: from)
        
        // Control points located vertically lower than the nodes
        let deltaX = abs(to.x - from.x)
        let dipOffset = min(120.0, max(60.0, deltaX * 0.25)) // scale curve depth with distance
        
        let control1 = CGPoint(x: from.x + 30, y: from.y + dipOffset)
        let control2 = CGPoint(x: to.x - 30, y: to.y + dipOffset)
        
        path.addCurve(to: to, control1: control1, control2: control2)
        
        // Direction angle at destination (pointing up/left)
        // Approximate tangent at end of curve: tangent from control2 to to
        let angle = atan2(to.y - control2.y, to.x - control2.x)
        drawArrowHead(in: &path, at: to, angle: angle)
    }
    
    private func drawArrowHead(in path: inout Path, at point: CGPoint, angle: CGFloat, size: CGFloat = 8) {
        let arrowAngle = CGFloat.pi / 6 // 30-degree flare
        
        let p1 = CGPoint(
            x: point.x - size * cos(angle - arrowAngle),
            y: point.y - size * sin(angle - arrowAngle)
        )
        let p2 = CGPoint(
            x: point.x - size * cos(angle + arrowAngle),
            y: point.y - size * sin(angle + arrowAngle)
        )
        
        // Add arrowhead to path
        path.move(to: point)
        path.addLine(to: p1)
        path.move(to: point)
        path.addLine(to: p2)
    }
}


