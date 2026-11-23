import SwiftUI

public enum AppTopic: String, CaseIterable, Identifiable {
    case introduction = "Introduction"
    case nodeStructure = "Node Structure"
    case singlyList = "Singly Linked List"
    case doublyList = "Doubly Linked List"
    case circularList = "Circular Linked List"
    case sandbox = "Interactive Sandbox"
    case quiz = "Memory & Pointer Quiz"
    
    public var id: String { self.rawValue }
    
    public var icon: String {
        switch self {
        case .introduction: return "doc.text"
        case .nodeStructure: return "square.stack.3d.up"
        case .singlyList: return "arrow.right"
        case .doublyList: return "arrow.left.and.right"
        case .circularList: return "arrow.3.trianglepath"
        case .sandbox: return "cube.transparent"
        case .quiz: return "checkmark.seal"
        }
    }
    
    public var category: String {
        switch self {
        case .introduction, .nodeStructure:
            return "GETTING STARTED"
        case .singlyList, .doublyList, .circularList:
            return "DYNAMIC VISUALIZERS"
        case .sandbox:
            return "PLAYGROUND"
        case .quiz:
            return "ASSESSMENT"
        }
    }
}

public struct MainView: View {
    @State private var selectedTopic: AppTopic? = .introduction
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            // Sidebar Navigation (Xcode style)
            List(selection: $selectedTopic) {
                // Grouping sidebar by categories
                ForEach(categories, id: \.self) { category in
                    Section(header: Text(category).font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)) {
                        ForEach(topics(in: category)) { topic in
                            NavigationLink(value: topic) {
                                HStack(spacing: 8) {
                                    Image(systemName: topic.icon)
                                        .foregroundColor(topicColor(topic))
                                        .frame(width: 16)
                                    Text(topic.rawValue)
                                        .font(.system(size: 13, weight: .medium))
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("SwiftListak")
            .frame(minWidth: 200, maxWidth: 260)
            
        } detail: {
            // Detail panel displaying active educational views
            if let topic = selectedTopic {
                detailView(for: topic)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(nsColor: .windowBackgroundColor)) // Native macOS background texture
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "square.dashed.3.squares")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Select a topic from the sidebar")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(minWidth: 850, minHeight: 600)
    }
    
    // Core Layout Helpers
    private var categories: [String] {
        ["GETTING STARTED", "DYNAMIC VISUALIZERS", "PLAYGROUND", "ASSESSMENT"]
    }
    
    private func topics(in category: String) -> [AppTopic] {
        AppTopic.allCases.filter { $0.category == category }
    }
    
    private func topicColor(_ topic: AppTopic) -> Color {
        switch topic.category {
        case "GETTING STARTED": return .indigo
        case "DYNAMIC VISUALIZERS": return .blue
        case "PLAYGROUND": return .teal
        case "ASSESSMENT": return .green
        default: return .primary
        }
    }
    
    // Dynamic Router mapping selected topic to content view
    @ViewBuilder
    private func detailView(for topic: AppTopic) -> some View {
        switch topic {
        case .introduction:
            IntroductionView()
        case .nodeStructure:
            NodeStructureView()
        case .singlyList:
            SinglyLinkedListView()
        case .doublyList:
            DoublyLinkedListView()
        case .circularList:
            CircularLinkedListView()
        case .sandbox:
            SandboxView()
        case .quiz:
            QuizView()
        }
    }
}

// Fallback extension to make NSColor work on standard SwiftUI preview / compilation
#if !canImport(AppKit)
public struct NSColor {
    public static let windowBackgroundColor = NSColor()
    public static let controlBackgroundColor = NSColor()
    public static let textBackgroundColor = NSColor()
}
extension Color {
    init(nsColor: NSColor) {
        self = .clear
    }
}
#else
extension Color {
    init(nsColor: NSColor) {
        self = Color(nsColor)
    }
}
#endif

#if !os(Windows)
#Preview {
    MainView()
}
#endif
