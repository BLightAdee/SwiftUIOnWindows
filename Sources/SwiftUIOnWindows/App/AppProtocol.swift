// AppProtocol.swift - App protocol and WindowGroup
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation
#if canImport(WinSDK)
import WinSDK
#endif

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

public protocol WindowStyle {}
public struct HiddenTitleBarWindowStyle: WindowStyle, Sendable { public init() {} }
public struct TitleBarWindowStyle: WindowStyle, Sendable { public init() {} }
public struct DefaultWindowStyle: WindowStyle, Sendable { public init() {} }

extension WindowStyle where Self == HiddenTitleBarWindowStyle {
    public static var hiddenTitleBar: HiddenTitleBarWindowStyle { HiddenTitleBarWindowStyle() }
}
extension WindowStyle where Self == TitleBarWindowStyle {
    public static var titleBar: TitleBarWindowStyle { TitleBarWindowStyle() }
}
extension WindowStyle where Self == DefaultWindowStyle {
    public static var automatic: DefaultWindowStyle { DefaultWindowStyle() }
}

public protocol WindowToolbarStyle {}
public struct UnifiedWindowToolbarStyle: WindowToolbarStyle, Sendable { public init() {} }
public struct UnifiedCompactWindowToolbarStyle: WindowToolbarStyle, Sendable { public init() {} }
public struct ExpandedWindowToolbarStyle: WindowToolbarStyle, Sendable { public init() {} }

extension WindowToolbarStyle where Self == UnifiedWindowToolbarStyle {
    public static var unified: UnifiedWindowToolbarStyle { UnifiedWindowToolbarStyle() }
}
extension WindowToolbarStyle where Self == UnifiedCompactWindowToolbarStyle {
    public static var unifiedCompact: UnifiedWindowToolbarStyle { UnifiedWindowToolbarStyle() }
}
extension WindowToolbarStyle where Self == ExpandedWindowToolbarStyle {
    public static var expanded: ExpandedWindowToolbarStyle { ExpandedWindowToolbarStyle() }
}

public extension Scene {
    func windowStyle<S: WindowStyle>(_ style: S) -> some Scene { self }
    func windowToolbarStyle<S: WindowToolbarStyle>(_ style: S) -> some Scene { self }
}

extension Never: Scene {
}

// MARK: - SceneBuilder

@resultBuilder
public struct SceneBuilder {
    public static func buildBlock<Content: Scene>(_ content: Content) -> Content {
        return content
    }
}

// MARK: - WindowGroup

public protocol _WindowGroupProtocol {
    var _title: String? { get }
    func _makeContentView() -> any View
}

/// A scene that presents a group of identically structured windows.
public struct WindowGroup<Content: View>: Scene, _WindowGroupProtocol {
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

    public var _title: String? { return title }
    public func _makeContentView() -> any View {
        return content()
    }
}

// MARK: - App Runner

/// Launches a SwiftUI App on Windows using Win32.
public func runApp<A: App>(_ appType: A.Type) {
    let app = A()
    let scene = app.body

    let windowGroup = scene as? _WindowGroupProtocol
    let title = windowGroup?._title ?? "SwiftUI App"

    #if canImport(WinSDK)
    let window = Win32Window(title: title)

    window.setRenderCallback { hdc, rect in
        let renderer = Win32Renderer.shared
        let builder = RenderTreeBuilder.shared
        builder.beginFrame()
        var context = RenderContext(
            size: CGSize(width: CGFloat(rect.right - rect.left),
                         height: CGFloat(rect.bottom - rect.top))
        )
        if let wg = windowGroup {
            let view = wg._makeContentView()
            context.renderAny(view)
        } else {
            context.render(Text("SwiftUI on Windows"))
        }
        let nodes = builder.endFrame()
        renderer.render(nodes: nodes, to: hdc, in: rect)
    }

    window.setClickCallback { x, y in
        RenderTreeBuilder.shared.handleClick(at: CGPoint(x: CGFloat(x), y: CGFloat(y)))
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
    print("SwiftUI App '\(title)' cannot render outside Windows.")
    #endif
}

// MARK: - @main support

/// Extension to make any App runnable with @main.
extension App {
    public static func main() {
        runApp(Self.self)
    }
}
