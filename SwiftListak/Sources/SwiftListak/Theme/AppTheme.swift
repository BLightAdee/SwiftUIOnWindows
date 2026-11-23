import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

public struct AppTheme {
    // System-like vibrant macOS colors
    public struct XcodeColors {
        // Native Xcode Dark Theme editor colors
        public static let editorBackground = Color(red: 0.114, green: 0.122, blue: 0.149) // #1D1F26
        public static let editorText = Color(red: 0.878, green: 0.886, blue: 0.898)
        public static let keyword = Color(red: 0.925, green: 0.141, blue: 0.463) // #EC2476 - Pink/Magenta
        public static let type = Color(red: 0.388, green: 0.796, blue: 0.690) // #63CBB0 - Teal
        public static let number = Color(red: 0.443, green: 0.482, blue: 0.965) // #717BF6 - Purple/Blue
        public static let comment = Color(red: 0.439, green: 0.522, blue: 0.592) // #708597 - Slate Gray
        public static let string = Color(red: 0.961, green: 0.408, blue: 0.322) // #F56852 - Salmon Red
        public static let preprocessor = Color(red: 0.894, green: 0.502, blue: 0.196) // #E48032 - Orange
        public static let activeLineHighlight = Color(red: 0.176, green: 0.204, blue: 0.278) // Highlight active execution line
    }
    
    public struct UI {
        // Xcode Inspector styling
        public static let inspectorBackground = Color(red: 0.141, green: 0.149, blue: 0.180)
        
        // Pointers and Nodes colors
        public static let nodeBorderNormal = Color.secondary.opacity(0.4)
        public static let nodeBorderActive = Color.blue
        public static let nodeBorderTemp = Color.orange
        public static let nodeBorderHighlight = Color.green
        
        public static let pointerLineNormal = Color.primary.opacity(0.6)
        public static let pointerLineActive = Color.blue
        public static let pointerLineTemp = Color.orange
        public static let pointerLineDelete = Color.red
        
        // Stack vs Heap
        public static let stackAccent = Color.indigo
        public static let heapAccent = Color.teal
    }
    
    // Typography
    public static func monoFont(size: CGFloat) -> Font {
        Font.custom("SF Mono", size: size).monospaced()
    }
    
    public static func titleFont(size: CGFloat) -> Font {
        Font.system(size: size, weight: .bold, design: .rounded)
    }
    
    public static func bodyFont(size: CGFloat) -> Font {
        Font.system(size: size, weight: .regular, design: .default)
    }
}

// Glassmorphism and Card Styling View Modifiers
struct XcodeCardModifier: ViewModifier {
    var isSelected: Bool = false
    var highlightColor: Color = .blue
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.thinMaterial)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? highlightColor : Color.primary.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

extension View {
    public func xcodeCardStyle(isSelected: Bool = false, highlightColor: Color = .blue) -> some View {
        self.modifier(XcodeCardModifier(isSelected: isSelected, highlightColor: highlightColor))
    }
}
