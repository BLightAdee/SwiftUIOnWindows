// StateManager.swift - Coordinates state changes and UI updates
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation
#if canImport(WinSDK)
import WinSDK
#endif

/// Manages the UI update cycle triggered by state changes.
public final class StateManager: @unchecked Sendable {
    public static let shared = StateManager()

    private var updateScheduled = false
    private var renderCallback: (() -> Void)?

    private init() {}

    /// Register the render callback (called by the platform window).
    public func setRenderCallback(_ callback: @escaping () -> Void) {
        renderCallback = callback
    }

    /// Schedule a UI update. Coalesces multiple rapid state changes.
    public func scheduleUpdate() {
        guard !updateScheduled else { return }
        updateScheduled = true

        #if canImport(WinSDK)
        // Post a custom message to the Win32 message loop
        if let hwnd = Win32Window.mainWindowHandle {
            PostMessageW(hwnd, Win32Window.WM_SWIFTUI_UPDATE, 0, 0)
        }
        #else
        // Fallback: dispatch async
        DispatchQueue.main.async { [weak self] in
            self?.performUpdate()
        }
        #endif
    }

    /// Perform the actual UI re-render.
    public func performUpdate() {
        updateScheduled = false
        renderCallback?()
    }
}
