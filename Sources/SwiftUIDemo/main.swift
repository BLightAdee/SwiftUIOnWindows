// main.swift - SwiftUI Demo Application
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows
// This demonstrates SwiftUI code running natively on Windows.

import SwiftUIOnWindows
#if canImport(WinSDK)
import WinSDK
#endif

// ============================================================================
// MARK: - Demo Views (Standard SwiftUI Syntax!)
// ============================================================================

/// A simple counter view demonstrating @State and event handling.
struct CounterView: View {
    @State private var count: Int = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("SwiftUI on Windows")
                .font(.largeTitle)
                .foregroundColor(.blue)

            Text("Counter: \(count)")
                .font(.title2)
                .foregroundColor(.primary)

            HStack(spacing: 12) {
                Button("- Decrement") {
                    count -= 1
                }

                Button("+ Increment") {
                    count += 1
                }
            }

            if count > 10 {
                Text("🎉 You passed 10!")
                    .foregroundColor(.green)
                    .font(.headline)
            } else if count < 0 {
                Text("Going negative!")
                    .foregroundColor(.red)
                    .font(.headline)
            }

            Divider()

            Text("This app was written in pure SwiftUI\nand compiled natively on Windows!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
    }
}

/// A settings-like form view.
struct SettingsView: View {
    @State private var username: String = ""
    @State private var isDarkMode: Bool = false
    @State private var fontSize: Double = 13.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.title)
                .foregroundColor(.primary)

            Divider()

            HStack {
                Text("Username:")
                    .font(.body)
                TextField("Enter username", text: $username)
            }

            Toggle("Dark Mode", isOn: $isDarkMode)

            HStack {
                Text("Font Size: \(Int(fontSize))")
                Slider(value: $fontSize, in: 8...36)
            }

            Spacer()
        }
        .padding(16)
    }
}

/// A card component showing composability.
struct CardView: View {
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white)
                .opacity(0.8)
        }
        .padding(16)
        .background(color)
        .cornerRadius(12)
    }
}

/// Main content view combining all demos.
struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("SwiftUI on Windows")
                    .font(.title2)
                    .foregroundColor(.white)
                Spacer()
                Text("Demo App")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .opacity(0.7)
            }
            .padding(16)
            .background(Color.blue)

            // Content
            VStack(spacing: 16) {
                CounterView()

                Divider()

                // Cards
                HStack(spacing: 12) {
                    CardView(title: "Views", subtitle: "Text, Button, Image, Toggle",
                             color: .blue)
                    CardView(title: "Layout", subtitle: "VStack, HStack, ZStack, List",
                             color: .green)
                    CardView(title: "State", subtitle: "@State, @Binding, @Observable",
                             color: .purple)
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(16)
        }
    }
}

// ============================================================================
// MARK: - App Entry Point
// ============================================================================

/// The main SwiftUI application.
struct SwiftUIOnWindowsApp: App {
    var body: some Scene {
        WindowGroup("SwiftUI on Windows — Demo") {
            ContentView()
        }
    }
}

// ============================================================================
// MARK: - Launch
// ============================================================================

#if canImport(WinSDK)
// On Windows: Create the Win32 window and run the app

let appTitle = "SwiftUI on Windows — Demo"
let window = Win32Window(title: appTitle, width: 960, height: 700)

// Set up the render pipeline
window.setRenderCallback { hdc, rect in
    let renderer = Win32Renderer.shared
    let builder = RenderTreeBuilder.shared
    builder.beginFrame()

    var context = RenderContext(
        size: CGSize(
            width: Double(rect.right - rect.left),
            height: Double(rect.bottom - rect.top)
        )
    )
    context.render(ContentView())

    let nodes = builder.endFrame()
    renderer.render(nodes: nodes, to: hdc, in: rect)
}

// Set up state management
StateManager.shared.setRenderCallback {
    if let hwnd = Win32Window.mainWindowHandle {
        InvalidateRect(hwnd, nil, true)
    }
}

// Create and show the window
print("SwiftUI on Windows - Starting application...")
if window.create() {
    window.show()
    print("Window created successfully. Running event loop...")
    window.runMessageLoop()
} else {
    print("ERROR: Failed to create window")
}

#else
// On non-Windows platforms: print the view tree
print("╔══════════════════════════════════════════════════╗")
print("║       SwiftUI on Windows — Demo App             ║")
print("╠══════════════════════════════════════════════════╣")
print("║ This is a cross-platform SwiftUI compatibility  ║")
print("║ layer. On Windows, this renders a native Win32  ║")
print("║ window with GDI rendering.                      ║")
print("║                                                  ║")
print("║ Running in console mode (non-Windows platform)  ║")
print("╚══════════════════════════════════════════════════╝")
print()
print("View tree preview:")
print("  ContentView")
print("    └─ VStack")
print("       ├─ HStack (header)")
print("       │  ├─ Text('SwiftUI on Windows')")
print("       │  └─ Text('Demo App')")
print("       ├─ CounterView")
print("       │  ├─ Text('Counter: 0')")
print("       │  └─ HStack")
print("       │     ├─ Button('- Decrement')")
print("       │     └─ Button('+ Increment')")
print("       ├─ Divider")
print("       └─ HStack (cards)")
print("          ├─ CardView('Views')")
print("          ├─ CardView('Layout')")
print("          └─ CardView('State')")
#endif
