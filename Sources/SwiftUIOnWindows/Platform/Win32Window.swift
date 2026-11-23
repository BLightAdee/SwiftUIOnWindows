// Win32Window.swift - Win32 window management and event loop
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation
#if canImport(WinSDK)
import WinSDK

/// Creates and manages the Win32 application window.
public final class Win32Window: @unchecked Sendable {
    /// The main window handle (accessible for posting messages).
    public static var mainWindowHandle: HWND? = nil

    /// Custom message ID for SwiftUI state updates.
    public static let WM_SWIFTUI_UPDATE: UINT = WM_USER + 100

    private var hwnd: HWND?
    private var className: String
    private let title: String
    private let width: Int32
    private let height: Int32
    private var renderCallback: ((HDC?, RECT) -> Void)?
    private var clickCallback: ((Int32, Int32) -> Void)?
    private var resizeCallback: ((Int32, Int32) -> Void)?

    public init(title: String, width: Int32 = 900, height: Int32 = 650) {
        self.title = title
        self.width = width
        self.height = height
        self.className = "SwiftUIOnWindows_\(title.hashValue)"
    }

    public func setRenderCallback(_ callback: @escaping (HDC?, RECT) -> Void) {
        renderCallback = callback
    }

    public func setClickCallback(_ callback: @escaping (Int32, Int32) -> Void) {
        clickCallback = callback
    }

    public func setResizeCallback(_ callback: @escaping (Int32, Int32) -> Void) {
        resizeCallback = callback
    }

    /// Register the window class and create the window.
    public func create() -> Bool {
        // Store self for the window procedure
        Win32WindowStore.shared.window = self

        return className.withCString(encodedAs: UTF16.self) { classNamePtr in
            var wc = WNDCLASSEXW()
            wc.cbSize = UINT(MemoryLayout<WNDCLASSEXW>.size)
            wc.style = UINT(CS_HREDRAW | CS_VREDRAW)
            wc.lpfnWndProc = win32WindowProc
            wc.cbClsExtra = 0
            wc.cbWndExtra = 0
            wc.hInstance = GetModuleHandleW(nil)
            wc.hIcon = LoadIconW(nil, IDI_APPLICATION)
            wc.hCursor = LoadCursorW(nil, IDC_ARROW)
            wc.hbrBackground = nil  // We handle painting ourselves
            wc.lpszMenuName = nil
            wc.lpszClassName = classNamePtr
            wc.hIconSm = nil

            guard RegisterClassExW(&wc) != 0 else {
                print("Failed to register window class: \(GetLastError())")
                return false
            }

            // Calculate window size to get desired client area
            var rect = RECT(left: 0, top: 0, right: width, bottom: height)
            AdjustWindowRectEx(&rect, DWORD(WS_OVERLAPPEDWINDOW), false, 0)

            let windowWidth = rect.right - rect.left
            let windowHeight = rect.bottom - rect.top

            hwnd = title.withCString(encodedAs: UTF16.self) { titlePtr in
                CreateWindowExW(
                    0,
                    classNamePtr,
                    titlePtr,
                    DWORD(WS_OVERLAPPEDWINDOW),
                    Int32(CW_USEDEFAULT), Int32(CW_USEDEFAULT),
                    windowWidth, windowHeight,
                    nil, nil,
                    GetModuleHandleW(nil),
                    nil
                )
            }

            guard hwnd != nil else {
                print("Failed to create window: \(GetLastError())")
                return false
            }

            Win32Window.mainWindowHandle = hwnd
            return true
        }
    }

    /// Show the window and run the message loop.
    public func show() {
        guard let hwnd = hwnd else { return }
        ShowWindow(hwnd, Int32(SW_SHOWNORMAL))
        UpdateWindow(hwnd)
    }

    /// Run the Win32 message loop (blocking).
    public func runMessageLoop() {
        var msg = MSG()
        while GetMessageW(&msg, nil, 0, 0) {
            TranslateMessage(&msg)
            DispatchMessageW(&msg)
        }
    }

    /// Handle window messages.
    internal func handleMessage(_ hwnd: HWND?, _ msg: UINT, _ wParam: WPARAM,
                                _ lParam: LPARAM) -> LRESULT {
        switch msg {
        case UINT(WM_PAINT):
            var ps = PAINTSTRUCT()
            let hdc = BeginPaint(hwnd, &ps)
            var clientRect = RECT()
            GetClientRect(hwnd, &clientRect)

            // Double-buffer: create memory DC
            let memDC = CreateCompatibleDC(hdc)
            let width = clientRect.right - clientRect.left
            let height = clientRect.bottom - clientRect.top
            let bitmap = CreateCompatibleBitmap(hdc, width, height)
            let oldBitmap = SelectObject(memDC, bitmap)

            renderCallback?(memDC, clientRect)

            // Blit to screen
            BitBlt(hdc, 0, 0, width, height, memDC, 0, 0, DWORD(SRCCOPY))

            SelectObject(memDC, oldBitmap)
            DeleteObject(bitmap)
            DeleteDC(memDC)
            EndPaint(hwnd, &ps)
            return 0

        case UINT(WM_LBUTTONDOWN):
            let x = Int32(lParam & 0xFFFF)
            let y = Int32((lParam >> 16) & 0xFFFF)
            clickCallback?(x, y)
            return 0

        case UINT(WM_SIZE):
            let w = Int32(lParam & 0xFFFF)
            let h = Int32((lParam >> 16) & 0xFFFF)
            resizeCallback?(w, h)
            InvalidateRect(hwnd, nil, true)
            return 0

        case Win32Window.WM_SWIFTUI_UPDATE:
            InvalidateRect(hwnd, nil, true)
            StateManager.shared.performUpdate()
            return 0

        case UINT(WM_DESTROY):
            PostQuitMessage(0)
            return 0

        default:
            return DefWindowProcW(hwnd, msg, wParam, lParam)
        }
    }
}

// MARK: - Window Store (for C callback access)

private final class Win32WindowStore: @unchecked Sendable {
    static let shared = Win32WindowStore()
    var window: Win32Window?
    private init() {}
}

// MARK: - Window Procedure (C callback)

private func win32WindowProc(_ hwnd: HWND?, _ msg: UINT, _ wParam: WPARAM,
                             _ lParam: LPARAM) -> LRESULT {
    if let window = Win32WindowStore.shared.window {
        return window.handleMessage(hwnd, msg, wParam, lParam)
    }
    return DefWindowProcW(hwnd, msg, wParam, lParam)
}

#else
// Stub for non-Windows platforms
public final class Win32Window {
    public static var mainWindowHandle: Any? = nil
    public static let WM_SWIFTUI_UPDATE: UInt32 = 0

    public init(title: String, width: Int32 = 900, height: Int32 = 650) {}
    public func setRenderCallback(_ callback: @escaping (Any?, Any) -> Void) {}
    public func setClickCallback(_ callback: @escaping (Int32, Int32) -> Void) {}
    public func setResizeCallback(_ callback: @escaping (Int32, Int32) -> Void) {}
    public func create() -> Bool {
        print("Win32Window is only available on Windows")
        return false
    }
    public func show() {}
    public func runMessageLoop() {}
}
#endif
