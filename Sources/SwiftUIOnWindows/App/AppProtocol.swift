// AppProtocol.swift - App protocol and WindowGroup
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - App Protocol

/// The entry point for a SwiftUI application.
public protocol App {
    associatedtype Body: Scene
    @SceneBuilder var body: Body { get }
    init()
}

// MARK: - Scene Protocol

public protocol Scene {
    associatedtype Body: Scene
    @SceneBuilder var body: Body { get }
}

extension Never: Scene {
    public var body: Never {
        fatalError("Never should not have a body accessed")
    }
}

// MARK: - SceneBuilder

@resultBuilder
public struct SceneBuilder {
    public static func buildBlock<Content: Scene>(_ content: Content) -> Content {
        return content
    }
}

// MARK: - WindowGroup

/// A scene that presents a group of identically structured windows.
public struct WindowGroup<Content: View>: Scene {
    public typealias Body = Never

    internal let title: String?
    internal let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.title = nil
        self.content = content
    }

    public init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    public var body: Never {
        fatalError("WindowGroup is a leaf scene")
    }
}

// MARK: - App Runner

/// Launches a SwiftUI App on Windows using Win32.
public func runApp<A: App>(_ appType: A.Type) {
    let app = A()

    // Extract the WindowGroup from the app body
    let scene = app.body

    guard let windowGroup = scene as? WindowGroup<AnyView> else {
        // Try to run with the scene anyway
        print("SwiftUIOnWindows: Starting app...")
        #if canImport(WinSDK)
        let window = Win32Window(title: "SwiftUI App")

        window.setRenderCallback { hdc, rect in
            let renderer = Win32Renderer.shared
            let builder = RenderTreeBuilder.shared
            builder.beginFrame()
            var context = RenderContext(
                size: CGSize(width: CGFloat(rect.right - rect.left),
                             height: CGFloat(rect.bottom - rect.top))
            )
            // Render placeholder
            context.render(Text("SwiftUI on Windows"))
            let nodes = builder.endFrame()
            renderer.render(nodes: nodes, to: hdc, in: rect)
        }

        if window.create() {
            window.show()
            window.runMessageLoop()
        }
        #else
        print("Not running on Windows. App lifecycle requires Win32.")
        #endif
        return
    }

    let title = windowGroup.title ?? "SwiftUI App"
    let contentView = windowGroup.content()

    #if canImport(WinSDK)
    import WinSDK
    let window = Win32Window(title: title)

    window.setRenderCallback { hdc, rect in
        let renderer = Win32Renderer.shared
        let builder = RenderTreeBuilder.shared
        builder.beginFrame()
        var context = RenderContext(
            size: CGSize(width: CGFloat(rect.right - rect.left),
                         height: CGFloat(rect.bottom - rect.top))
        )
        context.render(contentView)
        let nodes = builder.endFrame()
        renderer.render(nodes: nodes, to: hdc, in: rect)
    }

    if window.create() {
        window.show()
        window.runMessageLoop()
    }
    #else
    print("SwiftUI App '\(title)' cannot render outside Windows.")
    #endif
}

// MARK: - @main support

/// Extension to make any App runnable with @main.
extension App {
    public static func main() {
        // Create Win32 window and run the app
        let app = Self()
        let scene = app.body

        #if canImport(WinSDK)
        let title = "SwiftUI App"
        let window = Win32Window(title: title)

        window.setRenderCallback { hdc, rect in
            let renderer = Win32Renderer.shared
            let builder = RenderTreeBuilder.shared
            builder.beginFrame()
            var context = RenderContext(
                size: CGSize(width: CGFloat(rect.right - rect.left),
                             height: CGFloat(rect.bottom - rect.top))
            )
            // We need to render the content from WindowGroup
            let nodes = builder.endFrame()
            renderer.render(nodes: nodes, to: hdc, in: rect)
        }

        StateManager.shared.setRenderCallback {
            if let hwnd = Win32Window.mainWindowHandle {
                InvalidateRect(hwnd, nil, true)
            }
        }

        if window.create() {
            window.show()
            window.runMessageLoop()
        }
        #else
        print("SwiftUI App cannot render outside Windows.")
        #endif
    }
}
