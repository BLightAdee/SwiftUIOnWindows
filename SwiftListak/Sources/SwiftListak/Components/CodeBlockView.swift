import SwiftUI
import Foundation

public struct CodeBlockView: View {
    public let code: String
    public let highlightedLineIndex: Int? // 0-indexed line to highlight
    
    public init(code: String, highlightedLineIndex: Int? = nil) {
        self.code = code
        self.highlightedLineIndex = highlightedLineIndex
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Bar (Xcode-like Tab style)
            HStack(spacing: 8) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .foregroundColor(AppTheme.XcodeColors.comment)
                    .font(.system(size: 11, weight: .semibold))
                Text("LinkedList.cpp")
                    .font(AppTheme.monoFont(size: 11))
                    .foregroundColor(AppTheme.XcodeColors.editorText)
                Spacer()
                // Xcode window controls styling
                HStack(spacing: 4) {
                    Circle().fill(Color.red.opacity(0.6)).frame(width: 8, height: 8)
                    Circle().fill(Color.yellow.opacity(0.6)).frame(width: 8, height: 8)
                    Circle().fill(Color.green.opacity(0.6)).frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.primary.opacity(0.06))
            
            Divider()
            
            // Code Editor Console
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 0) {
                        let lines = code.components(separatedBy: .newlines)
                        ForEach(0..<lines.count, id: \.self) { index in
                            let isHighlighted = index == highlightedLineIndex
                            
                            HStack(alignment: .top, spacing: 12) {
                                // Line Number
                                Text("\(index + 1)")
                                    .font(AppTheme.monoFont(size: 12))
                                    .foregroundColor(isHighlighted ? .blue : AppTheme.XcodeColors.comment.opacity(0.6))
                                    .frame(width: 24, alignment: .trailing)
                                    .padding(.leading, 6)
                                
                                // Code Line Content
                                Text(highlightedString(from: lines[index]))
                                    .font(AppTheme.monoFont(size: 12))
                                    .foregroundColor(AppTheme.XcodeColors.editorText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 3)
                            .background(
                                isHighlighted ? 
                                AppTheme.XcodeColors.activeLineHighlight : 
                                Color.clear
                            )
                            .overlay(
                                // Native Xcode highlight indicator
                                HStack {
                                    if isHighlighted {
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: 3)
                                        Spacer()
                                    }
                                }
                            )
                            .id(index)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: highlightedLineIndex) { oldValue, newValue in
                    if let targetIndex = newValue {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            proxy.scrollTo(targetIndex, anchor: .center)
                        }
                    }
                }
            }
            .background(AppTheme.XcodeColors.editorBackground)
        }
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }
    
    // Dynamic Lexer / Syntax Highlighter
    private func highlightedString(from line: String) -> AttributedString {
        var attrString = AttributedString(line)
        
        // Match Comments
        if let commentRange = line.range(of: "//") {
            let startIdx = attrString.unicodeScalars.index(attrString.startIndex, offsetBy: line.distance(from: line.startIndex, to: commentRange.lowerBound))
            let endIdx = attrString.endIndex
            attrString[startIdx..<endIdx].foregroundColor = AppTheme.XcodeColors.comment
            return attrString
        }
        
        // Tokens definitions
        let keywords = [
            "struct", "class", "public", "private", "int", "void", "new", "delete",
            "nullptr", "NULL", "return", "while", "if", "else", "bool", "true", "false"
        ]
        let types = ["Node", "head", "tail", "temp", "curr", "prev", "next"]
        let preprocessors = ["#include", "#define", "#ifndef", "#endif"]
        
        // Tokenize standard words
        let pattern = "\\b[A-Za-z_][A-Za-z0-9_]*\\b"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let nsLine = line as NSString
            let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: nsLine.length))
            
            for match in matches.reversed() { // Iterate backwards to avoid index shifting if modifying length (not strictly necessary for AttributedString but safe)
                let nsRange = match.range
                guard let range = Range(nsRange, in: line) else { continue }
                let word = String(line[range])
                
                let startIdx = attrString.unicodeScalars.index(attrString.startIndex, offsetBy: nsRange.location)
                let endIdx = attrString.unicodeScalars.index(attrString.startIndex, offsetBy: nsRange.location + nsRange.length)
                
                if keywords.contains(word) {
                    attrString[startIdx..<endIdx].foregroundColor = AppTheme.XcodeColors.keyword
                    attrString[startIdx..<endIdx].inlinePresentationIntent = .stronglyEmphasized
                } else if types.contains(word) {
                    attrString[startIdx..<endIdx].foregroundColor = AppTheme.XcodeColors.type
                } else if preprocessors.contains(word) {
                    attrString[startIdx..<endIdx].foregroundColor = AppTheme.XcodeColors.preprocessor
                }
            }
        }
        
        // Tokenize numbers
        let numPattern = "\\b\\d+\\b"
        if let regex = try? NSRegularExpression(pattern: numPattern) {
            let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: (line as NSString).length))
            for match in matches {
                let nsRange = match.range
                let startIdx = attrString.unicodeScalars.index(attrString.startIndex, offsetBy: nsRange.location)
                let endIdx = attrString.unicodeScalars.index(attrString.startIndex, offsetBy: nsRange.location + nsRange.length)
                attrString[startIdx..<endIdx].foregroundColor = AppTheme.XcodeColors.number
            }
        }
        
        return attrString
    }
}

#if !os(Windows)
#Preview {
    CodeBlockView(
        code: """
#include <iostream>

struct Node {
    int data;
    Node* next;
    
    Node(int val) : data(val), next(nullptr) {}
};

void insertAtHead(Node*& head, int val) {
    // Allocate new node
    Node* temp = new Node(val);
    temp->next = head;
    head = temp;
}
""",
        highlightedLineIndex: 12
    )
    .frame(width: 400, height: 300)
    .padding()
}
#endif
