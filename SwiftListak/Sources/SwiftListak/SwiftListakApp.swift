import SwiftUI

@main
public struct SwiftListakApp: App {
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 950, minHeight: 650)
                .background(.ultraThinMaterial)
        }
        .windowStyle(.hiddenTitleBar) // Modern macOS unified title bar look
        .windowToolbarStyle(.unified)
    }
}
